import 'dart:async';
// import 'dart:isolate';
import 'package:acta/acta.dart';
import 'package:acta/src/model/defines.dart';
import 'package:flutter/foundation.dart';

/// Central event and error journal for Acta.
///
/// Handles initialization, error capturing, context management, breadcrumbs, and
/// reporting to multiple [Reporter]s. Supports hooks for event mutation and notification,
/// and can capture errors from Flutter, platform, and async sources.
///
/// Usage:
///   - Call [initialize] at app startup to set up error capturing and reporting.
///   - Use [report] to manually log events.
///   - Use [setContext], [setContextKey], and [addBreadcrumb] to enrich event data.
class ActaJournal {
  /// List of active reporters to send events to.
  static final List<Reporter> _reporters = [];

  /// Current handler options (controls error capture and filtering).
  static late HandlerOptions _options;

  /// Optional hook to mutate or filter events before sending.
  static BeforeSend? _beforeSend;

  /// Optional callback triggered after an event is captured.
  static OnCaptured? _onCaptured;

  /// Global context merged into every event's metadata.
  static Map<String, dynamic> _globalContext = {};

  /// In-memory list of breadcrumbs (recent app actions).
  static final List<Map<String, dynamic>> _breadcrumbs = [];

  /// Initializes the journal, sets up error capturing, and runs the app.
  ///
  /// - [appRunner]: Function to run the app (usually runApp).
  /// - [reporters]: List of reporters to send events to.
  /// - [options]: Handler configuration.
  /// - [beforeSend]: Optional hook to mutate/filter events before sending.
  /// - [onCaptured]: Optional callback after event is captured.
  /// - [initialContext]: Initial global context for all events.
  /// - [zoneSpecification]: Optional custom zone specification for async error capture.
  static void initialize({
    required void Function() appRunner,
    required List<Reporter> reporters,
    HandlerOptions options = const HandlerOptions(),
    BeforeSend? beforeSend,
    OnCaptured? onCaptured,
    Map<String, dynamic>? initialContext,
    ZoneSpecification? zoneSpecification,
  }) {
    _reporters
      ..clear()
      ..addAll(reporters);
    _options = options;
    _beforeSend = beforeSend;
    _onCaptured = onCaptured;
    _globalContext = {...?initialContext};

    if (_options.logFlutterErrors) {
      final prev = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        report(
          event: ErrorEvent(
            message: "FlutterError caught",
            exception: details.exception,
            stackTrace: details.stack,
            severity: Severity.critical,
          ),
        );
        prev?.call(details);
      };
    }
    if (_options.logPlatformErrors) {
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        report(
          event: ErrorEvent(
            message: "Platform error caught",
            exception: error,
            stackTrace: stack,
            severity: Severity.critical,
          ),
        );
        return true;
      };
    }
    if (_options.catchAsyncErrors) {
      runZonedGuarded(appRunner, (Object error, StackTrace stack) {
        report(
          event: ErrorEvent(
            message: "Async error caught",
            exception: error,
            stackTrace: stack,
            severity: Severity.critical,
          ),
        );
      }, zoneSpecification: zoneSpecification);
    } else {
      appRunner();
    }
  }

  /// Sets the global context for all future events.
  static void setContext(Map<String, dynamic> context) {
    _globalContext = Map<String, dynamic>.from(context);
  }

  /// Updates or adds a single key in the global context.
  static void setContextKey(String key, Object? value) {
    _globalContext[key] = value;
  }

  /// Adds a breadcrumb (recent action or state) to the in-memory list.
  /// Keeps only the last [maxBreadcrumbs] items.
  static void addBreadcrumb(String message, {Map<String, dynamic>? data}) {
    final bc = {
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      if (data != null) ...data,
    };
    _breadcrumbs.add(bc);
    if (_breadcrumbs.length > _options.maxBreadcrumbs) {
      _breadcrumbs.removeRange(
        0,
        _breadcrumbs.length - _options.maxBreadcrumbs,
      );
    }
  }

  /// Reports an [Event] to all configured reporters.
  ///
  /// - Merges global context and breadcrumbs into the event.
  /// - Applies [beforeSend] hook (can mutate or drop the event).
  /// - Sends to all reporters (fan-out).
  /// - Calls [onCaptured] callback after reporting.
  static Future<void> report({
    required Event event,
    Map<String, dynamic>? meta,
  }) async {
    if (event.severity.index < _options.minSeverity.index) return;
    event
      ..metadata = {..._globalContext, ...?meta}
      ..breadcrumbs = List<Map<String, dynamic>>.from(_breadcrumbs);
    event.calculateFingerprint();

    final maybe = await Future.value(_beforeSend?.call(event) ?? event);
    if (maybe == null) return;

    for (final r in _reporters) {
      try {
        _reportEventMethod(r, maybe);
        // Pass only serializable data
        // ========================================================================
        // await compute(_isolateEntry, {
        //   'reporterType': r.runtimeType.toString(),
        //   'event': maybe.toJson(), // <- you need toJson()
        // });
        // ========================================================================
        // final receivePort = ReceivePort();
        // await Isolate.spawn(_isolateWorker, {
        //   'sendPort': receivePort.sendPort,
        //   'reporterType': r.runtimeType.toString(),
        //   'event': maybe.toJson(), // <- again must be serializable
        // });
        // // optional: wait for completion
        // await for (var message in receivePort) {
        //   if (message == 'done') {
        //     receivePort.close();
        //     break;
        //   }
        // }
        // ========================================================================
      } catch (e, s) {
        debugPrint('[ACTA] reporter ${r.runtimeType} failed: $e\n$s');
      }
    }
    _onCaptured?.call(maybe);
  }

  /// Internal helper to report an event to a single reporter.
  static void _reportEventMethod(Reporter r, Event event) async {
    try {
      await r.report(event);
    } catch (e, s) {
      //TODO Safe Fallback reporter
      debugPrint('[ACTA] reporter ${r.runtimeType} failed: $e\n$s');
    }
  }

  //  TODO future improvments
  // static Future<void> _isolateEntry(Map<String, dynamic> args) async {
  //   final String reporterType = args['reporterType'];
  //   final event = Event.fromJson(args['event']); // <- you need fromJson()
  //   // Recreate reporter based on type
  //   final Reporter r = Reporter.create(reporterType);
  //   await _reportEventMethod(r, event);
  // }

  // static Future<void> _isolateWorker(Map<String, dynamic> args) async {
  //   final sendPort = args['sendPort'] as SendPort;
  //   final String reporterType = args['reporterType'];
  //   final event = Event.fromJson(args['event']);
  //   final Reporter r = Reporter.create(reporterType);
  //   await _reportEventMethod(r, event);
  //   sendPort.send('done');
  // }
}

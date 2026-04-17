import 'dart:async';
import 'package:acta/acta.dart';
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
  static final List<ReporterFactory> _reporters = [];

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
  /// - [integrations]: List of integrations to initialize (e.g. FlutterIntegration).
  static void initialize({
    required void Function() appRunner,
    required List<ReporterFactory> reporters,
    HandlerOptions options = const HandlerOptions(),
    BeforeSend? beforeSend,
    OnCaptured? onCaptured,
    Map<String, dynamic>? initialContext,
    ZoneSpecification? zoneSpecification,
    List<ActaIntegration> integrations = const [],
  }) {
    _reporters
      ..clear()
      ..addAll(reporters);
    _options = options;
    _beforeSend = beforeSend;
    _onCaptured = onCaptured;
    _globalContext = {...?initialContext};

    // Initialize integrations
    for (final integration in integrations) {
      integration();
    }

    // Legacy support (to be deprecated)
    if (_options.logFlutterErrors &&
        !integrations.any((i) => i is FlutterIntegration)) {
      FlutterIntegration().setupFlutterErrorCapture();
    }
    if (_options.logPlatformErrors &&
        !integrations.any((i) => i is FlutterIntegration)) {
      FlutterIntegration().setupPlatformErrorCapture();
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
    if (event.shouldReport(_options.minSeverity.index)) return;
    event
      ..metadata = {..._globalContext, ...?meta}
      ..breadcrumbs = List<Map<String, dynamic>>.from(_breadcrumbs);
    event.preloadEvent();

    final maybe = await Future.value(_beforeSend?.call(event) ?? event);
    if (maybe == null) return;

    for (final entry in _reporters) {
      final r = entry.instance;
      try {
        _reportEventMethod(r, maybe);
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
}

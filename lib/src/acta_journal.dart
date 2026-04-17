import 'dart:async';
import 'package:acta/acta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

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

  /// Background event processing queue.
  static final StreamController<_QueuedEvent> _eventController =
      StreamController<_QueuedEvent>();

  /// Future representing the background worker's life.
  static Future<void>? _workerFuture;

  /// Resets the journal for testing purposes.
  @visibleForTesting
  static void reset() {
    _reporters.clear();
    _globalContext = {};
    _breadcrumbs.clear();
    _beforeSend = null;
    _onCaptured = null;
  }

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
    required List<ReporterFactory> reporters,
    HandlerOptions options = const HandlerOptions(),
    BeforeSend? beforeSend,
    OnCaptured? onCaptured,
    Map<String, dynamic>? initialContext,
    ZoneSpecification? zoneSpecification,
  }) {
    _ensureWorkerRunning();
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

  /// Flushes all pending events in the queue.
  ///
  /// Returns a [Future] that completes when all currently queued events
  /// have been processed by the background worker.
  static Future<void> flush() async {
    final completer = Completer<void>();
    // We send a special event that just completes when reached
    _eventController.add(_QueuedEvent(
      _FlushEvent(),
      completer,
    ));
    return completer.future;
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
  /// - Queues the event for background processing.
  /// - Returns a [Future] that completes when the event has been processed.
  static Future<void> report({
    required Event event,
    Map<String, dynamic>? meta,
  }) {
    if (event.shouldReport(_options.minSeverity.index)) return Future.value();

    // Capture state immediately to ensure accuracy
    event
      ..metadata = {..._globalContext, ...?meta}
      ..breadcrumbs = List<Map<String, dynamic>>.from(_breadcrumbs);

    // Preload event (calculate fingerprint, etc.) before queuing to ensure
    // we capture the correct execution context (e.g., stack traces).
    event.preloadEvent();

    _ensureWorkerRunning();

    final completer = Completer<void>();
    _eventController.add(_QueuedEvent(event, completer));
    return completer.future;
  }

  /// Ensures the background worker is running.
  static void _ensureWorkerRunning() {
    _workerFuture ??= _runWorker();
  }

  /// Internal worker that processes queued events.
  static Future<void> _runWorker() async {
    await for (final queuedEvent in _eventController.stream) {
      try {
        if (kIsWeb) {
          await _processEvent(queuedEvent);
        } else {
          // Attempt to use SchedulerBinding for non-blocking processing
          final scheduler = SchedulerBinding.instance;
          // ignore: unnecessary_null_comparison
          if (scheduler != null) {
            await scheduler.scheduleTask(
              () => _processEvent(queuedEvent),
              Priority.idle,
            );
          } else {
            // Fallback for non-Flutter environments (e.g., pure Dart tests)
            await Future.microtask(() => _processEvent(queuedEvent));
          }
        }
      } catch (e, s) {
        debugPrint('[ACTA] Background worker error: $e\n$s');
        if (!queuedEvent.completer.isCompleted) {
          queuedEvent.completer.complete();
        }
      }
    }
  }

  /// Internal helper to process a single queued event.
  static Future<void> _processEvent(_QueuedEvent queued) async {
    final event = queued.event;
    if (event is _FlushEvent) {
      queued.completer.complete();
      return;
    }

    try {
      Event? maybe = event;
      if (_beforeSend != null) {
        maybe = await _beforeSend!(event);
      }
      if (maybe == null) return;

      for (final entry in _reporters) {
        final r = entry.instance;
        try {
          await r.report(maybe);
        } catch (e, s) {
          debugPrint('[ACTA] reporter ${r.runtimeType} failed: $e\n$s');
        }
      }
      _onCaptured?.call(maybe);
    } finally {
      if (!queued.completer.isCompleted) {
        queued.completer.complete();
      }
    }
  }
}

/// Internal event used to signal a flush.
class _FlushEvent extends Event {}

/// Internal wrapper for queued events.
class _QueuedEvent {
  final Event event;
  final Completer<void> completer;
  _QueuedEvent(this.event, this.completer);
}

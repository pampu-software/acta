import 'dart:ui';
import 'package:acta/acta.dart';
import 'package:acta/src/integrations/integration.dart';
import 'package:flutter/foundation.dart';

/// Integration that captures errors from the Flutter framework and the platform.
class FlutterIntegration implements ActaIntegration {
  @override
  void call() {
    setupFlutterErrorCapture();
    setupPlatformErrorCapture();
  }

  /// Sets up Flutter error capturing.
  void setupFlutterErrorCapture() {
    final prev = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      ActaJournal.report(
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

  /// Sets up platform error capturing.
  void setupPlatformErrorCapture() {
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      ActaJournal.report(
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
}

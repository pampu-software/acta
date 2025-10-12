import 'package:acta/acta.dart';

/// Configuration options for the event handler.
///
/// Controls how errors and events are captured and processed:
///
/// - [catchAsyncErrors]: Whether to catch uncaught asynchronous errors (e.g., in zones).
/// - [logFlutterErrors]: Whether to capture and log Flutter framework errors.
/// - [logPlatformErrors]: Whether to capture platform-level errors.
/// - [minSeverity]: Minimum severity required for an event to be processed.
/// - [maxBreadcrumbs]: Maximum number of breadcrumbs to keep in memory.
class HandlerOptions {
  final bool catchAsyncErrors;
  final bool logFlutterErrors;
  final bool logPlatformErrors;
  final Severity minSeverity;
  final int maxBreadcrumbs;

  const HandlerOptions({
    this.catchAsyncErrors = true,
    this.logFlutterErrors = true,
    this.logPlatformErrors = true,
    this.minSeverity = Severity.info,
    this.maxBreadcrumbs = 50,
  });
}

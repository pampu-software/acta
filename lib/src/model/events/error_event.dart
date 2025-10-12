import 'package:acta/src/model/events/base_event.dart';
import 'package:acta/src/model/severity.dart';
import 'package:acta/src/utils/utils.dart';

///Implementation of ErrorEvent extends [BaseEvent]
///
/// Represents an error event with additional details:
///
/// - [exception]: The error or exception object that was thrown or caught.
///   Can be any type (e.g., Exception, Error, String) and provides context about what went wrong.
/// - [stackTrace]: The stack trace at the moment the exception occurred.
///   Useful for debugging, as it shows the sequence of function calls leading to the error.
class ErrorEvent extends BaseEvent {
  /// The error or exception object associated with this event.
  final Object? exception;

  /// The stack trace captured when the exception occurred.
  final StackTrace? stackTrace;

  ErrorEvent({
    required super.message,
    super.severity,
    super.metadata,
    super.tag,
    super.breadcrumbs,
    super.timestamp,
    this.exception,
    this.stackTrace,
  });

  @override
  void calculateFingerprint() =>
      super.fingerPrint = generateFingerprint(exception, stackTrace);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'exception': exception.toString(),
      'stackTrace': stackTrace.toString(),
    });
    return map;
  }

  factory ErrorEvent.fromMap(Map<String, dynamic> map) {
    return ErrorEvent(
      message: map['message'] as String,
      severity: SeverityMapper.fromMap(map['severity'] as String),
      tag: map['tag'] as String?,
      metadata:
          map['metadata'] != null
              ? Map<String, dynamic>.from(map['metadata'] as Map)
              : null,
      breadcrumbs:
          map['breadcrumbs'] != null
              ? List<Map<String, dynamic>>.from(map['breadcrumbs'] as List)
              : null,
      timestamp:
          map['timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
              : null,
      exception: map['exception'],
      stackTrace:
          map['stackTrace'] != null
              ? StackTrace.fromString(map['stackTrace'] as String)
              : null,
    )..fingerPrint = map['fingerPrint'] as String;
  }

  @override
  String toString() =>
      'ErrorEvent(${super.getContentToString()} exception: $exception, stackTrace: $stackTrace)';

  @override
  String prettyPrinter() {
    final buffer = StringBuffer();
    if (exception != null) buffer.writeln('Exception: $exception');
    if (stackTrace != null) buffer.writeln('StackTrace: $stackTrace');
    return "${super.prettyPrinter()}${buffer.toString()}";
  }
}

import 'dart:convert';
import 'package:acta/src/model/events/event.dart';
import 'package:acta/src/model/severity.dart';

/// Base implementation of [Event].
///
/// Represents a generic event in the system, with core attributes:
///
/// - [message]: Description or details about the event.
/// - [severity]: Importance or level of the event (e.g., info, warning, error).
/// - [tag]: Optional label to categorize the event.
/// - [metadata]: Optional map with extra data related to the event.
/// - [breadcrumbs]: Optional list of contextual actions or states leading up to the event.
/// - [timestamp]: When the event occurred.
/// - [fingerPrint]: Unique identifier for the event, useful for grouping or deduplication.
class BaseEvent implements Event {
  late String fingerPrint;
  final String message;
  final String? tag;
  @override
  final Severity severity;
  @override
  Map<String, dynamic>? metadata;
  @override
  List<Map<String, dynamic>>? breadcrumbs;
  DateTime timestamp;

  BaseEvent({
    required this.message,
    this.severity = Severity.info,
    this.metadata,
    this.tag,
    List<Map<String, dynamic>>? breadcrumbs,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now(),
       breadcrumbs = breadcrumbs ?? [];

  @override
  void calculateFingerprint() {
    fingerPrint =
        '${message.replaceAll(RegExp(r'\d+'), '#')}|${severity.name}|${tag ?? ''}';
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'fingerPrint': fingerPrint,
      'severity': severity.toMap(),
      'tag': tag,
      'metadata': metadata,
      'breadcrumbs': breadcrumbs,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory BaseEvent.fromMap(Map<String, dynamic> map) {
    return BaseEvent(
      message: map['message'] as String,
      severity: SeverityMapper.fromMap(map['severity'] as String),
      tag: map['tag'] != null ? map['tag'] as String : null,
      metadata:
          map['metadata'] != null
              ? Map<String, dynamic>.from(
                map['metadata'] as Map<String, dynamic>,
              )
              : null,
      breadcrumbs:
          map['breadcrumbs'] != null
              ? List<Map<String, dynamic>>.from(map['breadcrumbs'] as List)
              : [],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    )..fingerPrint = map['fingerPrint'] as String;
  }

  @override
  String toJson() => json.encode(toMap());

  factory BaseEvent.fromJson(String source) =>
      BaseEvent.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Event($getContentToString)';

  @override
  String getContentToString() {
    return 'fingerPrint: $fingerPrint, message: $message, severity: $severity, tag: $tag, metadata: $metadata, breadcrumbs: $breadcrumbs, timestamp: $timestamp';
  }

  @override
  String prettyPrinter() {
    final buffer = StringBuffer();
    buffer.writeln(
      '[${severity.name.toUpperCase()}] ${timestamp.toIso8601String()}',
    );
    buffer.writeln('Message: $message');
    buffer.writeln('FingerPrint: $fingerPrint');
    if (metadata != null && metadata!.isNotEmpty) {
      buffer.writeln('Metadata: $metadata');
    }
    if (breadcrumbs != null && breadcrumbs!.isNotEmpty) {
      buffer.writeln('Breadcrumbs:');
      for (final bc in breadcrumbs!) {
        buffer.writeln('  - $bc');
      }
    }
    return buffer.toString();
  }
}

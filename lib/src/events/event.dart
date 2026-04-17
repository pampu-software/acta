import 'dart:convert';
import 'package:acta/src/helpers/severity.dart';

/// Abstraction of event, could be extended as [BaseEvent] and [ErrorEvent]
abstract class Event {
  String? fingerPrint;
  final String message;
  final String? tag;
  final Severity severity;
  Map<String, dynamic>? metadata;
  List<Map<String, dynamic>>? breadcrumbs;
  final DateTime timestamp;

  Event({
    required this.message,
    this.severity = Severity.info,
    this.tag,
    this.metadata,
    this.fingerPrint,
    List<Map<String, dynamic>>? breadcrumbs,
    DateTime? timestamp,
  })  : timestamp = timestamp ?? DateTime.now(),
        breadcrumbs = breadcrumbs ?? [];

  bool shouldReport(Severity minSeverity) {
    return severity.weight >= minSeverity.weight;
  }

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

  String toJson() => jsonEncode(toMap());
  String getContentToString() {
    return 'fingerPrint: $fingerPrint, message: $message, severity: $severity, tag: $tag, metadata: $metadata, breadcrumbs: $breadcrumbs, timestamp: $timestamp';
  }

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

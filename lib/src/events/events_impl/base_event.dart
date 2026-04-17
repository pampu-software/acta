import 'dart:convert';
import 'package:acta/src/helpers/capabilities.dart';
import 'package:acta/src/events/event.dart';
import 'package:acta/src/helpers/severity.dart';

/// Base implementation of [Event].
///
/// Represents a generic event in the system.
class BaseEvent extends Event implements SeverityAware, Fingerprintable {
  BaseEvent({
    required super.message,
    super.severity = Severity.info,
    super.metadata,
    super.tag,
    super.breadcrumbs,
    super.timestamp,
    super.fingerPrint,
  });

  @override
  void calculateFingerprint() {
    fingerPrint =
        '${message.replaceAll(RegExp(r'\d+'), '#')}|${severity.name}|${tag ?? ''}';
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
      fingerPrint: map['fingerPrint'] as String?,
    );
  }

  factory BaseEvent.fromJson(String source) =>
      BaseEvent.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Event(${getContentToString()})';
}

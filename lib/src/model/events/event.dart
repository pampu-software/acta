import 'dart:convert';

import 'package:acta/acta.dart';

/// Abstraction of event, could be extended as [BaseEvent] and [ErrorEvent]
abstract class Event {
  Map<String, dynamic>? metadata;
  List<Map<String, dynamic>>? breadcrumbs;

  bool shouldReport(int index) => true;

  Map<String, dynamic> toMap() => {'': ''};
  String toJson() => jsonEncode(toMap());
  String getContentToString() => toJson();
  String prettyPrinter() => getContentToString();
}

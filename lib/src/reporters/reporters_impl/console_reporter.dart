import 'package:acta/acta.dart';
import 'package:flutter/foundation.dart';

/// Reporter that outputs events to the console.
///
/// Useful for debugging and development. Supports pretty-printing for more readable output.
class ConsoleReporter implements Reporter {
  /// If true, uses [Event.prettyPrinter] for formatted output; otherwise, uses [Event.toString].
  final bool pretty;
  ConsoleReporter({this.pretty = true});

  /// Reports the [Event] to the console.
  ///
  /// Uses pretty formatting if [pretty] is true.
  @override
  Future<void> report(Event r) async {
    if (pretty) {
      debugPrint(r.prettyPrinter());
    } else {
      debugPrint(r.toString());
    }
  }
}

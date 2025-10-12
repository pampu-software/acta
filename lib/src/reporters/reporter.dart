import 'package:acta/acta.dart';

/// Abstraction of reporter, could be extended as [ConsoleReporter]
abstract class Reporter {
  /// Function to send the [Event] of reporter, each [Reporter] has its own implementation
  Future<void> report(Event report);
}

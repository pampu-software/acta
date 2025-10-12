import 'package:acta/acta.dart';
import 'package:hive/hive.dart';

/// Reporter that stores events locally using a Hive [Box].
///
/// Enables offline-first logging: events are saved on the device and can be flushed or synced later.
class LocalDbReporter implements Reporter {
  /// The Hive box used to persist event data.
  final Box box;
  LocalDbReporter(this.box);

  /// Saves the [Event] to the local Hive box as JSON.
  ///
  /// This allows events to be retained even when offline, and processed or uploaded later.
  @override
  Future<void> report(Event r) async {
    await box.add(r.toJson());
  }
}

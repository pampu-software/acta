import 'package:acta/acta.dart';
import 'package:hive/hive.dart';

/// A custom reporter implemented in the app side using Hive.
/// This shows how to use Acta with external dependencies without
/// having those dependencies in the core Acta package.
class HiveReporter implements Reporter {
  final Box box;
  HiveReporter(this.box);

  @override
  Future<void> report(Event event) async {
    await box.add(event.toJson());
  }
}

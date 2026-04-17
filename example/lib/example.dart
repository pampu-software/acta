import 'package:acta/acta.dart';
import 'package:example/bloc_integration.dart';
import 'package:example/custom_report.dart';
import 'package:example/hive_reporter.dart';
import 'package:example/screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bloc/bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (for the optional HiveReporter example)
  await Hive.initFlutter();
  final box = await Hive.openBox('acta_events');

  // Set up Bloc observer (for the optional Bloc integration example)
  Bloc.observer = ActaBlocObserver();

  ActaJournal.initialize(
    reporters: [
      ReporterFactory.createReporter(ConsoleReporter()),
      ReporterFactory.createReporter(HiveReporter(box)), // Using the new optional HiveReporter
      ReporterFactory.createLazyReporter(() => CustomReport()),
    ],
    integrations: [
      FlutterIntegration(), // Built-in integration
    ],
    options: const HandlerOptions(
      catchAsyncErrors: true,
      minSeverity: Severity.info,
      maxBreadcrumbs: 50,
    ),
    initialContext: {'appVersion': '1.0.0', 'build': 1, 'env': 'dev'},
    appRunner: () => runApp(const Screen()),
  );
}

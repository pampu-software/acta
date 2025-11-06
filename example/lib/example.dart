import 'package:acta/acta.dart';
import 'package:example/custom_report.dart';
import 'package:example/screen.dart';
import 'package:flutter/material.dart';

void main() async {
  ActaJournal.initialize(
    reporters: [
      ReporterFactory.createReporter(ConsoleReporter()), // Non lazy Reporter
      ReporterFactory.createLazyReporter(() => CustomReport()), //Lazy Reporter
    ],
    options: const HandlerOptions(
      catchAsyncErrors:
          true, //Create new ZoneGuarded inside!!! be awere, if needed, of Lazy creation
      logFlutterErrors: true,
      logPlatformErrors: true,
      minSeverity: Severity.info,
      maxBreadcrumbs: 50,
    ),
    initialContext: {'appVersion': '1.0.0', 'build': 1, 'env': 'dev'},
    beforeSend: (report) => report,
    appRunner: () => oldMain(),
  );
}

void oldMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Screen());
}

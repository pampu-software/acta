import 'package:acta/acta.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ActaJournal.initialize(
    reporters: [
      ConsoleReporter(),
    ],
    options: const HandlerOptions(
      catchAsyncErrors: true,
      logFlutterErrors: true,
      logPlatformErrors: true,
      minSeverity: Severity.info,
      maxBreadcrumbs: 50,
    ),
    initialContext: {'appVersion': '1.0.0', 'build': 1, 'env': 'dev'},
    beforeSend: (report) {
      return report;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Test demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ActaJournal.addBreadcrumb('Pressed INFO');
                  ActaJournal.report(
                    event: BaseEvent(
                      message: 'User pressed info',
                      severity: Severity.info,
                      metadata: {'screen': 'home'},
                    ),
                  );
                },
                child: const Text('Log info'),
              ),
              ElevatedButton(
                onPressed: () {
                  ActaJournal.addBreadcrumb('Pressed ERROR');
                  throw Exception('Boom!');
                },
                child: const Text('Throw error'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

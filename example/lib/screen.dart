import 'package:acta/acta.dart';
import 'package:flutter/material.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

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

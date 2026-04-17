import 'package:flutter_test/flutter_test.dart';
import 'package:acta/acta.dart';

class MockIntegration implements ActaIntegration {
  bool integrationCalled = false;
  @override
  void call() {
    integrationCalled = true;
  }
}

class MockReporter implements Reporter {
  bool reported = false;
  @override
  Future<void> report(Event event) async {
    reported = true;
  }
}

void main() {
  test('ActaJournal initializes with integrations', () {
    final mockIntegration = MockIntegration();

    ActaJournal.initialize(
      appRunner: () {},
      reporters: [],
      integrations: [mockIntegration],
    );

    expect(mockIntegration.integrationCalled, isTrue);
  });

  test('ActaJournal reports events to reporters', () async {
    final mockReporter = MockReporter();

    ActaJournal.initialize(
      appRunner: () {},
      reporters: [ReporterFactory.createReporter(mockReporter)],
    );

    await ActaJournal.report(event: BaseEvent(message: 'test'));

    expect(mockReporter.reported, isTrue);
  });
}

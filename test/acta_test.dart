import 'package:acta/acta.dart';
import 'package:flutter_test/flutter_test.dart';

class MockReporter implements Reporter {
  final List<Event> reportedEvents = [];

  @override
  Future<void> report(Event event) async {
    reportedEvents.add(event);
  }
}

void main() {
  group('ActaJournal Severity Filtering', () {
    late MockReporter mockReporter;

    setUp(() {
      mockReporter = MockReporter();
      ActaJournal.initialize(
        appRunner: () {},
        reporters: [ReporterFactory.createReporter(mockReporter)],
        options: const HandlerOptions(minSeverity: Severity.info),
      );
    });

    test('should report event when severity is equal to minSeverity', () async {
      final event = BaseEvent(message: 'Info message', severity: Severity.info);
      await ActaJournal.report(event: event);
      expect(mockReporter.reportedEvents.length, 1);
      expect((mockReporter.reportedEvents.first as BaseEvent).message, 'Info message');
    });

    test('should report event when severity is higher than minSeverity', () async {
      final event = BaseEvent(message: 'Warning message', severity: Severity.warning);
      await ActaJournal.report(event: event);
      expect(mockReporter.reportedEvents.length, 1);
      expect((mockReporter.reportedEvents.first as BaseEvent).message, 'Warning message');
    });

    test('should NOT report event when severity is lower than minSeverity', () async {
      final event = BaseEvent(message: 'Debug message', severity: Severity.debug);
      await ActaJournal.report(event: event);
      expect(mockReporter.reportedEvents.length, 0);
    });

    test('should work with custom extended severity', () async {
      const customSeverity = Severity('custom', 250);

      // minSeverity is info (200), so custom (250) should be reported
      final event = BaseEvent(message: 'Custom message', severity: customSeverity);
      await ActaJournal.report(event: event);
      expect(mockReporter.reportedEvents.length, 1);

      // Update ActaJournal with higher minSeverity
      ActaJournal.initialize(
        appRunner: () {},
        reporters: [ReporterFactory.createReporter(mockReporter)],
        options: const HandlerOptions(minSeverity: Severity.warning), // 300
      );

      mockReporter.reportedEvents.clear();
      await ActaJournal.report(event: event);
      expect(mockReporter.reportedEvents.length, 0);
    });
   group('Severity Comparison', () {
      test('operators work correctly', () {
        expect(Severity.info > Severity.debug, isTrue);
        expect(Severity.warning >= Severity.info, isTrue);
        expect(Severity.info < Severity.warning, isTrue);
        expect(Severity.critical <= Severity.fatal, isTrue);
        expect(Severity.error == Severity.error, isTrue);
        expect(Severity.info == const Severity('info', 200), isTrue);
      });

      test('custom severity comparison', () {
        const custom = Severity('custom', 250);
        expect(custom > Severity.info, isTrue);
        expect(custom < Severity.warning, isTrue);
      });
    });

    group('SeverityMapper', () {
      test('fromMap works for standard severities', () {
        expect(SeverityMapper.fromMap('info'), Severity.info);
        expect(SeverityMapper.fromMap('critical'), Severity.critical);
      });

      test('fromMap returns custom severity for unknown values', () {
        final custom = SeverityMapper.fromMap('unknown');
        expect(custom.name, 'unknown');
        expect(custom.level, 0);
      });
    });
  });
}

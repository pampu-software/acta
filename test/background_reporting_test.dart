import 'package:acta/acta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

class MockReporter extends Reporter {
  final List<Event> events = [];
  bool shouldDelay = false;

  @override
  Future<void> report(Event event) async {
    if (shouldDelay) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    events.add(event);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ActaJournal Background Reporting', () {
    late MockReporter mockReporter;

    setUp(() {
      mockReporter = MockReporter();
      ActaJournal.reset();
      ActaJournal.initialize(
        appRunner: () {},
        reporters: [ReporterFactory.createReporter(mockReporter)],
        options: const HandlerOptions(
          minSeverity: Severity.info,
        ),
      );
    });

    test('should report event in background', () async {
      final event = BaseEvent(message: 'test event');
      await ActaJournal.report(event: event);

      expect(mockReporter.events.length, 1);
      expect(mockReporter.events.first.getContentToString(), contains('test event'));
    });

    test('should preserve state at time of report', () async {
      ActaJournal.setContext({'key': 'initial'});
      ActaJournal.addBreadcrumb('bc1');

      final event = BaseEvent(message: 'event 1');
      final reportFuture = ActaJournal.report(event: event);

      // Change state immediately after calling report
      ActaJournal.setContext({'key': 'changed'});
      ActaJournal.addBreadcrumb('bc2');

      await reportFuture;

      expect(mockReporter.events.length, 1);
      final capturedEvent = mockReporter.events.first;
      expect(capturedEvent.metadata?['key'], 'initial');
      expect(capturedEvent.breadcrumbs?.any((bc) => bc['message'] == 'bc1'), isTrue);
      expect(capturedEvent.breadcrumbs?.any((bc) => bc['message'] == 'bc2'), isFalse);
    });

    test('flush should wait for all pending events', () async {
      mockReporter.shouldDelay = true;

      ActaJournal.report(event: BaseEvent(message: 'e1'));
      ActaJournal.report(event: BaseEvent(message: 'e2'));
      ActaJournal.report(event: BaseEvent(message: 'e3'));

      expect(mockReporter.events.length, lessThan(3));

      await ActaJournal.flush();

      expect(mockReporter.events.length, 3);
    });

    test('should handle beforeSend hook in background', () async {
      final localMock = MockReporter();
      ActaJournal.reset();
      ActaJournal.initialize(
        appRunner: () {},
        reporters: [ReporterFactory.createReporter(localMock)],
        beforeSend: (event) {
          if (event is BaseEvent && event.message == 'drop me') {
            return null;
          }
          return event;
        },
      );

      await ActaJournal.report(event: BaseEvent(message: 'keep me'));
      await ActaJournal.report(event: BaseEvent(message: 'drop me'));
      await ActaJournal.flush();

      expect(localMock.events.length, 1);
      expect((localMock.events.first as BaseEvent).message, 'keep me');
    });
  });
}

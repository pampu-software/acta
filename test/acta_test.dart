import 'package:acta/acta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event Refactoring Tests', () {
    test('Event shouldReport correctly filters based on severity weight', () {
      final event = BaseEvent(message: 'test', severity: Severity.warning);

      expect(event.shouldReport(Severity.debug), isTrue);
      expect(event.shouldReport(Severity.info), isTrue);
      expect(event.shouldReport(Severity.warning), isTrue);
      expect(event.shouldReport(Severity.error), isFalse);
      expect(event.shouldReport(Severity.critical), isFalse);
      expect(event.shouldReport(Severity.fatal), isFalse);
    });

    test('Event toMap includes all base properties', () {
      final timestamp = DateTime.now();
      final event = BaseEvent(
        message: 'test message',
        severity: Severity.critical,
        tag: 'test-tag',
        metadata: {'key': 'value'},
        breadcrumbs: [
          {'message': 'crumb'}
        ],
        timestamp: timestamp,
      )..calculateFingerprint();

      final map = event.toMap();

      expect(map['message'], 'test message');
      expect(map['severity'], 'critical');
      expect(map['tag'], 'test-tag');
      expect(map['metadata'], {'key': 'value'});
      expect(map['breadcrumbs'], [
        {'message': 'crumb'}
      ]);
      expect(map['timestamp'], timestamp.millisecondsSinceEpoch);
      expect(map['fingerPrint'], isNotNull);
    });

    test('ErrorEvent toMap includes base and error properties', () {
      final exception = Exception('fail');
      final stackTrace = StackTrace.current;
      final event = ErrorEvent(
        message: 'error message',
        exception: exception,
        stackTrace: stackTrace,
      )..calculateFingerprint();

      final map = event.toMap();

      expect(map['message'], 'error message');
      expect(map['severity'], 'error'); // Default for ErrorEvent
      expect(map['exception'], exception.toString());
      expect(map['stackTrace'], stackTrace.toString());
      expect(map['fingerPrint'], isNotNull);
    });
  });

  group('Severity Tests', () {
    test('Severity weights are correctly ordered', () {
      expect(Severity.debug.weight, lessThan(Severity.info.weight));
      expect(Severity.info.weight, lessThan(Severity.warning.weight));
      expect(Severity.warning.weight, lessThan(Severity.error.weight));
      expect(Severity.error.weight, lessThan(Severity.critical.weight));
      expect(Severity.critical.weight, lessThan(Severity.fatal.weight));
    });

    test('SeverityMapper maps correctly', () {
      expect(Severity.debug.toMap(), 'debug');
      expect(SeverityMapper.fromMap('critical'), Severity.critical);
    });
  });
}

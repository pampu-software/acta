import 'package:acta/acta.dart';
import 'package:acta/src/reporters/reporter.dart';

class ReporterFactory {
  Reporter? _cached;
  final Reporter Function() _factory;

  ReporterFactory.createReporter(Reporter reporter)
    : _cached = reporter,
      _factory = (() => reporter);

  ReporterFactory.createLazyReporter(Reporter Function() factory)
    : _factory = factory;

  Reporter get instance => _cached ??= _factory();
}

import 'package:acta/acta.dart';

abstract interface class SeverityAware {
  Severity get severity;
}

abstract interface class Taggable {
  String? get tag;
}

abstract interface class Fingerprintable {
  void calculateFingerprint();
}

extension PreloadExtensions on Event {
  void preloadEvent() {
    if (this is Fingerprintable) {
      (this as Fingerprintable).calculateFingerprint();
    }
  }
}

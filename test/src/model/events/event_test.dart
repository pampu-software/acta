import 'package:acta/acta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('event ...', () {
    final event = BaseEvent(message: 'message')..calculateFingerprint();
    var schema = event.toJson();
    print(schema);
  });
}

// {
//     "message": "message",
//     "fingerPrint": "message|info|",
//     "severity": "info",
//     "tag": null,
//     "metadata": null,
//     "breadcrumbs": [],
//     "timestamp": 1758589162974
// }

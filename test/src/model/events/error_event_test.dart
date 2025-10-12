import 'package:acta/src/model/events/error_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('event ...', () {
    final event = ErrorEvent(message: 'message')..calculateFingerprint();
    var schema = event.toJson();
    print(schema);
  });
}
// {
//     "message": "message",
//     "fingerPrint": "1983520455",
//     "severity": "info",
//     "tag": null,
//     "metadata": null,
//     "breadcrumbs": [],
//     "timestamp": 1758589262778,
//     "exception": "null",
//     "stackTrace": "null"
// }
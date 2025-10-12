// import 'package:acta/acta.dart';
// import 'package:hive/hive.dart';

// /// Replays locally stored logs to an uploader reporter, then clears the box.
// class LogFlusher {
//   final Box box;
//   final Reporter uploader;

//   LogFlusher({required this.box, required this.uploader});

//   Future<void> flush() async {
//     final items = box.values.toList().cast<Map>();
//     for (final m in items) {
//       final report = Event.fromMap(m as Map<String, dynamic>);
//       await uploader.report(report);
//     }
//     await box.clear();
//   }
// }

//TODO FUTURE

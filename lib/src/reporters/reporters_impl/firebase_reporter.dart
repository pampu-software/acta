// // Import this file explicitly ONLY if you add firebase_crashlytics to your app.
// import 'package:acta/acta.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// class FirebaseReporter implements Reporter {
//   final FirebaseCrashlytics crashlytics;
//   FirebaseReporter({FirebaseCrashlytics? instance})
//     : crashlytics = instance ?? FirebaseCrashlytics.instance;

//   @override
//   Future<void> report(Event r) async {
//     // attach useful keys
//     await crashlytics.setCustomKey('level', r.severity.name);
//     await crashlytics.setCustomKey('timestamp', r.timestamp.toIso8601String());
//     if (r.metadata != null) {
//       for (final entry in r.metadata!.entries) {
//         final v = entry.value;
//         // Crashlytics supports primitives and strings
//         if (v is num || v is bool || v is String) {
//           await crashlytics.setCustomKey(entry.key, v);
//         } else {
//           await crashlytics.setCustomKey(entry.key, v.toString());
//         }
//       }
//     }
//     if (r.breadcrumbs.isNotEmpty) {
//       await crashlytics.log('breadcrumbs: ${r.breadcrumbs}');
//     }

//     if (r.stackTrace != null) {
//       await crashlytics.recordError(
//         r.message,
//         r.stackTrace,
//         fatal: r.severity == Severity.critical,
//       );
//     } else {
//       // No stack: still record as a log
//       await crashlytics.log(r.message.toString());
//     }
//   }
// }

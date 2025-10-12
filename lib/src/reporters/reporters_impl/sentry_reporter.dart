// // Import this file explicitly ONLY if you add sentry_flutter to your app.
// import 'package:acta/acta.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

// class SentryCrashReporter implements Reporter {
//   SentryCrashReporter();

//   SentryLevel _mapLevel(Severity l) {
//     switch (l) {
//       // case Severity.debug:
//       //   return SentryLevel.debug;
//       case Severity.info:
//         return SentryLevel.info;
//       case Severity.warning:
//         return SentryLevel.warning;
//       // case Severity.error:
//       //   return SentryLevel.error;
//       // case Severity.fatal:
//       //   return SentryLevel.fatal;
//       default:
//         return SentryLevel.error;
//     }
//   }

//   @override
//   Future<void> report(Event r) async {
//     final hint = Hint.withMap({
//       'timestamp': r.timestamp.toIso8601String(),
//       'meta': r.metadata,
//       'breadcrumbs': r.breadcrumbs,
//     });

//     await Sentry.captureException(
//       r.message,
//       stackTrace: r.stackTrace,
//       withScope: (scope) {
//         scope.level = _mapLevel(r.severity);
//         if (r.metadata != null) {
//           for (final e in r.metadata!.entries) {
//             final v = e.value;
//             scope.setExtra(e.key, v);
//           }
//         }
//         if (r.breadcrumbs.isNotEmpty) {
//           for (final bc in r.breadcrumbs) {
//             scope.addBreadcrumb(
//               Breadcrumb(
//                 message: (bc['message'] ?? bc.toString()).toString(),
//                 data: Map<String, dynamic>.from(bc),
//                 timestamp: DateTime.tryParse(
//                   (bc['timestamp'] ?? '').toString(),
//                 ),
//               ),
//             );
//           }
//         }
//       },
//       hint: hint,
//     );
//   }
// }

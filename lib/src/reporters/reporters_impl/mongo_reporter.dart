import 'package:acta/acta.dart';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Reporter that sends events to a MongoDB database.
///
/// Useful for centralized storage, querying, and analytics.
/// Configure with your MongoDB connection details as needed.
class MongoReporter implements Reporter {
  /// [connectionString] represent the connection URL to the MongoDB instance.
  final String connectionString;

  /// [dbName] represent the database name in MongoDB where events will be stored.
  final String dbName;

  /// [collection] represent the collection in MongoDB where events will be stored.
  final String collection;

  // final bool compactMode;

  MongoReporter({
    required this.connectionString,
    required this.dbName,
    required this.collection,
    // this.compactMode = false,
  });

  Future<Db> _connect() async {
    final db = Db(connectionString);
    await db.open();
    return db;
  }

  // @override
  // Future<void> report(Event event) async {
  //   try {
  //     final db = await _connect();
  //     final coll = db.collection(collection);
  //     WriteResult result;
  //     if (compactMode) {
  //       result = await coll.updateOne(
  //         where.eq('fingerPrint', event.fingerPrint),
  //         ModifierBuilder()
  //             // These modifiers apply on both insert and update
  //             .set('lastSeen', event.timestamp.toIso8601String())
  //             // Corrected: $inc handles both new documents and existing ones
  //             .inc('occurrences', 1)
  //             .push('breadcrumbs', {r'$each': event.breadcrumbs})
  //             // These modifiers apply ONLY on insert
  //             .setOnInsert('fingerPrint', event.fingerPrint)
  //             .setOnInsert('message', event.message)
  //             .setOnInsert('severity', event.severity.toString())
  //             .setOnInsert('timestamp', event.timestamp.toIso8601String())
  //             .setOnInsert('exception', event.exception?.toString())
  //             .setOnInsert('stackTrace', event.stackTrace?.toString())
  //             .setOnInsert('metadata', event.metadata)
  //             .setOnInsert('tag', event.tag),
  //         upsert: true,
  //       );
  //     } else {
  //       // Raw insert: histórico completo
  //       result = await coll.insertOne({
  //         'message': event.message,
  //         'severity': event.severity.toString(),
  //         'timestamp': event.timestamp.toIso8601String(),
  //         'exception': event.exception?.toString(),
  //         'stackTrace': event.stackTrace?.toString(),
  //         'metadata': event.metadata,
  //         'breadcrumbs': event.breadcrumbs,
  //         'fingerPrint': event.fingerPrint,
  //         'tag': event.tag,
  //       });
  //     }
  //     await db.close();
  //     debugPrint('Evento salvo no MongoDB: ${event.message}');
  //     // return result;
  //   } catch (e, s) {
  //     debugPrint('Erro ao salvar no MongoDB: $e\n$s');
  //     // return null;
  //   }
  // }

  /// Reports the [Event] to MongoDB.
  ///
  /// Converts the event to JSON and inserts it into the configured collection.
  @override
  Future<void> report(Event event) async {
    try {
      final db = await _connect();
      final coll = db.collection(collection);
      await coll.insertOne(event.toMap());

      await db.close();
      // debugPrint('Evento salvo no MongoDB: ${event.toString()}');
      // return result;
    } catch (e, s) {
      debugPrint('Erro ao salvar no MongoDB: $e\n$s');
      // return null;
    }
  }
}

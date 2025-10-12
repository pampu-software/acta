import 'package:acta/acta.dart';

import 'package:http/http.dart' as http;

/// Reporter that sends events to an Elasticsearch backend.
///
/// Useful for centralized logging, search, and analytics.
/// Configure with your Elasticsearch endpoint and credentials as needed.
class ElasticsearchReporter implements Reporter {
  /// [connectionString] represent the connection URL to the Elasticsearch instance.
  final String connectionString;

  /// [idnexPattern] represent the index in Elasticsearch where events will be stored.
  final String indexPattern;

  ElasticsearchReporter({
    required this.connectionString,
    required this.indexPattern,
  });

  /// Reports the [Event] to Elasticsearch.
  ///
  /// Converts the event to JSON and sends it to the configured Elasticsearch index.
  @override
  Future<void> report(Event event) async {
    final url = Uri.parse(
      "$connectionString/$indexPattern/_doc/", // "http://localhost:9200/events/_doc",
    ); // index = events
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: event.toJson(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("Saved to Elasticsearch: ${response.body}");
    } else {
      print("Failed to save: ${response.statusCode} ${response.body}");
    }
  }
}

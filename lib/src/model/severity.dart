/// Represents the severity level of an event or error.
///
/// - [info]: Informational message, not an error.
/// - [warning]: Indicates a potential issue or non-critical error.
/// - [critical]: Serious error requiring immediate attention.
enum Severity { info, warning, critical }
// TODO Feature Improvment { debug, info, warning, error, fatal }

/// Extension for mapping [Severity] to and from string values.
extension SeverityMapper on Severity {
  /// Converts the [Severity] to its string representation.
  String toMap() {
    return toString().split('.').last;
  }

  /// Parses a string value to its corresponding [Severity] enum.
  static Severity fromMap(String value) {
    return Severity.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  }
}

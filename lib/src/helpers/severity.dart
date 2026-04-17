/// Represents the severity level of an event or error.
///
/// - [debug]: Least severe, for debugging.
/// - [info]: Informational message, not an error.
/// - [warning]: Indicates a potential issue or non-critical error.
/// - [error]: Indicates an error that should be looked at.
/// - [critical]: Serious error requiring immediate attention.
/// - [fatal]: Most severe, usually causes termination.
enum Severity { debug, info, warning, error, critical, fatal }

/// Extension for mapping [Severity] to and from string values.
extension SeverityMapper on Severity {
  /// Converts the [Severity] to its string representation.
  String toMap() {
    return name;
  }

  /// Returns the weight of the severity for comparison.
  int get weight {
    switch (this) {
      case Severity.debug:
        return 100;
      case Severity.info:
        return 200;
      case Severity.warning:
        return 300;
      case Severity.error:
        return 400;
      case Severity.critical:
        return 500;
      case Severity.fatal:
        return 600;
    }
  }

  /// Parses a string value to its corresponding [Severity] enum.
  static Severity fromMap(String value) {
    return Severity.values.firstWhere(
      (e) => e.name == value,
    );
  }
}

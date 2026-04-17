/// Represents the severity level of an event or error.
///
/// - [debug]: Useful for debugging information.
/// - [info]: Informational message, not an error.
/// - [warning]: Indicates a potential issue or non-critical error.
/// - [error]: Indicates a critical error.
/// - [critical]: Serious error requiring immediate attention.
/// - [fatal]: Application-breaking error.
class Severity implements Comparable<Severity> {
  final String name;
  final int level;

  const Severity(this.name, this.level);

  static const debug = Severity('debug', 100);
  static const info = Severity('info', 200);
  static const warning = Severity('warning', 300);
  static const error = Severity('error', 400);
  static const critical = Severity('critical', 500);
  static const fatal = Severity('fatal', 600);

  static const List<Severity> values = [
    debug,
    info,
    warning,
    error,
    critical,
    fatal,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Severity && name == other.name && level == other.level;

  @override
  int get hashCode => name.hashCode ^ level.hashCode;

  bool operator <(Severity other) => level < other.level;
  bool operator <=(Severity other) => level <= other.level;
  bool operator >(Severity other) => level > other.level;
  bool operator >=(Severity other) => level >= other.level;

  @override
  int compareTo(Severity other) => level.compareTo(other.level);

  @override
  String toString() => name;
}

/// Extension for mapping [Severity] to and from string values.
extension SeverityMapper on Severity {
  /// Converts the [Severity] to its string representation.
  String toMap() {
    return name;
  }

  /// Parses a string value to its corresponding [Severity] enum.
  static Severity fromMap(String value) {
    return Severity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Severity(value, 0),
    );
  }
}

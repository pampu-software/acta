import 'dart:async';

/// An integration for the Acta library.
///
/// Integrations are used to extend the functionality of the [ActaJournal],
/// such as capturing errors from the Flutter framework or from other packages.
abstract interface class ActaIntegration {
  /// Initializes the integration.
  FutureOr<void> call();
}

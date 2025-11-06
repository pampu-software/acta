import 'dart:async';

import 'package:acta/acta.dart';

/// Signature for a hook that runs before an [Event] is sent.
/// Can modify, filter, or drop the event by returning a new event or null.
/// If null is returned, the event will not be sent.
typedef BeforeSend = FutureOr<Event?> Function(Event event);

/// Callback triggered when an event is captured.
/// Receives the captured [Event], or null if none.
typedef OnCaptured = void Function(Event? event);

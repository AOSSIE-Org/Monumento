import 'dart:async';

import 'package:flutter/foundation.dart';

/// A utility class for debouncing actions in Dart and Flutter applications.
class Debouncer {
  /// Creates a new Debouncer with the specified [delay].
  ///
  /// The [delay] defines the duration for which to delay the execution of
  /// the provided action after the last call to the `run` method. It is
  /// required and must be a non-null [Duration].
  Debouncer({this.delay});

  /// The delay duration for debouncing.
  Duration? delay;

  /// The callback action to be executed after the debounce delay.
  VoidCallback? _action;

  /// The timer used to manage the delay.
  Timer? _timer;

  /// Runs the provided [action] after a delay defined by [delay].
  ///
  /// If this method is called while a previous timer is active, it cancels
  /// the previous timer and starts a new one, effectively resetting the
  /// delay period.
  ///
  /// - [action]: The callback function to be executed after the delay.
  void run(VoidCallback action) {
    _action = action;
    _timer?.cancel();
    if (delay != null) {
      _timer = Timer(delay!, () {
        // Check if the action is not null before executing it.
        if (_action != null) {
          _action!();
        }
      });
    }
  }

  /// Cancels any active timer and clears the currently scheduled action.
  ///
  /// This can be used to prevent the scheduled action from executing if it
  /// is no longer needed.
  void cancel() {
    _timer?.cancel();
    _action = null;
  }
}

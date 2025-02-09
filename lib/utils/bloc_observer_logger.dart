import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

/// A logger for observing and logging state changes and activities in Blocs/Cubits.
class BlocObserverLogger extends BlocObserver {
  /// Logs every change in the state of any Bloc/Cubit.
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('onChange: ${bloc.runtimeType}, Prev State: ${change.currentState}, Next State: ${change.nextState}');
  }

  /// Logs when a Bloc/Cubit is closed.
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('onClose: ${bloc.runtimeType}');
  }

  /// Logs when a Bloc/Cubit is created.
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('onCreate: ${bloc.runtimeType}');
  }

  /// Logs events added to the Bloc.
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log('onEvent: ${bloc.runtimeType}, Event: $event');
  }

  /// Logs errors caught in the Bloc/Cubit.
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('onError: ${bloc.runtimeType}, Error: $error');
  }

  /// Logs state transitions in the Bloc.
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('onTransition: ${bloc.runtimeType}, Transition: $transition');
  }
}

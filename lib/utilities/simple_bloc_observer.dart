import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print("$event BLOC");
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print("$transition BLOC");
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print("$error BLOC");
    super.onError(bloc, error, stackTrace);
  }
}

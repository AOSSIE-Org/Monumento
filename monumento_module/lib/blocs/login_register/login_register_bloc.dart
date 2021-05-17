import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/resources/authentication/authentication_repository.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';

part 'login_register_event.dart';

part 'login_register_state.dart';

class LoginRegisterBloc extends Bloc<LoginRegisterEvent, LoginRegisterState> {
  final AuthenticationRepository _authRepository;
  final AuthenticationBloc _authenticationBloc;

  LoginRegisterBloc(
      {@required AuthenticationRepository authenticationRepository,
      @required AuthenticationBloc authenticationBloc})
      : assert(authenticationRepository != null),
        assert(authenticationBloc != null),
        _authenticationBloc = authenticationBloc,
        _authRepository = authenticationRepository,
        super(LoginRegisterInitial());

  @override
  Stream<LoginRegisterState> mapEventToState(
    LoginRegisterEvent event,
  ) async* {
    if (event is LoginWithEmailPressed) {
      yield* _mapLoginWithEmailPressedToState(
          email: event.email, password: event.password);
    } else if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LogOutPressed) {
      yield* _mapLogoutPressedToState();
    } else if (event is SignUpWithEmailPressed) {
      yield* _mapSignUpWithEmailPressedToState(
          email: event.email, password: event.password,name: event.name, status: event.status);
    }
  }

  Stream<LoginRegisterState> _mapLoginWithGooglePressedToState() async* {
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        _authenticationBloc.add(LoggedIn());
        yield LoginSuccess(UserModel.fromEntity(user));
      } else {
        yield LoginFailed();
      }
    } catch (_) {
      yield LoginFailed();
    }
  }

  Stream<LoginRegisterState> _mapLoginWithEmailPressedToState(
      {@required String email, @required String password}) async* {
    try {
      final user =
          await _authRepository.emailSignIn(email: email, password: password);
      if (user != null) {
        yield LoginSuccess(UserModel.fromEntity(user));
      } else {
        yield LoginFailed();
      }
    } catch (_) {
      yield LoginFailed();
    }
  }

  Stream<LoginRegisterState> _mapLogoutPressedToState() async* {
    await _authRepository.signOut();
    _authenticationBloc.add(LoggedOut());
    yield LogOutSuccess();
  }

  Stream<LoginRegisterState> _mapSignUpWithEmailPressedToState(
      {@required String email, @required String password, @required name, @required status}) async* {
    try {
      final user = await _authRepository.signUp(email: email, name: name, password: password, status: status );
      if (user != null) {
        yield SignUpSuccess(UserModel.fromEntity(user));
      } else {
        yield SignUpFailed();
      }
    } catch (_) {
      yield SignUpFailed();
    }
  }
}

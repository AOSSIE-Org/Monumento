import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';

part 'login_register_event.dart';
part 'login_register_state.dart';

class LoginRegisterBloc extends Bloc<LoginRegisterEvent, LoginRegisterState> {
  final AuthenticationRepository _authRepository;
  final AuthenticationBloc _authenticationBloc;

  LoginRegisterBloc(this._authRepository, this._authenticationBloc)
      : super(LoginRegisterInitial()) {
    on<LoginWithEmailPressed>(_mapLoginWithEmailPressedToState);
    on<LogOutEvent>(_mapLogoutEventToState);
    on<LoginWithGooglePressed>(_mapLoginWithGooglePressedToState);
    on<SignUpWithEmailPressed>(_mapSignUpWithEmailPressedToState);
  }

  _mapLoginWithEmailPressedToState(
      LoginWithEmailPressed event, Emitter<LoginRegisterState> emit) async {
    try {
      emit(LoginRegisterLoading());

      final user = await _authRepository.emailSignIn(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        _authenticationBloc.add(LoggedIn());
        print('User: $user');
        emit(LoginSuccess(user));
      } else {
        emit(const LoginFailed(message: 'Failed to login'));
      }
    } catch (e) {
      emit(LoginFailed(message: e.toString()));
    }
  }

  _mapLogoutEventToState(
      LoginRegisterEvent event, Emitter<LoginRegisterState> emit) async* {
    await _authRepository.signOut();
    _authenticationBloc.add(LoggedOut());
    emit(LogOutSuccess());
  }

  Stream<LoginRegisterState> _mapLoginWithGooglePressedToState(
      LoginRegisterEvent event, Emitter<LoginRegisterState> emit) async* {
    try {
      yield LoginRegisterLoading();

      final map = await _authRepository.signInWithGoogle();
      // _authenticationBloc.add(LoggedIn());

      if (map['isNewUser'] as bool) {
        yield SigninWithGoogleSuccess(
            isNewUser: map['isNewUser'] as bool,
            user: map['user'] as UserModel);
      } else {
        UserModel? user = await _authRepository.getUser();
        if (user == null) {
          emit(const LoginFailed(message: 'Failed to login'));
        } else {
          _authenticationBloc.add(LoggedIn());
          emit(SigninWithGoogleSuccess(isNewUser: false, user: user));
        }
      }
    } catch (e) {
      yield LoginFailed(message: e.toString());
    }
  }

  _mapSignUpWithEmailPressedToState(
      SignUpWithEmailPressed event, Emitter<LoginRegisterState> emit) async {
    // TODO: implement
  }
}

import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:monumento/utils/constants.dart';

part 'login_register_event.dart';
part 'login_register_state.dart';

class LoginRegisterBloc extends Bloc<LoginRegisterEvent, LoginRegisterState> {
  final AuthenticationRepository _authRepository;
  final SocialRepository _socialRepository;
  final AuthenticationBloc _authenticationBloc;

  LoginRegisterBloc(
      this._authRepository, this._socialRepository, this._authenticationBloc)
      : super(LoginRegisterInitial()) {
    on<LoginWithEmailPressed>(_mapLoginWithEmailPressedToState);
    on<LogOutEvent>(_mapLogoutEventToState);
    on<LoginWithGooglePressed>(_mapLoginWithGooglePressedToState);
    on<SignUpWithEmailPressed>(_mapSignUpWithEmailPressedToState);
    on<ResetPasswordButtonPressed>(_mapResetPasswordButtonPressedToState);
    on<SaveOnboardingDetails>(_mapSaveOnboardingDetailsToState);
  }

  _mapSaveOnboardingDetailsToState(
      SaveOnboardingDetails event, Emitter<LoginRegisterState> emit) async {
    try {
      emit(LoginRegisterLoading());
      bool isUserNameAvailable = await _socialRepository
          .checkUserNameAvailability(username: event.username);
      if (isUserNameAvailable) {
        String url;

        if (event.profilePictureFile != null) {
          url = await _socialRepository.uploadProfilePicForUrl(
              fileBytes: event.profilePictureFile!);
        } else {
          url = defaultProfilePicture;
        }
        final uid = await _authRepository.getUid();
        final email = await _authRepository.getEmail();
        final user = await _authRepository.getOrCreateUserDocForGoogleSignIn(
          uid: uid,
          name: event.name,
          email: email,
          status: event.status,
          username: event.username,
          profilePictureUrl: url,
        );
        emit(SignUpSuccess(user));
        _authenticationBloc.add(LoggedIn());
      } else {
        emit(const SignUpFailed(
            message: 'Username already taken, please try with another one.'));
      }
    } catch (e) {
      emit(SignUpFailed(message: e.toString()));
    }
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
        log('User: $user');
        emit(LoginSuccess(user));
      } else {
        emit(const LoginFailed(message: 'Failed to login'));
      }
    } catch (e) {
      emit(LoginFailed(message: e.toString()));
    }
  }

  _mapLogoutEventToState(
      LoginRegisterEvent event, Emitter<LoginRegisterState> emit) async {
    await _authRepository.signOut();
    _authenticationBloc.add(LoggedOut());
    emit(const LogOutSuccess());
  }

  _mapLoginWithGooglePressedToState(
      LoginRegisterEvent event, Emitter<LoginRegisterState> emit) async {
    try {
      emit(LoginRegisterLoading());

      final map = await _authRepository.signInWithGoogle();
      _authenticationBloc.add(LoggedIn());

      if (map['isNewUser'] as bool) {
        _authenticationBloc.add(LoggedInWithInCompleteOnboarding());
        emit(SigninWithGoogleSuccess(
            isNewUser: map['isNewUser'] as bool,
            user: map['user'] as UserModel));
      } else {
        UserModel? user = map['user'] as UserModel;

        _authenticationBloc.add(LoggedIn());
        emit(SigninWithGoogleSuccess(isNewUser: false, user: user));
      }
    } catch (e) {
      emit(SigninWithGoogleFailed(message: e.toString()));
    }
  }

  _mapSignUpWithEmailPressedToState(
      SignUpWithEmailPressed event, Emitter<LoginRegisterState> emit) async {
    try {
      emit(LoginRegisterLoading());
      bool isUserNameAvailable = await _socialRepository
          .checkUserNameAvailability(username: event.username);
      if (isUserNameAvailable) {
        String url;

        if (event.profilePictureFile != null) {
          url = await _socialRepository.uploadProfilePicForUrl(
              fileBytes: event.profilePictureFile!);
        } else {
          url = defaultProfilePicture;
        }
        final user = await _authRepository.signUp(
            email: event.email,
            name: event.name,
            password: event.password,
            status: event.status,
            username: event.username,
            profilePictureUrl: url);
        if (user != null) {
          emit(SignUpSuccess(user));
          _authenticationBloc.add(LoggedIn());
        } else {
          emit(const SignUpFailed(message: 'Failed to sign up'));
        }
      } else {
        emit(const SignUpFailed(
            message: 'Username already taken, please try with another one.'));
      }
    } catch (e) {
      emit(SignUpFailed(message: e.toString()));
    }
  }

  _mapResetPasswordButtonPressedToState(ResetPasswordButtonPressed event,
      Emitter<LoginRegisterState> emit) async {
    try {
      emit(LoginRegisterLoading());
      await _authRepository.sendPasswordResetEmail(email: event.email);
      emit(ResetPasswordSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        emit(const ResetPasswordFailed(
            message:
                'The email provided is invalid. Please try again with a valid email.'));
      } else if (e.code == 'user-not-found') {
        emit(const ResetPasswordFailed(
            message:
                'No user found with this email. Please sign up or check the email you entered.'));
      } else {
        emit(const ResetPasswordFailed(message: 'Something went wrong'));
      }
    } catch (e) {
      emit(ResetPasswordFailed(message: e.toString()));
    }
  }
}

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/resources/authentication/authentication_repository.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:monumento/utilities/constants.dart';

part 'login_register_event.dart';
part 'login_register_state.dart';

class LoginRegisterBloc extends Bloc<LoginRegisterEvent, LoginRegisterState> {
  final AuthenticationRepository _authRepository;
  final SocialRepository _socialRepository;
  final AuthenticationBloc _authenticationBloc;

  LoginRegisterBloc(
      {@required AuthenticationRepository authenticationRepository,
      @required AuthenticationBloc authenticationBloc,
      @required SocialRepository socialRepository})
      : assert(authenticationRepository != null),
        assert(authenticationBloc != null),
        assert(socialRepository != null),
        _authenticationBloc = authenticationBloc,
        _authRepository = authenticationRepository,
        _socialRepository = socialRepository,
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
    } else if (event is LogOutEvent) {
      yield* _mapLogoutEventToState();
    } else if (event is SignUpWithEmailPressed) {
      yield* _mapSignUpWithEmailPressedToState(
          profilePictureFile: event.profilePictureFile,
          email: event.email,
          password: event.password,
          name: event.name,
          status: event.status,
          username: event.username);
    }
  }

  Stream<LoginRegisterState> _mapLoginWithGooglePressedToState() async* {
    try {
      yield LoginRegisterLoading();

      final map = await _authRepository.signInWithGoogle();
      // _authenticationBloc.add(LoggedIn());

      if (map['isNewUser'] as bool) {
        yield SigninWithGoogleSuccess(
            isNewUser: map['isNewUser'] as bool,
            user: map['user'] as UserModel);
      } else {
        UserModel user = await _authRepository.getUser();
        _authenticationBloc.add(LoggedIn());

        yield SigninWithGoogleSuccess(isNewUser: false, user: user);
      }
    } catch (e) {
      yield LoginFailed(message: e.toString());
    }
  }

  Stream<LoginRegisterState> _mapLoginWithEmailPressedToState(
      {@required String email, @required String password}) async* {
    try {
      yield LoginRegisterLoading();

      final user =
          await _authRepository.emailSignIn(email: email, password: password);
      if (user != null) {
        _authenticationBloc.add(LoggedIn());
        yield LoginSuccess(user);
      } else {
        yield LoginFailed(message: 'Failed to Login');
      }
    } catch (e) {
      yield LoginFailed(message: e.toString());
    }
  }

  Stream<LoginRegisterState> _mapLogoutEventToState() async* {
    await _authRepository.signOut();
    _authenticationBloc.add(LoggedOut());
    yield LogOutSuccess();
  }

  Stream<LoginRegisterState> _mapSignUpWithEmailPressedToState(
      {@required String email,
      @required String password,
      @required String name,
      @required String status,
      @required String username,
      @required File profilePictureFile}) async* {
    try {
      yield LoginRegisterLoading();
      bool isUserNameAvailable =
          await _socialRepository.checkUserNameAvailability(username: username);
      if (isUserNameAvailable) {
        String url;

        if (profilePictureFile != null) {
          url = await _socialRepository.uploadProfilePicForUrl(
              file: profilePictureFile);
        } else {
          url = defaultProfilePicture;
        }
        final user = await _authRepository.signUp(
            email: email,
            name: name,
            password: password,
            status: status,
            username: username,
            profilePictureUrl: url);
        if (user != null) {
          yield SignUpSuccess(user);
          _authenticationBloc.add(LoggedIn());
        } else {
          yield SignUpFailed(message: 'Something went wrong');
        }
      } else {
        yield SignUpFailed(
            message: 'Username already used. Enter a different username');
      }
    } catch (e) {
      print(e);
      yield SignUpFailed(message: e.toString());
    }
  }
}

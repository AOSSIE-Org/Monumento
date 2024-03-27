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

part 'profile_form_event.dart';
part 'profile_form_state.dart';

class ProfileFormBloc extends Bloc<ProfileFormEvent, ProfileFormState> {
  final AuthenticationRepository _authRepository;
  final SocialRepository _socialRepository;
  final AuthenticationBloc _authenticationBloc;

  ProfileFormBloc(
      {@required AuthenticationRepository authenticationRepository,
      @required SocialRepository socialRepository,
      @required AuthenticationBloc authenticationBloc})
      : assert(authenticationRepository != null),
        assert(socialRepository != null),
        _authRepository = authenticationRepository,
        _socialRepository = socialRepository,
        _authenticationBloc = authenticationBloc,
        super(ProfileFormInitial());

  @override
  Stream<ProfileFormState> mapEventToState(
    ProfileFormEvent event,
  ) async* {
    if (event is CreateUserDoc) {
      yield* _mapCreateUserDocToState(
          name: event.name,
          username: event.username,
          profilePictureFile: event.profilePictureFile,
          email: event.email,
          status: event.status,
          uid: event.uid);
    }
  }

  Stream<ProfileFormState> _mapCreateUserDocToState(
      {String name,
      String username,
      File profilePictureFile,
      String email,
      String status,
      String uid}) async* {
    try {
      yield ProfileFormLoading();
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
        UserModel user =
            await _authRepository.getOrCreateUserDocForGoogleSignIn(
                name: name,
                username: username,
                status: status,
                uid: uid,
                email: email,
                profilePictureUrl: url);
        yield ProfileCreated(user: user);
        _authenticationBloc.add(LoggedIn());
      } else {
        yield ProfileFormError(
            message: 'Username already used. Enter a different username');
      }
    } catch (e) {
      yield ProfileFormError(message: e.toString());
    }
  }
}

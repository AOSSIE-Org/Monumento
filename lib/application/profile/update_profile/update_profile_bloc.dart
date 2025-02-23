import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:monumento/utils/constants.dart';

part 'update_profile_event.dart';
part 'update_profile_state.dart';

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  final SocialRepository _socialRepository;
  final AuthenticationRepository _authenticationRepository;
  UpdateProfileBloc(this._socialRepository, this._authenticationRepository)
      : super(UpdateProfileInitial()) {
    on<UpdateUserDetails>(_mapUpdateUserDetails);
    on<UpdateUserDetailsDesktop>(_mapUpdateUserDetailsDesktop);
  }

  FutureOr<void> _mapUpdateUserDetails(
      UpdateUserDetails event, Emitter<UpdateProfileState> emit) async {
    try {
      emit(UpdateProfileLoading());
      if (event.userInfo.keys.first == "profilePictureUrl") {
        String url;

        if (event.userInfo.values.first != null) {
          url = await _socialRepository.uploadProfilePicForUrl(
              file: event.userInfo.values.first);
        } else {
          url = defaultProfilePicture;
        }
        await _socialRepository
            .updateUserProfile(userInfo: {'profilePictureUrl': url});
        emit(UpdateProfileSuccess(userInfo: event.userInfo));
      } else if (event.userInfo.keys.first == "email" ||
          event.userInfo.keys.first == "password") {
        await _authenticationRepository.updateEmailPassword(
            emailPassword: event.userInfo);
        emit(UpdateProfileSuccess(userInfo: event.userInfo));
      } else {
        if (event.userInfo.keys.first == "username") {
          bool isUserNameAvailable = await _socialRepository
              .checkUserNameAvailability(username: event.userInfo.values.first);
          if (isUserNameAvailable) {
            await _socialRepository.updateUserProfile(userInfo: event.userInfo);
            emit(UpdateProfileSuccess(userInfo: event.userInfo));
          } else {
            emit(const UpdateProfileFailure(message: "Username already taken"));
          }
        } else {
          await _socialRepository.updateUserProfile(userInfo: event.userInfo);
          emit(UpdateProfileSuccess(userInfo: event.userInfo));
        }
      }
    } catch (e) {
      emit(UpdateProfileFailure(message: e.toString()));
    }
  }

  FutureOr<void> _mapUpdateUserDetailsDesktop(
      UpdateUserDetailsDesktop event, Emitter<UpdateProfileState> emit) async {
    try {
      emit(
        UpdateProfileLoading(),
      );

      bool hasChanges = await _checkIfThereAreNewUserUpdates(event);
      if (!hasChanges) {
        emit(const UpdateProfileFailure(message: "No changes detected"));
        return;
      }
      if (event.userInfo.keys.contains('image') &&
          event.userInfo['image'] != null) {
        String url = await _socialRepository.uploadProfilePicForUrl(
            file: event.userInfo['image']);
        event.userInfo['profilePictureUrl'] = url;
        event.userInfo.remove('image');
      }
      if (event.userInfo['shouldUpdateUsername']) {
        if (event.userInfo.keys.contains('username')) {
          bool isUserNameAvailable = await _socialRepository
              .checkUserNameAvailability(username: event.userInfo['username']);
          if (!isUserNameAvailable) {
            emit(const UpdateProfileFailure(message: "Username already taken"));
            return;
          }
        }
      }

      await _socialRepository.updateUserProfile(userInfo: event.userInfo);
      emit(UpdateProfileSuccess(userInfo: event.userInfo));
    } catch (e) {
      emit(UpdateProfileFailure(message: e.toString()));
    }
  }

  Future<bool> _checkIfThereAreNewUserUpdates(
      UpdateUserDetailsDesktop event) async {
    final (success, currentUser) = await _authenticationRepository.getUser();

    if (!success || currentUser == null) {
      return false;
    }

    bool hasChanges = (event.userInfo.containsKey('name') &&
            event.userInfo['name'] != currentUser.name) ||
        (event.userInfo.containsKey('status') &&
            event.userInfo['status'] != currentUser.status) ||
        (event.userInfo.containsKey('username') &&
            event.userInfo['username'] != currentUser.username) ||
        event.userInfo.containsKey('image');

    return hasChanges;
  }
}

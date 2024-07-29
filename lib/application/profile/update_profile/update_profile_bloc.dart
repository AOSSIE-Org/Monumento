import 'dart:async';
import 'dart:developer';

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
        emit(UpdateProfileSuccess());
      } else if (event.userInfo.keys.first == "email" ||
          event.userInfo.keys.first == "password") {
        await _authenticationRepository.updateEmailPassword(
            emailPassword: event.userInfo);
        emit(UpdateProfileSuccess());
      } else {
        if (event.userInfo.keys.first == "username") {
          bool isUserNameAvailable = await _socialRepository
              .checkUserNameAvailability(username: event.userInfo.values.first);
          if (isUserNameAvailable) {
            await _socialRepository.updateUserProfile(userInfo: event.userInfo);
            emit(UpdateProfileSuccess());
          } else {
            emit(const UpdateProfileFailure(message: "Username already taken"));
          }
        } else {
          await _socialRepository.updateUserProfile(userInfo: event.userInfo);
          emit(UpdateProfileSuccess());
        }
      }
    } catch (e) {
      emit(UpdateProfileFailure(message: e.toString()));
    }
  }
}

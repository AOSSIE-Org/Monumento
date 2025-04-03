import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';

part 'follow_event.dart';
part 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final SocialRepository _socialRepository;
  final AuthenticationBloc _authenticationBloc;
  final AuthenticationRepository _authenticationRepository;
  bool _currentFollowStatus = false;

  FollowBloc(this._socialRepository, this._authenticationBloc, this._authenticationRepository) : super(FollowInitial()) {
    on<FollowUser>(_mapFollowUserToState);
    on<UnfollowUser>(_mapUnfollowUserToState);
    on<GetFollowStatus>(_mapGetFollowStatusToState);
    on<LoadUser>(_mapLoadUserToState);
  }

  _mapFollowUserToState(FollowUser event, Emitter<FollowState> emit) async {
    try {
      emit(LoadingFollowState());
      await _socialRepository.followUser(targetUser: event.targetUser);
      _currentFollowStatus = true;
      emit(FollowStatusRetrieved(following: _currentFollowStatus));
      
      // Update authentication state
      _authenticationBloc.add(LoggedIn());
      
      // Get the current user's following and followers lists
      final (userLoggedIn, user) = await _authenticationRepository.getUser();
      if (userLoggedIn && user != null) {
        add(LoadUser(following: user.following));
        add(LoadUser(following: user.followers));
      }
    } catch (e) {
      log('${e.toString()} follow');
      emit(FollowStateError(e.toString()));
    }
  }

  _mapUnfollowUserToState(UnfollowUser event, Emitter<FollowState> emit) async {
    try {
      emit(LoadingFollowState());
      await _socialRepository.unfollowUser(targetUser: event.targetUser);
      _currentFollowStatus = false;
      emit(FollowStatusRetrieved(following: _currentFollowStatus));
      
      // Update authentication state
      _authenticationBloc.add(LoggedIn());
      
      // Get the current user's following and followers lists
      final (userLoggedIn, user) = await _authenticationRepository.getUser();
      if (userLoggedIn && user != null) {
        add(LoadUser(following: user.following));
        add(LoadUser(following: user.followers));
      }
    } catch (e) {
      log('${e.toString()} unfollow');
      emit(FollowStateError(e.toString()));
    }
  }

  _mapGetFollowStatusToState(
      GetFollowStatus event, Emitter<FollowState> emit) async {
    try {
      emit(LoadingFollowState());
      _currentFollowStatus =
          await _socialRepository.getFollowStatus(targetUser: event.targetUser);
      emit(FollowStatusRetrieved(following: _currentFollowStatus));
    } catch (e) {
      log('${e.toString()} status');
      emit(FollowStateError(e.toString()));
    }
  }

  FutureOr<void> _mapLoadUserToState(
      LoadUser event, Emitter<FollowState> emit) async {
    try {
      emit(LoadingFollowUserListState());

      final userData = await _socialRepository.loadUser(event.following);

      List<UserEntity> userDataEntity =
          userData.map((e) => e.toEntity()).toList();

      emit(LoadedFollowUserListState(userData: userDataEntity));
    } catch (e) {
      log('${e.toString()} follow');
      emit(FollowUserListErrorState(message: e.toString()));
    }
  }
}

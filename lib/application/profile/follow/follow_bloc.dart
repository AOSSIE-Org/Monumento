import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'follow_event.dart';
part 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final SocialRepository _socialRepository;

  FollowBloc(this._socialRepository) : super(FollowInitial()) {
    on<FollowUser>(_mapFollowUserToState);
    on<UnfollowUser>(_mapUnfollowUserToState);
    on<GetFollowStatus>(_mapGetFollowStatusToState);
  }

  _mapFollowUserToState(FollowUser event, Emitter<FollowState> emit) async {
    try {
      emit(LoadingFollowState());
      await _socialRepository.followUser(targetUser: event.targetUser);
      add(GetFollowStatus(targetUser: event.targetUser));
    } catch (e) {
      log('${e.toString()} follow');

      emit(FollowStateError(e.toString()));
    }
  }

  _mapUnfollowUserToState(UnfollowUser event, Emitter<FollowState> emit) async {
    try {
      emit(LoadingFollowState());

      await _socialRepository.unfollowUser(targetUser: event.targetUser);
      add(GetFollowStatus(targetUser: event.targetUser));
    } catch (e) {
      log('${e.toString()} unfollow');

      emit(FollowStateError(e.toString()));
    }
  }

  _mapGetFollowStatusToState(
      GetFollowStatus event, Emitter<FollowState> emit) async {
    try {
      emit(LoadingFollowState());
      bool following =
          await _socialRepository.getFollowStatus(targetUser: event.targetUser);
      emit(FollowStatusRetrieved(following: following));
    } catch (e) {
      log('${e.toString()} status');

      emit(FollowStateError(e.toString()));
    }
  }
}

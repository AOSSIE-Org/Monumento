import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/social_repository.dart';

part 'follow_event.dart';
part 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final SocialRepository _socialRepository;

  FollowBloc({SocialRepository socialRepository})
      : assert(socialRepository != null),
        _socialRepository = socialRepository,
        super(FollowInitial());

  @override
  Stream<FollowState> mapEventToState(
    FollowEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is FollowUser) {
      yield* _mapFollowUserToState(
          targetUser: event.targetUser, currentUser: event.currentUser);
    } else if (event is UnfollowUser) {
      yield* _mapUnfollowUserToState(
          targetUser: event.targetUser, currentUser: event.currentUser);
    } else if (event is GetFollowStatus) {
      yield* _mapGetFollowStatusToState(
          targetUser: event.targetUser, currentUser: event.currentUser);
    }
  }

  Stream<FollowState> _mapFollowUserToState(
      {@required UserModel targetUser,
      @required UserModel currentUser}) async* {
    try {
      yield LoadingFollowState();
      await _socialRepository.followUser(
          targetUser: targetUser, currentUser: currentUser);
      add(GetFollowStatus(targetUser: targetUser, currentUser: currentUser));
    } catch (e) {
      print(e.toString() + 'follow');

      yield FollowStateError(e.toString());
    }
  }

  Stream<FollowState> _mapUnfollowUserToState(
      {@required UserModel targetUser,
      @required UserModel currentUser}) async* {
    try {
      yield LoadingFollowState();

      await _socialRepository.unfollowUser(
          targetUser: targetUser, currentUser: currentUser);
      add(GetFollowStatus(targetUser: targetUser, currentUser: currentUser));
    } catch (e) {
      print(e.toString() + 'unfollow');
      yield FollowStateError(e.toString());
    }
  }

  Stream<FollowState> _mapGetFollowStatusToState(
      {@required UserModel targetUser,
      @required UserModel currentUser}) async* {
    try {
      yield LoadingFollowState();
      if (targetUser == currentUser) {
        yield CurrentUserProfile();
      } else {
        bool following = await _socialRepository.getFollowStatus(
            targetUser: targetUser, currentUser: currentUser);
        yield FollowStatusRetrieved(following: following);
      }
    } catch (e) {
      print(e.toString() + 'status');

      yield FollowStateError(e.toString());
    }
  }
}

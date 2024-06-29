part of 'follow_bloc.dart';

abstract class FollowEvent extends Equatable {
  const FollowEvent();
}

class FollowUser extends FollowEvent {
  final UserEntity targetUser;
  final UserEntity currentUser;

  const FollowUser({required this.targetUser, required this.currentUser});
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class UnfollowUser extends FollowEvent {
  final UserEntity targetUser;
  final UserEntity currentUser;
  const UnfollowUser({required this.targetUser, required this.currentUser});
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetFollowStatus extends FollowEvent {
  final UserEntity targetUser;
  final UserEntity currentUser;

  const GetFollowStatus({required this.targetUser, required this.currentUser});
  @override
  // TODO: implement props
  List<Object> get props => [];
}

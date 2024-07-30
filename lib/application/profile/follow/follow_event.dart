part of 'follow_bloc.dart';

abstract class FollowEvent extends Equatable {
  const FollowEvent();
}

class FollowUser extends FollowEvent {
  final UserEntity targetUser;

  const FollowUser({required this.targetUser});

  @override
  List<Object> get props => [];
}

class UnfollowUser extends FollowEvent {
  final UserEntity targetUser;
  const UnfollowUser({required this.targetUser});

  @override
  List<Object> get props => [];
}

class GetFollowStatus extends FollowEvent {
  final UserEntity targetUser;

  const GetFollowStatus({required this.targetUser});

  @override
  List<Object> get props => [];
}

class LoadUser extends FollowEvent {
  final List<String> following;

  const LoadUser({required this.following});

  @override
  List<Object?> get props => [];
  
}

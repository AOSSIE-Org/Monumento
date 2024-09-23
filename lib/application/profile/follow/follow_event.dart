part of 'follow_bloc.dart';

sealed class FollowEvent extends Equatable {
  const FollowEvent();
}

final class FollowUser extends FollowEvent {
  final UserEntity targetUser;

  const FollowUser({required this.targetUser});

  @override
  List<Object> get props => [targetUser];
}

final class UnfollowUser extends FollowEvent {
  final UserEntity targetUser;
  const UnfollowUser({required this.targetUser});

  @override
  List<Object> get props => [targetUser];
}

final class GetFollowStatus extends FollowEvent {
  final UserEntity targetUser;

  const GetFollowStatus({required this.targetUser});

  @override
  List<Object> get props => [targetUser];
}

final class LoadUser extends FollowEvent {
  final List<String> following;

  const LoadUser({required this.following});

  @override
  List<Object?> get props => [following];
  
}

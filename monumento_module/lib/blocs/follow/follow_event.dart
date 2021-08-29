part of 'follow_bloc.dart';

abstract class FollowEvent extends Equatable {
  const FollowEvent();
}

class FollowUser extends FollowEvent {
  final UserModel targetUser;
  final UserModel currentUser;

  FollowUser({@required this.targetUser, @required this.currentUser});
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class UnfollowUser extends FollowEvent {
  final UserModel targetUser;
  final UserModel currentUser;
  UnfollowUser({@required this.targetUser, @required this.currentUser});
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetFollowStatus extends FollowEvent {
  final UserModel targetUser;
  final UserModel currentUser;

  GetFollowStatus({@required this.targetUser, @required this.currentUser});
  @override
  // TODO: implement props
  List<Object> get props => [];
}

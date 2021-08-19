part of 'follow_bloc.dart';

abstract class FollowState extends Equatable {
  const FollowState();
}

class FollowInitial extends FollowState {
  @override
  List<Object> get props => [];
}

class FollowStatusRetrieved extends FollowState {
  final bool following;

  FollowStatusRetrieved({@required this.following});

  @override
  List<Object> get props => [];
}

class FollowStateError extends FollowState {
  final String message;

  FollowStateError(this.message);

  @override
  List<Object> get props => [];
}

class LoadingFollowState extends FollowState {
  @override
  List<Object> get props => [];
}

class CurrentUserProfile extends FollowState {
  @override
  List<Object> get props => [];
}

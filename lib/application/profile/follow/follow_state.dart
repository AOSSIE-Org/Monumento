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

  const FollowStatusRetrieved({required this.following});

  @override
  List<Object> get props => [];
}

class FollowStateError extends FollowState {
  final String message;

  const FollowStateError(this.message);

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

class LoadingFollowUserListState extends FollowState {
  @override
  List<Object?> get props => [];
  
}

class LoadedFollowUserListState extends FollowState {
  final List<UserEntity> userData;

  const LoadedFollowUserListState({required this.userData});

  @override
  List<Object?> get props => [userData];
  
}

class FollowUserListErrorState extends FollowState {
  final String message;

  const FollowUserListErrorState({required this.message});

  @override
  List<Object?> get props => [message];
  
}

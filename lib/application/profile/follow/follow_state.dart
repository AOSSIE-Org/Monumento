part of 'follow_bloc.dart';

sealed class FollowState extends Equatable {
  const FollowState();
}

final class FollowInitial extends FollowState {
  @override
  List<Object> get props => [];
}

final class FollowStatusRetrieved extends FollowState {
  final bool following;

  const FollowStatusRetrieved({required this.following});

  @override
  List<Object> get props => [following];
}

final class FollowStateError extends FollowState {
  final String message;

  const FollowStateError(this.message);

  @override
  List<Object> get props => [message];
}

final class LoadingFollowState extends FollowState {
  @override
  List<Object> get props => [];
}

final class CurrentUserProfile extends FollowState {
  @override
  List<Object> get props => [];
}

final class LoadingFollowUserListState extends FollowState {
  @override
  List<Object?> get props => [];
  
}

final class LoadedFollowUserListState extends FollowState {
  final List<UserEntity> userData;

  const LoadedFollowUserListState({required this.userData});

  @override
  List<Object?> get props => [userData];
  
}

final class FollowUserListErrorState extends FollowState {
  final String message;

  const FollowUserListErrorState({required this.message});

  @override
  List<Object?> get props => [message];
  
}

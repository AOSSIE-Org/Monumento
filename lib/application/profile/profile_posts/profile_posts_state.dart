part of 'profile_posts_bloc.dart';

sealed class ProfilePostsState extends Equatable {
  const ProfilePostsState();
}

class ProfilePostsInitial extends ProfilePostsState {
  @override
  List<Object> get props => [];
}

class InitialProfilePostsLoaded extends ProfilePostsState {
  final List<PostEntity> initialPosts;

  const InitialProfilePostsLoaded({required this.initialPosts});

  @override
  List<Object> get props => [initialPosts];
}

// ignore: must_be_immutable
class MoreProfilePostsLoaded extends ProfilePostsState {
  final List<PostEntity> posts;
  final bool hasReachedMax;
  const MoreProfilePostsLoaded({required this.posts, required this.hasReachedMax});

  @override
  List<Object> get props => [posts, hasReachedMax];
}

class InitialProfilePostsLoadingFailed extends ProfilePostsState {
  final String message;
  const InitialProfilePostsLoadingFailed({required this.message});
  @override
  List<Object> get props => [];
}

class MoreProfilePostsLoadingFailed extends ProfilePostsState {
  @override
  List<Object> get props => [];
}

class LoadingInitialProfilePosts extends ProfilePostsState {
  @override
  List<Object> get props => [];
}

class LoadingMoreProfilePosts extends ProfilePostsState {
  @override
  List<Object> get props => [];
}

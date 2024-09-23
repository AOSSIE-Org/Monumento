part of 'discover_posts_bloc.dart';

sealed class DiscoverPostsState extends Equatable {
  const DiscoverPostsState();

  @override
  List<Object> get props => [];
}

final class DiscoverPostsInitial extends DiscoverPostsState {}

class InitialDiscoverPostsLoaded extends DiscoverPostsState {
  final List<PostEntity> initialPosts;

  const InitialDiscoverPostsLoaded({required this.initialPosts});

  @override
  List<Object> get props => [initialPosts];
}

class MoreDiscoverPostsLoaded extends DiscoverPostsState {
  final List<PostEntity> posts;
  final bool hasReachedMax;
  const MoreDiscoverPostsLoaded(
      {required this.posts, required this.hasReachedMax});
  @override
  List<Object> get props => [posts, hasReachedMax];
}

class InitialDiscoverPostsLoadingFailed extends DiscoverPostsState {
  @override
  List<Object> get props => [];
}

class MoreDiscoverPostsLoadingFailed extends DiscoverPostsState {
  final String message;

  @override
  List<Object> get props => [message];

  const MoreDiscoverPostsLoadingFailed({
    required this.message,
  });
}

class LoadingInitialDiscoverPosts extends DiscoverPostsState {
  @override
  List<Object> get props => [];
}

class LoadingMoreDiscoverPosts extends DiscoverPostsState {
  @override
  List<Object> get props => [];
}

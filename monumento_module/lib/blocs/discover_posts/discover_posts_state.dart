part of 'discover_posts_bloc.dart';

abstract class DiscoverPostsState extends Equatable {
  const DiscoverPostsState();
}

class DiscoverPostsInitial extends DiscoverPostsState {
  @override
  List<Object> get props => [];
}
class InitialDiscoverPostsLoaded extends DiscoverPostsState {
  final List<PostModel> initialPosts;

  InitialDiscoverPostsLoaded({this.initialPosts});

  @override
  List<Object> get props => [initialPosts];
}

class MoreDiscoverPostsLoaded extends DiscoverPostsState {
  final List<PostModel> posts;
  MoreDiscoverPostsLoaded({@required this.posts});
  @override
  List<Object> get props => [posts];
}

class InitialDiscoverPostsLoadingFailed extends DiscoverPostsState {
  @override
  List<Object> get props => [];
}

class MoreDiscoverPostsLoadingFailed extends DiscoverPostsState {
  @override
  List<Object> get props => [];
}

class LoadingInitialDiscoverPosts extends DiscoverPostsState {
  @override
  List<Object> get props => [];
}

class LoadingMoreDiscoverPosts extends DiscoverPostsState {
  @override
  List<Object> get props => [];
}

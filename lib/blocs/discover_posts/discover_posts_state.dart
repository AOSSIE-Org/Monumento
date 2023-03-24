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
  bool hasReachedMax;
  MoreDiscoverPostsLoaded({@required this.posts}) {
    if (posts.isEmpty) {
      hasReachedMax = true;
    } else {
      hasReachedMax = false;
    }
  }
  @override
  List<Object> get props => [posts];
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
    @required this.message,
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

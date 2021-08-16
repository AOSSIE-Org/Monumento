part of 'feed_bloc.dart';

@immutable
abstract class FeedState extends Equatable {}

class FeedInitial extends FeedState {
  @override
  List<Object> get props => [];
}

class InitialFeedLoaded extends FeedState {
  final List<PostModel> initialPosts;

  InitialFeedLoaded({this.initialPosts});

  @override
  List<Object> get props => [initialPosts];
}

class MorePostsLoaded extends FeedState {
  final List<PostModel> posts;
  bool hasReachedMax;
  MorePostsLoaded({@required this.posts}) {
    if (posts.isEmpty) {
      hasReachedMax = true;
    } else {
      hasReachedMax = false;
    }
  }
  @override
  List<Object> get props => [posts];
}

class InitialFeedLoadingFailed extends FeedState {
  @override
  List<Object> get props => [];
}

class MorePostsLoadingFailed extends FeedState {
  final String message;
  @override
  List<Object> get props => [message];

  MorePostsLoadingFailed({
    @required this.message,
  });
}

class LoadingInitialFeed extends FeedState {
  @override
  List<Object> get props => [];
}

class LoadingMorePosts extends FeedState {
  @override
  List<Object> get props => [];
}

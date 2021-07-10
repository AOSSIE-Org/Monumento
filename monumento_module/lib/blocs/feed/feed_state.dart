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
  MorePostsLoaded({@required this.posts});
  @override
  List<Object> get props => [posts];
}

class InitialFeedLoadingFailed extends FeedState {
  @override
  List<Object> get props => [];
}

class MorePostsLoadingFailed extends FeedState {
  @override
  List<Object> get props => [];
}

class LoadingInitialFeed extends FeedState {
  @override
  List<Object> get props => [];
}

class LoadingMorePosts extends FeedState {
  @override
  List<Object> get props => [];
}

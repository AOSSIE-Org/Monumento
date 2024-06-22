part of 'feed_bloc.dart';

sealed class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object> get props => [];
}

final class FeedInitial extends FeedState {}

class InitialFeedLoaded extends FeedState {
  final List<PostEntity> initialPosts;

  const InitialFeedLoaded({required this.initialPosts});

  @override
  List<Object> get props => [initialPosts];
}

class MorePostsLoaded extends FeedState {
  final List<PostEntity> posts;
  final bool hasReachedMax;
  const MorePostsLoaded({required this.posts, required this.hasReachedMax});
  @override
  List<Object> get props => [posts, hasReachedMax];
}

class InitialFeedLoadingFailed extends FeedState {
  @override
  List<Object> get props => [];
}

class MorePostsLoadingFailed extends FeedState {
  final String message;
  @override
  List<Object> get props => [message];

  const MorePostsLoadingFailed({
    required this.message,
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

class PostLiked extends FeedState {
  final String postId;
  final bool isPostLiked;

  const PostLiked({
    required this.postId,
    required this.isPostLiked,
  });

  @override
  List<Object> get props => [postId, isPostLiked];
}

class PostLikeFailed extends FeedState {
  final String message;
  final String postId;

  const PostLikeFailed({
    required this.postId,
    required this.message,
  });

  @override
  List<Object> get props => [message, postId];
}

class PostUnLiked extends FeedState {
  final String postId;
  final bool isPostLiked;

  const PostUnLiked({
    required this.postId,
    required this.isPostLiked,
  });

  @override
  List<Object> get props => [postId, isPostLiked];
}

class PostUnlikeFailed extends FeedState {
  final String message;
  final String postId;

  const PostUnlikeFailed({
    required this.postId,
    required this.message,
  });

  @override
  List<Object> get props => [message, postId];
}

part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

class LoadInitialFeed extends FeedEvent {
  @override
  List<Object> get props => [];
}

class LoadMorePosts extends FeedEvent {
  final String startAfterDocId;

  const LoadMorePosts({required this.startAfterDocId});
  @override
  List<Object> get props => [startAfterDocId];
}

class LikePost extends FeedEvent {
  final String postId;

  const LikePost({required this.postId});
  @override
  List<Object> get props => [postId];
}

class UnlikePost extends FeedEvent {
  final String postId;

  const UnlikePost({required this.postId});
  @override
  List<Object> get props => [postId];
}

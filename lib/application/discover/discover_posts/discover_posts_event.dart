part of 'discover_posts_bloc.dart';

sealed class DiscoverPostsEvent extends Equatable {
  const DiscoverPostsEvent();

  @override
  List<Object> get props => [];
}

class LoadInitialDiscoverPosts extends DiscoverPostsEvent {
  @override
  List<Object> get props => [];
}

class LoadMoreDiscoverPosts extends DiscoverPostsEvent {
  final String startAfterDocId;

  const LoadMoreDiscoverPosts({required this.startAfterDocId});
  @override
  List<Object> get props => [startAfterDocId];
}

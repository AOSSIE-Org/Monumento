part of 'discover_posts_bloc.dart';

abstract class DiscoverPostsEvent extends Equatable {
  const DiscoverPostsEvent();
}

class LoadInitialDiscoverPosts extends DiscoverPostsEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoadMoreDiscoverPosts extends DiscoverPostsEvent {
  final DocumentSnapshot startAfterDoc;

  LoadMoreDiscoverPosts({@required this.startAfterDoc});
  @override
  List<Object> get props => [startAfterDoc.id];
}

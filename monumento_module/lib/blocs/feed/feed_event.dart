part of 'feed_bloc.dart';

@immutable
abstract class FeedEvent extends Equatable {}

class LoadInitialFeed extends FeedEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoadMorePosts extends FeedEvent {
  final DocumentSnapshot startAfterDoc;

  LoadMorePosts({@required this.startAfterDoc});
  @override
  List<Object> get props => [startAfterDoc.id];
}

part of 'profile_posts_bloc.dart';

abstract class ProfilePostsEvent extends Equatable {
  const ProfilePostsEvent();
}

class LoadInitialProfilePosts extends ProfilePostsEvent {
  final String uid;
  LoadInitialProfilePosts({@required this.uid});
  @override
  // TODO: implement props
  List<Object> get props => [uid];
}

class LoadMoreProfilePosts extends ProfilePostsEvent {
  final String uid;

  final DocumentSnapshot startAfterDoc;

  LoadMoreProfilePosts({@required this.startAfterDoc, @required this.uid});
  @override
  List<Object> get props => [startAfterDoc.id];
}

part of 'profile_posts_bloc.dart';

sealed class ProfilePostsEvent extends Equatable {
  const ProfilePostsEvent();
}

class LoadInitialProfilePosts extends ProfilePostsEvent {
  const LoadInitialProfilePosts();
  @override

  List<Object> get props => [];
}

class LoadMoreProfilePosts extends ProfilePostsEvent {
  final String startAfterDocId;

  const LoadMoreProfilePosts({required this.startAfterDocId});
  @override
  List<Object> get props => [startAfterDocId];
}

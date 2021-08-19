part of 'profile_posts_bloc.dart';

abstract class ProfilePostsState extends Equatable {
  const ProfilePostsState();
}

class ProfilePostsInitial extends ProfilePostsState {
  @override
  List<Object> get props => [];
}

class InitialProfilePostsLoaded extends ProfilePostsState {
  final List<PostModel> initialPosts;

  InitialProfilePostsLoaded({this.initialPosts});

  @override
  List<Object> get props => [initialPosts];
}

class MoreProfilePostsLoaded extends ProfilePostsState {
  final List<PostModel> posts;
  bool hasReachedMax;
  MoreProfilePostsLoaded({@required this.posts}) {
    if (posts.isEmpty) {
      hasReachedMax = true;
    } else {
      hasReachedMax = false;
    }
  }

  @override
  List<Object> get props => [posts];
}

class InitialProfilePostsLoadingFailed extends ProfilePostsState {
  final String message;
  InitialProfilePostsLoadingFailed({this.message});
  @override
  List<Object> get props => [];
}

class MoreProfilePostsLoadingFailed extends ProfilePostsState {
  @override
  List<Object> get props => [];
}

class LoadingInitialProfilePosts extends ProfilePostsState {
  @override
  List<Object> get props => [];
}

class LoadingMoreProfilePosts extends ProfilePostsState {
  @override
  List<Object> get props => [];
}

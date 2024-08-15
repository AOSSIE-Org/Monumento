part of 'discover_profile_bloc.dart';

sealed class DiscoverProfileState extends Equatable {
  const DiscoverProfileState();

  @override
  List<Object> get props => [];
}

final class DiscoverProfileInitial extends DiscoverProfileState {}

class DiscoverProfileLoading extends DiscoverProfileState {}

class DiscoverProfilePostsLoaded extends DiscoverProfileState {
  final List<PostEntity> posts;

  const DiscoverProfilePostsLoaded({required this.posts});

  @override
  List<Object> get props => [posts];
}

class DiscoverProfileMorePostsLoaded extends DiscoverProfileState {
  final List<PostEntity> posts;
  final bool hasReachedMax;

  const DiscoverProfileMorePostsLoaded(
      {required this.posts, required this.hasReachedMax});

  @override
  List<Object> get props => [posts];
}

class DiscoverProfileLoadingFailed extends DiscoverProfileState {}

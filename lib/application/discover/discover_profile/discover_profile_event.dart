part of 'discover_profile_bloc.dart';

sealed class DiscoverProfileEvent extends Equatable {
  const DiscoverProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadDiscoverProfilePosts extends DiscoverProfileEvent {
  final String userId;

  const LoadDiscoverProfilePosts({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadMoreDiscoverProfilePosts extends DiscoverProfileEvent {
  final String userId;
  final String startAfterDocId;

  const LoadMoreDiscoverProfilePosts(
      {required this.userId, required this.startAfterDocId});

  @override
  List<Object> get props => [userId, startAfterDocId];
}

part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

final class SearchInitial extends SearchState {}

class SearchedPeople extends SearchState {
  final List<UserEntity> searchedUsers;

  const SearchedPeople({required this.searchedUsers});

  @override
  List<Object> get props => [searchedUsers];
}

class SearchedMorePeople extends SearchState {
  final List<UserEntity> searchedUsers;
  final bool hasReachedMax;
  const SearchedMorePeople(
      {required this.searchedUsers, required this.hasReachedMax});

  @override
  List<Object> get props => [searchedUsers];
}

class SearchingPeopleFailed extends SearchState {
  @override
  List<Object> get props => [];
}

class SearchingMorePeopleFailed extends SearchState {
  @override
  List<Object> get props => [];
}

class LoadingPeople extends SearchState {
  @override
  List<Object> get props => [];
}

class LoadingMorePeople extends SearchState {
  @override
  List<Object> get props => [];
}

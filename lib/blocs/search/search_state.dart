part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();
}

class SearchInitial extends SearchState {
  @override
  List<Object> get props => [];
}

class SearchedPeople extends SearchState {
  final List<UserModel> searchedUsers;

  SearchedPeople({@required this.searchedUsers});

  @override
  List<Object> get props => [searchedUsers];
}

class SearchedMorePeople extends SearchState {
  final List<UserModel> searchedUsers;
  bool hasReachedMax;
  SearchedMorePeople({@required this.searchedUsers}) {
    if (searchedUsers.isEmpty) {
      hasReachedMax = true;
    } else {
      hasReachedMax = false;
    }
  }

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

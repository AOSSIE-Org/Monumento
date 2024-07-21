part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchPeople extends SearchEvent {
  final String searchQuery;

  const SearchPeople({required this.searchQuery});
  @override
  List<Object> get props => [searchQuery];
}

class SearchMorePeople extends SearchEvent {
  final String searchQuery;
  final String startAfterDocId;

  const SearchMorePeople(
      {required this.searchQuery, required this.startAfterDocId});
  @override
  List<Object> get props => [searchQuery, startAfterDocId];
}

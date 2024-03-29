part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
}

class SearchPeople extends SearchEvent {
  final String searchQuery;

  SearchPeople({@required this.searchQuery});
  @override
  // TODO: implement props
  List<Object> get props => [searchQuery];
}

class SearchMorePeople extends SearchEvent {
  final String searchQuery;
  final DocumentSnapshot startAfterDoc;

  SearchMorePeople({@required this.searchQuery, @required this.startAfterDoc});
  @override
  // TODO: implement props
  List<Object> get props => [searchQuery, startAfterDoc];
}

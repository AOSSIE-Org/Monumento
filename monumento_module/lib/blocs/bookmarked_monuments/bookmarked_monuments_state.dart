part of 'bookmarked_monuments_bloc.dart';

abstract class BookmarkedMonumentsState extends Equatable {
  const BookmarkedMonumentsState();
}

class BookmarkedMonumentsInitial extends BookmarkedMonumentsState {
  @override
  List<Object> get props => [];
}

class BookmarkedMonumentsRetrieved extends BookmarkedMonumentsState {
  final List<BookmarkedMonumentModel> bookmarkedMonuments;
  BookmarkedMonumentsRetrieved({this.bookmarkedMonuments});

  @override
  List<Object> get props => [bookmarkedMonuments];
}

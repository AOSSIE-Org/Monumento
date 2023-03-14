part of 'bookmarked_monuments_bloc.dart';

abstract class BookmarkedMonumentsEvent extends Equatable {
  const BookmarkedMonumentsEvent();
}

class RetrieveBookmarkedMonuments extends BookmarkedMonumentsEvent {
  final String userId;
  RetrieveBookmarkedMonuments({this.userId});
  @override
  // TODO: implement props
  List<Object> get props => [userId];
}

class UpdateBookmarkedMonuments extends BookmarkedMonumentsEvent {
  final List<BookmarkedMonumentModel> updatedBookmarkedMonuments;
  UpdateBookmarkedMonuments({this.updatedBookmarkedMonuments});
  @override
  // TODO: implement props
  List<Object> get props => [updatedBookmarkedMonuments];
}

part of 'bookmarked_monuments_bloc.dart';


sealed class BookmarkedMonumentsEvent extends Equatable {
  const BookmarkedMonumentsEvent();
}

class RetrieveBookmarkedMonuments extends BookmarkedMonumentsEvent {
  final String userId;
  const RetrieveBookmarkedMonuments({required this.userId});
  @override
  // TODO: implement props
  List<Object> get props => [userId];
}

class UpdateBookmarkedMonuments extends BookmarkedMonumentsEvent {
  final List<BookmarkedMonumentModel> updatedBookmarkedMonuments;
  const UpdateBookmarkedMonuments({required this.updatedBookmarkedMonuments});
  @override
  // TODO: implement props
  List<Object> get props => [updatedBookmarkedMonuments];
}

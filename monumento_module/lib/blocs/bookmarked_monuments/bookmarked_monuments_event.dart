part of 'bookmarked_monuments_bloc.dart';

abstract class BookmarkedMonumentsEvent extends Equatable {
  const BookmarkedMonumentsEvent();
}

class RetrieveBookmarkedMonuments extends BookmarkedMonumentsEvent {
  final String userId;
  RetrieveBookmarkedMonuments({this.userId});
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class UpdateBookmarkedMonuments extends BookmarkedMonumentsEvent {
  final List<DocumentSnapshot> updatedBookmarkedMonuments;
  UpdateBookmarkedMonuments({this.updatedBookmarkedMonuments});
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

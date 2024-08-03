part of 'bookmark_monuments_bloc.dart';

sealed class BookmarkMonumentsEvent extends Equatable {
  const BookmarkMonumentsEvent();

  @override
  List<Object> get props => [];
}

final class BookmarkMonument extends BookmarkMonumentsEvent {
  final MonumentEntity monument;

  const BookmarkMonument(this.monument);

  @override
  List<Object> get props => [monument];
}

final class UnbookmarkMonument extends BookmarkMonumentsEvent {
  final MonumentEntity monument;

  const UnbookmarkMonument(this.monument);

  @override
  List<Object> get props => [monument];
}

final class GetBookmarkedMonuments extends BookmarkMonumentsEvent {
  const GetBookmarkedMonuments();

  @override
  List<Object> get props => [];
}

final class CheckIfMonumentIsBookmarked extends BookmarkMonumentsEvent {
  final String monumentId;

  const CheckIfMonumentIsBookmarked(this.monumentId);

  @override
  List<Object> get props => [monumentId];
}

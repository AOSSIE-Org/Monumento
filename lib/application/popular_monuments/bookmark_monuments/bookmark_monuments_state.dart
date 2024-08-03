part of 'bookmark_monuments_bloc.dart';

sealed class BookmarkMonumentsState extends Equatable {
  const BookmarkMonumentsState();

  @override
  List<Object> get props => [];
}

final class BookmarkMonumentsInitial extends BookmarkMonumentsState {}

final class MonumentAlreadyBookmarked extends BookmarkMonumentsState {
  final String monumentId;

  const MonumentAlreadyBookmarked(this.monumentId);

  @override
  List<Object> get props => [monumentId];
}

final class MonumentNotBookmarked extends BookmarkMonumentsState {
  final String monumentId;

  const MonumentNotBookmarked(this.monumentId);

  @override
  List<Object> get props => [monumentId];
}

final class MonumentBookmarked extends BookmarkMonumentsState {
  final String monumentId;

  const MonumentBookmarked(this.monumentId);

  @override
  List<Object> get props => [monumentId];
}

final class MonumentUnbookmarked extends BookmarkMonumentsState {
  final String monumentId;

  const MonumentUnbookmarked(this.monumentId);

  @override
  List<Object> get props => [monumentId];
}

final class BookmarkedMonumentsLoaded extends BookmarkMonumentsState {
  final List<MonumentEntity> bookmarkedMonuments;

  const BookmarkedMonumentsLoaded(this.bookmarkedMonuments);

  @override
  List<Object> get props => [bookmarkedMonuments];
}

final class BookmarkedMonumentsError extends BookmarkMonumentsState {
  final String message;

  const BookmarkedMonumentsError(this.message);

  @override
  List<Object> get props => [message];
}

final class BookmarkedMonumentsLoading extends BookmarkMonumentsState {}

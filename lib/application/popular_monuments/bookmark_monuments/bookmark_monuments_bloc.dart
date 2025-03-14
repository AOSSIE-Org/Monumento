import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';

part 'bookmark_monuments_event.dart';
part 'bookmark_monuments_state.dart';

class BookmarkMonumentsBloc
    extends Bloc<BookmarkMonumentsEvent, BookmarkMonumentsState> {
  final MonumentRepository _monumentRepository;
  BookmarkMonumentsBloc(this._monumentRepository)
      : super(BookmarkMonumentsInitial()) {
    on<BookmarkMonument>(_mapBookmarkMonumentToState);
    on<UnbookmarkMonument>(_mapUnbookmarkMonumentToState);
    on<CheckIfMonumentIsBookmarked>(_mapCheckIfMonumentIsBookmarkedToState);
    on<GetBookmarkedMonuments>(_mapGetBookmarkedMonumentsToState);
  }

  Future<void> _mapBookmarkMonumentToState(
      BookmarkMonument event, Emitter<BookmarkMonumentsState> emit) async {
    try {
      await _monumentRepository.bookmarkMonument(event.monument.id);
      final bookmarkedMonuments =
          await _monumentRepository.getBookmarkedMonuments();
      final bookmarkedMonumentsEntities =
          bookmarkedMonuments.map((e) => e.toEntity()).toList();
      emit(BookmarkedMonumentsLoaded(bookmarkedMonumentsEntities));
    } catch (e) {
      emit(BookmarkedMonumentsErrorState('Failed to bookmark monument'));
    }
  }

  Future<void> _mapUnbookmarkMonumentToState(
      UnbookmarkMonument event, Emitter<BookmarkMonumentsState> emit) async {
    try {
      await _monumentRepository.unbookmarkMonument(event.monument.id);
      final bookmarkedMonuments =
          await _monumentRepository.getBookmarkedMonuments();
      final bookmarkedMonumentsEntities =
          bookmarkedMonuments.map((e) => e.toEntity()).toList();
      emit(BookmarkedMonumentsLoaded(bookmarkedMonumentsEntities));
    } catch (e) {
      emit(BookmarkedMonumentsErrorState('Failed to unbookmark monument'));
    }
  }

  Future<void> _mapCheckIfMonumentIsBookmarkedToState(
      CheckIfMonumentIsBookmarked event,
      Emitter<BookmarkMonumentsState> emit) async {
    try {
      final isBookmarked =
          await _monumentRepository.isMonumentBookmarked(event.monumentId);
      if (isBookmarked) {
        emit(MonumentAlreadyBookmarked(event.monumentId));
      } else {
        emit(MonumentNotBookmarked(event.monumentId));
      }
    } catch (e) {
      emit(BookmarkedMonumentsErrorState('Error checking bookmark status'));
    }
  }

  Future<void> _mapGetBookmarkedMonumentsToState(GetBookmarkedMonuments event,
      Emitter<BookmarkMonumentsState> emit) async {
    emit(BookmarkedMonumentsLoading());
    try {
      final bookmarkedMonuments =
          await _monumentRepository.getBookmarkedMonuments();
      final bookmarkedMonumentsEntities =
          bookmarkedMonuments.map((e) => e.toEntity()).toList();
      emit(BookmarkedMonumentsLoaded(bookmarkedMonumentsEntities));
    } catch (e) {
      emit(BookmarkedMonumentsErrorState('Failed to load bookmarked monuments'));
    }
  }
}


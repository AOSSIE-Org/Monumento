import 'package:bloc/bloc.dart';
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

  Future _mapBookmarkMonumentToState(
      BookmarkMonument event, Emitter<BookmarkMonumentsState> emit) async {
    await _monumentRepository.bookmarkMonument(event.monument.id);
    emit(MonumentBookmarked(event.monument.id));
  }

  Future _mapUnbookmarkMonumentToState(
      UnbookmarkMonument event, Emitter<BookmarkMonumentsState> emit) async {
    await _monumentRepository.unbookmarkMonument(event.monument.id);
    emit(MonumentUnbookmarked(event.monument.id));
  }

  Future _mapCheckIfMonumentIsBookmarkedToState(
      CheckIfMonumentIsBookmarked event,
      Emitter<BookmarkMonumentsState> emit) async {
    final isBookmarked =
        await _monumentRepository.isMonumentBookmarked(event.monumentId);
    if (isBookmarked) {
      emit(MonumentAlreadyBookmarked(event.monumentId));
    } else {
      emit(MonumentNotBookmarked(event.monumentId));
    }
  }

  Future _mapGetBookmarkedMonumentsToState(GetBookmarkedMonuments event,
      Emitter<BookmarkMonumentsState> emit) async {
    final bookmarkedMonuments =
        await _monumentRepository.getBookmarkedMonuments();

    final bookmarkedMonumentsEntities =
        bookmarkedMonuments.map((e) => e.toEntity()).toList();

    emit(BookmarkedMonumentsLoaded(bookmarkedMonumentsEntities));
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/monuments/models/bookmarked_monument_model.dart';
import 'package:monumento/resources/monuments/monument_repository.dart';

part 'bookmarked_monuments_event.dart';
part 'bookmarked_monuments_state.dart';

class BookmarkedMonumentsBloc
    extends Bloc<BookmarkedMonumentsEvent, BookmarkedMonumentsState> {
  MonumentRepository _firebaseMonumentRepository;

  BookmarkedMonumentsBloc(
      {@required MonumentRepository firebaseMonumentRepository})
      : assert(firebaseMonumentRepository != null),
        _firebaseMonumentRepository = firebaseMonumentRepository,
        super(BookmarkedMonumentsInitial());

  @override
  Stream<BookmarkedMonumentsState> mapEventToState(
    BookmarkedMonumentsEvent event,
  ) async* {
    if (event is RetrieveBookmarkedMonuments) {
      yield* _mapRetrieveBookmarkedMonumentsToState(userId: event.userId);
    } else if (event is UpdateBookmarkedMonuments) {
      yield* _mapUpdateBookmarkedMonumentsToState(
          monuments: event.updatedBookmarkedMonuments);
    }
  }

  Stream<BookmarkedMonumentsState> _mapRetrieveBookmarkedMonumentsToState(
      {String userId}) async* {
    _firebaseMonumentRepository.getBookmarkedMonuments(userId).listen((event) {
      add(UpdateBookmarkedMonuments(updatedBookmarkedMonuments: event));
    });
  }

  Stream<BookmarkedMonumentsState> _mapUpdateBookmarkedMonumentsToState(
      {List<BookmarkedMonumentModel> monuments}) async* {
    yield BookmarkedMonumentsRetrieved(bookmarkedMonuments: monuments);
  }
}

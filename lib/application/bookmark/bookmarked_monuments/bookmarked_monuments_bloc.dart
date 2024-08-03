import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/data/models/bookmarked_monument_model.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';

part 'bookmarked_monuments_event.dart';
part 'bookmarked_monuments_state.dart';

class BookmarkedMonumentsBloc
    extends Bloc<BookmarkedMonumentsEvent, BookmarkedMonumentsState> {
  final MonumentRepository _firebaseMonumentRepository;

  BookmarkedMonumentsBloc(this._firebaseMonumentRepository):super(BookmarkedMonumentsInitial()){
    on<RetrieveBookmarkedMonuments>(_mapRetrieveBookmarkedMonumentsToState);
    on<UpdateBookmarkedMonuments>(_mapUpdateBookmarkedMonumentsToState);
  }

  _mapRetrieveBookmarkedMonumentsToState(RetrieveBookmarkedMonuments event,Emitter<BookmarkedMonumentsState> emit) async{
    _firebaseMonumentRepository.getBookmarkedMonuments(event.userId).listen((event) {
      add(UpdateBookmarkedMonuments(updatedBookmarkedMonuments: event));
  });
  }

  _mapUpdateBookmarkedMonumentsToState(UpdateBookmarkedMonuments event, Emitter<BookmarkedMonumentsState> emit) async {
    emit(BookmarkedMonumentsRetrieved(bookmarkedMonuments: event.updatedBookmarkedMonuments));
  }
}

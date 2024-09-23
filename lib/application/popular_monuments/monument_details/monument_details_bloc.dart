import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/wiki_data_entity.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';

part 'monument_details_event.dart';
part 'monument_details_state.dart';

class MonumentDetailsBloc
    extends Bloc<MonumentDetailsEvent, MonumentDetailsState> {
  final MonumentRepository _monumentRepository;
  MonumentDetailsBloc(this._monumentRepository)
      : super(MonumentDetailsInitial()) {
    on<GetMonumentWikiDetails>(_mapGetMonumentWikiDetailsToState);
  }

  _mapGetMonumentWikiDetailsToState(
      GetMonumentWikiDetails event, Emitter<MonumentDetailsState> emit) async {
    try {
      emit(LoadingMonumentWikiDetails());
      var wikiData = await _monumentRepository
          .getMonumentWikiDetails(event.monumentWikiId);
      emit(MonumentWikiDetailsRetrieved(wikiData: wikiData.toEntity()));
    } catch (_) {
      emit(FailedToRetrieveMonumentWikiDetails());
    }
  }
}

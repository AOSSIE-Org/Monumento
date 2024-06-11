import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';

part 'popular_monuments_event.dart';
part 'popular_monuments_state.dart';

class PopularMonumentsBloc
    extends Bloc<PopularMonumentsEvent, PopularMonumentsState> {
  final MonumentRepository _monumentRepository;
  PopularMonumentsBloc(this._monumentRepository)
      : super(PopularMonumentsInitial()) {
    on<GetPopularMonuments>(_mapGetPopularMonumentsToState);
  }

  _mapGetPopularMonumentsToState(
      PopularMonumentsEvent event, Emitter<PopularMonumentsState> emit) async {
    try {
      emit(LoadingPopularMonuments());
      final List<MonumentModel> popularMonuments =
          await _monumentRepository.getPopularMonuments();
      emit(PopularMonumentsRetrieved(
          popularMonuments:
              popularMonuments.map((e) => e.toEntity()).toList()));
    } catch (_) {
      emit(FailedToRetrievePopularMonuments());
    }
  }
}

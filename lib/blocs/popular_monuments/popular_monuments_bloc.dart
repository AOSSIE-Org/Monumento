import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/monuments/models/monument_model.dart';
import 'package:monumento/resources/monuments/monument_repository.dart';

part 'popular_monuments_event.dart';
part 'popular_monuments_state.dart';

class PopularMonumentsBloc
    extends Bloc<PopularMonumentsEvent, PopularMonumentsState> {
  MonumentRepository _firebaseMonumentRepository;

  PopularMonumentsBloc(
      {@required MonumentRepository firebaseMonumentRepository})
      : assert(firebaseMonumentRepository != null),
        _firebaseMonumentRepository = firebaseMonumentRepository,
        super(PopularMonumentsInitial());

  @override
  Stream<PopularMonumentsState> mapEventToState(
    PopularMonumentsEvent event,
  ) async* {
    if (event is GetPopularMonuments) {
      yield* _mapGetPopularMonumentsToState();
    }
  }

  Stream<PopularMonumentsState> _mapGetPopularMonumentsToState() async* {
    try {
      final List<MonumentModel> popularMonuments =
          await _firebaseMonumentRepository.getPopularMonuments();
      yield PopularMonumentsRetrieved(popularMonuments: popularMonuments);
    } catch (_) {
      yield FailedToRetrievePopularMonuments();
    }
  }
}

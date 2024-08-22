import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/nearby_place_entity.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';

part 'nearby_places_event.dart';
part 'nearby_places_state.dart';

class NearbyPlacesBloc extends Bloc<NearbyPlacesEvent, NearbyPlacesState> {
  final MonumentRepository _monumentRepository;
  NearbyPlacesBloc(this._monumentRepository) : super(NearbyPlacesInitial()) {
    on<GetNearbyPlaces>((event, emit) async {
      try {
        emit(NearbyPlacesLoading());
        var res = await _monumentRepository.getPlacesNearby(
            event.latitude, event.longitude);
        var nearbyPlaces = res.map((e) => e.toEntity()).toList();
        emit(NearbyPlacesLoaded(nearbyPlaces: nearbyPlaces));
      } catch (e) {
        emit(NearbyPlacesError(message: e.toString()));
      }
    });
  }
}

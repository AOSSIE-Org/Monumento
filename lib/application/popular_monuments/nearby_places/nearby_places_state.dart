part of 'nearby_places_bloc.dart';

sealed class NearbyPlacesState extends Equatable {
  const NearbyPlacesState();

  @override
  List<Object> get props => [];
}

final class NearbyPlacesInitial extends NearbyPlacesState {}

final class NearbyPlacesLoading extends NearbyPlacesState {}

final class NearbyPlacesLoaded extends NearbyPlacesState {
  final List<NearbyPlaceEntity> nearbyPlaces;

  const NearbyPlacesLoaded({
    required this.nearbyPlaces,
  });

  @override
  List<Object> get props => [nearbyPlaces];
}

final class NearbyPlacesError extends NearbyPlacesState {
  final String message;

  const NearbyPlacesError({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

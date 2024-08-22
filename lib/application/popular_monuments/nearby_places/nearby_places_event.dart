part of 'nearby_places_bloc.dart';

sealed class NearbyPlacesEvent extends Equatable {
  const NearbyPlacesEvent();

  @override
  List<Object> get props => [];
}

class GetNearbyPlaces extends NearbyPlacesEvent {
  final double latitude;
  final double longitude;

  const GetNearbyPlaces({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

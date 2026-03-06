import 'dart:math';
import 'package:monumento/domain/entities/nearby_place_entity.dart';

class NearbyPlacesDistanceCalculator {
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371;

    final double latDistance = _degreesToRadians(lat2 - lat1);
    final double lonDistance = _degreesToRadians(lon2 - lon1);

    final double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(lonDistance / 2) *
            sin(lonDistance / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  static List<NearbyPlaceEntity> sortPlacesByDistance(
      List<NearbyPlaceEntity> places,
      double referenceLatitude,
      double referenceLongitude) {
    final List<MapEntry<NearbyPlaceEntity, double>> placesWithDistances =
        places.map((place) {
      final double distance = calculateDistance(referenceLatitude,
          referenceLongitude, place.latitude, place.longitude);
      return MapEntry(place, distance);
    }).toList();

    placesWithDistances.sort((a, b) => a.value.compareTo(b.value));

    return placesWithDistances.map((entry) => entry.key).toList();
  }

  static String getFormattedDistance(
      double placeLatitude,
      double placeLongitude,
      double referenceLatitude,
      double referenceLongitude) {
    final double distance = calculateDistance(
        referenceLatitude, referenceLongitude, placeLatitude, placeLongitude);

    if (distance < 1) {
      final int meters = (distance * 1000).round();
      return "$meters m";
    } else {
      return "${distance.toStringAsFixed(1)} km";
    }
  }
}

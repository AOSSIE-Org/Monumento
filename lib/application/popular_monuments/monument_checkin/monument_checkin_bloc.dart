import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'monument_checkin_event.dart';
part 'monument_checkin_state.dart';

class MonumentCheckinBloc
    extends Bloc<MonumentCheckinEvent, MonumentCheckinState> {
  final SocialRepository _socialRepository;
  MonumentCheckinBloc(this._socialRepository)
      : super(MonumentCheckinInitial()) {
    on<CheckinMonument>(_mapCheckinMonumentToState);
    on<CheckIfMonumentIsCheckedIn>(_mapCheckIfMonumentIsCheckedInToState);
  }

  Future<void> _mapCheckinMonumentToState(
      CheckinMonument event, Emitter<MonumentCheckinState> emit) async {
    try {
      emit(MonumentCheckinLoading());
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const MonumentCheckinFailure(
            message: "Location services are disabled"));
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          emit(const MonumentCheckinFailure(
              message:
                  "Location permissions are permanently denied, we cannot request permissions."));
          return;
        }
        if (permission == LocationPermission.denied) {
          emit(const MonumentCheckinFailure(
              message: "Location permissions are denied"));
          return;
        }
      }
      var position = await Geolocator.getCurrentPosition();

      double distance = calculateDistance(position.latitude, position.longitude,
          event.monument.coordinates[0], event.monument.coordinates[1]);
      if (distance < 200) {
        emit(const MonumentCheckinFailure(
            message: "You are not close enough to check in"));
        return;
      }

      if (await _socialRepository.checkInStatus(
          monumentId: event.monument.id)) {
        emit(const MonumentCheckinFailure(message: "Already checked in"));
        return;
      }
      await _socialRepository.monumentCheckIn(monumentId: event.monument.id);
      emit(MonumentCheckinSuccess());
    } catch (e) {
      emit(MonumentCheckinFailure(message: e.toString()));
    }
  }

  Future<void> _mapCheckIfMonumentIsCheckedInToState(
      CheckIfMonumentIsCheckedIn event,
      Emitter<MonumentCheckinState> emit) async {
    try {
      emit(MonumentCheckinLoading());

      bool isCheckedIn =
          await _socialRepository.checkInStatus(monumentId: event.monument.id);

      if (isCheckedIn) {
        emit(MonumentCheckedIn());
      } else {
        emit(MonumentNotCheckedIn());
      }
    } catch (e) {
      emit(MonumentCheckinFailure(message: e.toString()));
    }
  }
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  // Radius of the Earth in meters
  const double earthRadius = 6371000;

  // Convert latitude and longitude from degrees to radians
  double dLat = (lat2 - lat1) * pi / 180;
  double dLon = (lon2 - lon1) * pi / 180;

  // Haversine formula for calculating distance
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  // Distance in meters using the Earth's radius
  double distance = earthRadius * c;
  // Return the calculated distance
  return distance;
}

// Function to check if a coordinate is within a certain range (in meters) of another coordinate
bool isWithinRange(
    double lat1, double lon1, double lat2, double lon2, double rangeInMeters) {
  double distance = calculateDistance(lat1, lon1, lat2, lon2);
  return distance <= rangeInMeters;
}

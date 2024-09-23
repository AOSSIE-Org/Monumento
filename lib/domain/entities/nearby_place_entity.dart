import 'package:equatable/equatable.dart';
import 'package:monumento/utils/enums.dart';

class NearbyPlaceEntity extends Equatable {
  final String name;
  final double longitude;
  final double latitude;
  final String address;
  final FeatureType featureType;

  const NearbyPlaceEntity({
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.address,
    required this.featureType,
  });

  @override
  List<Object?> get props => [
        name,
        longitude,
        latitude,
        address,
        featureType,
      ];
}

import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/domain/entities/nearby_place_entity.dart';
import 'package:monumento/utils/enums.dart';

part 'nearby_place_model.g.dart';

@JsonSerializable(explicitToJson: true)
class NearbyPlaceModel {
  final String name;
  @JsonKey(name: 'lon')
  final double longitude;
  @JsonKey(name: 'lat')
  final double latitude;
  @JsonKey(name: 'formatted')
  final String address;
  @JsonKey(name: 'feature_type')
  final FeatureType featureType;

  NearbyPlaceModel({
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.address,
    required this.featureType,
  });

  factory NearbyPlaceModel.fromJson(Map<String, dynamic> json) {
    return _$NearbyPlaceModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NearbyPlaceModelToJson(this);

  NearbyPlaceEntity toEntity() {
    return NearbyPlaceEntity(
      name: name,
      longitude: longitude,
      latitude: latitude,
      address: address,
      featureType: featureType,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NearbyPlaceModel _$NearbyPlaceModelFromJson(Map<String, dynamic> json) =>
    NearbyPlaceModel(
      name: json['name'] as String,
      longitude: (json['lon'] as num).toDouble(),
      latitude: (json['lat'] as num).toDouble(),
      address: json['formatted'] as String,
      featureType: $enumDecode(_$FeatureTypeEnumMap, json['feature_type']),
    );

Map<String, dynamic> _$NearbyPlaceModelToJson(NearbyPlaceModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'lon': instance.longitude,
      'lat': instance.latitude,
      'formatted': instance.address,
      'feature_type': _$FeatureTypeEnumMap[instance.featureType]!,
    };

const _$FeatureTypeEnumMap = {
  FeatureType.restaurant: 'restaurant',
  FeatureType.toilet: 'toilet',
  FeatureType.hotel: 'hotel',
  FeatureType.atm: 'atm',
  FeatureType.supermarket: 'supermarket',
  FeatureType.pharmacy: 'pharmacy',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monument_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonumentModel _$MonumentModelFromJson(Map<String, dynamic> json) =>
    MonumentModel(
      rating: (json['rating'] as num).toDouble(),
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      id: json['id'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      imageUrl: json['image'] as String,
      image_1x1_: json['image_1x1_'] as String,
      name: json['name'] as String,
      wiki: json['wikipediaLink'] as String,
      wikiPageId: json['wikiPageId'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MonumentModelToJson(MonumentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'country': instance.country,
      'image': instance.imageUrl,
      'image_1x1_': instance.image_1x1_,
      'wikipediaLink': instance.wiki,
      'wikiPageId': instance.wikiPageId,
      'rating': instance.rating,
      'coordinates': instance.coordinates,
      'images': instance.images,
    };

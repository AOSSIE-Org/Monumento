import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/domain/entities/monument_entity.dart';

part 'monument_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MonumentModel {
  final String id;
  final String name;
  final String city;
  final String country;
  @JsonKey(name: 'image')
  final String imageUrl;
  final String image_1x1_;
  @JsonKey(name: 'wikipediaLink')
  final String wiki;
  final String wikiPageId;
  final double rating;
  final List<double> coordinates;
  final List<String> images;
  final String? modelLink;
  final bool has3DModel;

  const MonumentModel({
    this.modelLink,
    required this.rating,
    required this.coordinates,
    required this.id,
    required this.city,
    required this.country,
    required this.imageUrl,
    required this.image_1x1_,
    required this.name,
    required this.wiki,
    required this.wikiPageId,
    this.images = const [],
    this.has3DModel = false,
  });

  factory MonumentModel.fromJson(Map<String, dynamic> json) {
    return _$MonumentModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MonumentModelToJson(this);

  factory MonumentModel.fromEntity(MonumentEntity entity) {
    return MonumentModel(
      id: entity.id,
      name: entity.name,
      city: entity.city,
      country: entity.country,
      imageUrl: entity.imageUrl,
      image_1x1_: entity.image_1x1_,
      wiki: entity.wiki,
      rating: entity.rating,
      coordinates: entity.coordinates,
      wikiPageId: entity.wikiPageId,
    );
  }

  MonumentEntity toEntity() {
    return MonumentEntity(
      id: id,
      name: name,
      city: city,
      country: country,
      imageUrl: imageUrl,
      image_1x1_: image_1x1_,
      wiki: wiki,
      rating: rating,
      coordinates: coordinates,
      wikiPageId: wikiPageId,
      images: images,
      modelLink: modelLink,
      has3DModel: has3DModel,
    );
  }

  factory MonumentModel.fromMap(Map<String, Object> data) {
    return MonumentModel(
      rating: data['rating'] as double,
      coordinates: (data['coordinates'] as List).map<double>((e) => e).toList(),
      id: data['id'] as String,
      city: data['city'] as String,
      country: data['country'] as String,
      imageUrl: data['imageUrl'] as String,
      image_1x1_: data['image_1x1_'] as String,
      name: data['name'] as String,
      wiki: data['wiki'] as String,
      wikiPageId: data['wikiPageId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'coordinates': coordinates,
      'id': id,
      'city': city,
      'country': country,
      'imageUrl': imageUrl,
      'image_1x1_': image_1x1_,
      'name': name,
      'wiki': wiki,
      'wikiPageId': wikiPageId,
    };
  }
}

import 'package:equatable/equatable.dart';

import 'local_expert_entity.dart';

class MonumentEntity extends Equatable {
  final String id;
  final String name;
  final String city;
  final String country;
  final String imageUrl;
  final String image_1x1_;
  final String wiki;
  final double rating;
  final List<double> coordinates;
  final String wikiPageId;
  final List<String> images;
  final bool has3DModel;
  final String? modelLink;
  final List<LocalExpertEntity> localExperts;

  const MonumentEntity({
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
    this.modelLink,
    this.localExperts = const [],
  });

  /// Creates a [MonumentEntity] from an Appwrite document
  factory MonumentEntity.fromDocument(Map<String, dynamic> document) {
    // Handle empty or null values
    final coordinates = document['coordinates'] as List<dynamic>?;
    final images = document['images'] as List<dynamic>?;

    return MonumentEntity(
      id: document['\$id'] ?? '',
      name: document['name'] ?? '',
      city: document['city'] ?? '',
      country: document['country'] ?? '',
      imageUrl: document['image'] ?? '', 
      image_1x1_: document['image_1x1_'] ?? '',
      wiki: document['wikipediaLink'] ?? '',
      rating: (document['rating'] ?? 0.0).toDouble(),
      coordinates: coordinates != null
          ? coordinates.map<double>((e) => (e ?? 0.0).toDouble()).toList()
          : [],
      wikiPageId: document['wikiPageId'] ?? '',
      images: images != null
          ? images.map<String>((e) => e.toString()).toList()
          : [],
      has3DModel: document['has3DModel'] ?? false,
      modelLink: document['modelLink'],
      localExperts: const [],
    );
  }

  @override
  List<Object?> get props => [
        rating,
        coordinates,
        id,
        city,
        country,
        imageUrl,
        image_1x1_,
        name,
        wiki,
        wikiPageId,
        images,
        has3DModel,
        modelLink,
        localExperts,
      ];
}

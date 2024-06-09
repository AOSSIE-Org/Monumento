import 'package:equatable/equatable.dart';

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
  });

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
      ];
}

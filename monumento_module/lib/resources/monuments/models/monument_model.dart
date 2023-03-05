import 'package:meta/meta.dart';
import 'package:monumento/resources/monuments/entities/monument_entity.dart';

class MonumentModel {
  final String id;
  final String name;
  final String city;
  final String country;
  final String imageUrl;
  final String wiki;

  MonumentModel(
      {this.id,
      this.city,
      this.country,
      this.imageUrl,
      this.name,
      @required this.wiki});

  MonumentModel copyWith() {
    return MonumentModel(
        id: id,
        name: name,
        city: city,
        country: country,
        wiki: wiki,
        imageUrl: imageUrl);
  }

  MonumentEntity toEntity() {
    return MonumentEntity(
        id: id,
        name: name,
        city: city,
        country: country,
        wiki: wiki,
        imageUrl: imageUrl);
  }

  static MonumentModel fromEntity(MonumentEntity monumentEntity) {
    return MonumentModel(
        id: monumentEntity.id,
        name: monumentEntity.name,
        city: monumentEntity.city,
        country: monumentEntity.country,
        wiki: monumentEntity.wiki,
        imageUrl: monumentEntity.imageUrl);
  }
}

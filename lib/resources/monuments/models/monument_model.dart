import 'package:meta/meta.dart';
import 'package:monumento/resources/monuments/entities/monument_entity.dart';

class MonumentModel {
  final String id;
  final String name;
  final String city;
  final String country;
  final String imageUrl;
  final String image_1x1_;
  final String wiki;

  MonumentModel(
      {this.id,
      this.city,
      this.country,
      this.imageUrl,
      this.image_1x1_,
      this.name,
      @required this.wiki});

  MonumentModel copyWith() {
    return MonumentModel(
        id: id,
        name: name,
        city: city,
        country: country,
        wiki: wiki,
        image_1x1_: image_1x1_,
        imageUrl: imageUrl);
  }

  MonumentEntity toEntity() {
    return MonumentEntity(
        id: id,
        name: name,
        city: city,
        country: country,
        wiki: wiki,
        image_1x1_: image_1x1_,
        imageUrl: imageUrl);
  }

  static MonumentModel fromEntity(MonumentEntity monumentEntity) {
    return MonumentModel(
        id: monumentEntity.id,
        name: monumentEntity.name,
        city: monumentEntity.city,
        country: monumentEntity.country,
        wiki: monumentEntity.wiki,
        image_1x1_: monumentEntity.image_1x1_,
        imageUrl: monumentEntity.imageUrl);

  }
}

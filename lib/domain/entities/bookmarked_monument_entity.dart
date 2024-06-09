import 'package:equatable/equatable.dart';

import 'monument_entity.dart';

class BookmarkedMonumentEntity extends Equatable {
  final String bookmarkedByUid;
  final MonumentEntity monumentEntity;

  const BookmarkedMonumentEntity(
      {required this.bookmarkedByUid, required this.monumentEntity});

  @override
  List<Object> get props => [bookmarkedByUid, monumentEntity.id];

  Map<String, Object> toMap() {
    return {
      'bookmarkedByUid': bookmarkedByUid,
    };
  }

  BookmarkedMonumentEntity fromJson(Map<String, dynamic> source) {
    return BookmarkedMonumentEntity(
      bookmarkedByUid: source['bookmarkedByUid'],
      monumentEntity: MonumentEntity(
        id: source['id'],
        name: source['name'],
        city: source['city'],
        country: source['country'],
        imageUrl: source['image'],
        image_1x1_: '',
        wiki: '',
        rating: source['rating'],
        coordinates: source['coordinates'],
        wikiPageId: source['wikiPageId'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookmarkedByUid': bookmarkedByUid,
      'id': monumentEntity.id,
      'name': monumentEntity.name,
      'city': monumentEntity.city,
      'country': monumentEntity.country,
      'image': monumentEntity.imageUrl,
    };
  }
}

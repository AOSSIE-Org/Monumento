import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/resources/monuments/entities/monument_entity.dart';

class BookmarkedMonumentEntity extends Equatable {
  final String bookmarkedByUid;
  final MonumentEntity monumentEntity;

  BookmarkedMonumentEntity({this.bookmarkedByUid, this.monumentEntity});

  @override
  List<Object> get props => [bookmarkedByUid, monumentEntity.id];

  Map<String, Object> toJson() {
    return {
      'bookmarkedByUid': bookmarkedByUid,
      'id': monumentEntity.id,
      'name': monumentEntity.name,
      'city': monumentEntity.city,
      'country': monumentEntity.country,
      'image': monumentEntity.imageUrl,
    };
  }

  static BookmarkedMonumentEntity fromJson(Map<String, Object> json) {
    return BookmarkedMonumentEntity(
        monumentEntity: MonumentEntity.fromJson(json),
        bookmarkedByUid: json['bookmarkedByUid']);
  }

  static BookmarkedMonumentEntity fromSnapshot(DocumentSnapshot snap) {
    return BookmarkedMonumentEntity(
        bookmarkedByUid: snap.data['bookmarkedByUid'],
        monumentEntity: MonumentEntity.fromSnapshot(snap));
  }

  Map<String, Object> toDocument() {
    return {
      'bookmarkedByUid':bookmarkedByUid,
      'id': monumentEntity.id,
      'name': monumentEntity.name,
      'city': monumentEntity.city,
      'country': monumentEntity.country,
      'image': monumentEntity.imageUrl,
    };
  }
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/resources/monuments/entities/monument_entity.dart';

class BookmarkedMonumentEntity extends Equatable {
  final String bookmarkedByUid;
  final MonumentEntity monumentEntity;

  BookmarkedMonumentEntity({this.bookmarkedByUid, this.monumentEntity});

  @override
  List<Object> get props => [bookmarkedByUid, monumentEntity.id];

  Map<String, Object> toMap() {
    return {
      'bookmarkedByUid': bookmarkedByUid,
      'id': monumentEntity.id,
      'name': monumentEntity.name,
      'city': monumentEntity.city,
      'country': monumentEntity.country,
      'image': monumentEntity.imageUrl,
    };
  }

  factory BookmarkedMonumentEntity.fromMap(Map<String, Object> data) {
    return BookmarkedMonumentEntity(
        monumentEntity: MonumentEntity.fromMap(data),
        bookmarkedByUid: data['bookmarkedByUid']);
  }

  factory BookmarkedMonumentEntity.fromSnapshot(DocumentSnapshot snap) {
    final Map<String, dynamic> data = snap.data();

    return BookmarkedMonumentEntity(
        bookmarkedByUid: data['bookmarkedByUid'],
        monumentEntity: MonumentEntity.fromSnapshot(snap));
  }

  BookmarkedMonumentEntity fromJson(String source) =>
      BookmarkedMonumentEntity.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}

import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/domain/entities/bookmarked_monument_entity.dart';

import 'monument_model.dart';

part 'bookmarked_monument_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BookmarkedMonumentModel {
  final String bookmarkedByUid;
  final MonumentModel monumentModel;

  BookmarkedMonumentModel(
      {required this.bookmarkedByUid, required this.monumentModel});

  BookmarkedMonumentModel copyWith() {
    return BookmarkedMonumentModel(
        bookmarkedByUid: bookmarkedByUid, monumentModel: monumentModel);
  }

  factory BookmarkedMonumentModel.fromJson(Map<String, dynamic> json) {
    return _$BookmarkedMonumentModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BookmarkedMonumentModelToJson(this);

  BookmarkedMonumentEntity toEntity() {
    return BookmarkedMonumentEntity(
        bookmarkedByUid: bookmarkedByUid,
        monumentEntity: monumentModel.toEntity());
  }

  static BookmarkedMonumentModel fromEntity(
      BookmarkedMonumentEntity bookmarkedMonumentEntity) {
    return BookmarkedMonumentModel(
      bookmarkedByUid: bookmarkedMonumentEntity.bookmarkedByUid,
      monumentModel:
          MonumentModel.fromEntity(bookmarkedMonumentEntity.monumentEntity),
    );
  }
}

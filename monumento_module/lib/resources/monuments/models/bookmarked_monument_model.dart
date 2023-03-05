import 'package:monumento/resources/monuments/entities/bookmarked_monument_entity.dart';
import 'package:monumento/resources/monuments/models/monument_model.dart';

class BookmarkedMonumentModel {
  final String bookmarkedByUid;
  final MonumentModel monumentModel;

  BookmarkedMonumentModel({this.bookmarkedByUid, this.monumentModel});

  BookmarkedMonumentModel copyWith() {
    return BookmarkedMonumentModel(
        bookmarkedByUid: bookmarkedByUid, monumentModel: monumentModel);
  }

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
            MonumentModel.fromEntity(bookmarkedMonumentEntity.monumentEntity));
  }
}

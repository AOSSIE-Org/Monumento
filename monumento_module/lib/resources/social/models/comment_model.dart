import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/entities/comment_entity.dart';

class CommentModel {
  final String comment;
  final String postInvolvedId;
  final UserModel author;
  final int timeStamp;
  final DocumentSnapshot snapshot;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const CommentModel({
    @required this.comment,
    @required this.postInvolvedId,
    @required this.author,
    @required this.timeStamp,
    @required this.snapshot,
  });

  CommentModel copyWith({
    String comment,
    String postInvolvedId,
    UserModel author,
    int timeStamp,
    DocumentSnapshot snapshot,
  }) {
    return new CommentModel(
      comment: comment ?? this.comment,
      postInvolvedId: postInvolvedId ?? this.postInvolvedId,
      author: author ?? this.author,
      timeStamp: timeStamp ?? this.timeStamp,
      snapshot: snapshot ?? this.snapshot,
    );
  }

  @override
  String toString() {
    return 'CommentModel{comment: $comment, postInvolvedId: $postInvolvedId, author: $author, timeStamp: $timeStamp, snapshot: $snapshot}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentModel &&
          runtimeType == other.runtimeType &&
          comment == other.comment &&
          postInvolvedId == other.postInvolvedId &&
          author == other.author &&
          timeStamp == other.timeStamp &&
          snapshot == other.snapshot);

  @override
  int get hashCode =>
      comment.hashCode ^
      postInvolvedId.hashCode ^
      author.hashCode ^
      timeStamp.hashCode ^
      snapshot.hashCode;

  factory CommentModel.fromEntity(
      {@required CommentEntity entity, DocumentSnapshot snapshot}) {
    return new CommentModel(
      comment: entity.comment,
      postInvolvedId: entity.postInvolvedId,
      author: UserModel.fromEntity(userEntity: entity.author),
      timeStamp: entity.timeStamp,
      snapshot: snapshot,
    );
  }

  CommentEntity toEntity() {
    return CommentEntity(
        comment: comment,
        postInvolvedId: postInvolvedId,
        author: author.toEntity(),
        timeStamp: timeStamp);
  }
}

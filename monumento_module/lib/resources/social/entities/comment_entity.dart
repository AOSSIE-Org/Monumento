import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';

class CommentEntity {
  final String comment;
  final String postInvolvedId;
  final UserEntity author;
  final int timeStamp;

  const CommentEntity({
    @required this.comment,
    @required this.postInvolvedId,
    @required this.author,
    @required this.timeStamp,
  });

  CommentEntity copyWith({
    String comment,
    String postInvolvedId,
    UserEntity author,
    int timeStamp,
  }) {
    return new CommentEntity(
      comment: comment ?? this.comment,
      postInvolvedId: postInvolvedId ?? this.postInvolvedId,
      author: author ?? this.author,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }

  @override
  String toString() {
    return 'CommentEntity{comment: $comment, postInvolvedId: $postInvolvedId, author: $author, timeStamp: $timeStamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentEntity &&
          runtimeType == other.runtimeType &&
          comment == other.comment &&
          postInvolvedId == other.postInvolvedId &&
          author == other.author &&
          timeStamp == other.timeStamp);

  @override
  int get hashCode =>
      comment.hashCode ^
      postInvolvedId.hashCode ^
      author.hashCode ^
      timeStamp.hashCode;

  factory CommentEntity.fromMap(Map<String, dynamic> map) {
    return new CommentEntity(
      comment: map['comment'] as String,
      postInvolvedId: map['postInvolvedId'] as String,
      author: map['author'] as UserEntity,
      timeStamp: map['timeStamp'] as int,
    );
  }

  factory CommentEntity.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    return new CommentEntity(
      comment: data['comment'] as String,
      postInvolvedId: data['postInvolvedId'] as String,
      author: UserEntity.fromMap(data['author']),
      timeStamp: data['timeStamp'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'comment': this.comment,
      'postInvolvedId': this.postInvolvedId,
      'author': this.author.toMap(),
      'timeStamp': this.timeStamp,
    };
  }
}

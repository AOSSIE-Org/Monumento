import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/domain/entities/comment_entity.dart';

import 'user_model.dart';

part 'comment_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CommentModel {
  final String comment;
  final String commentDocId;
  final String postInvolvedId;
  final UserModel author;
  final int timeStamp;

  CommentModel({
    required this.comment,
    required this.postInvolvedId,
    required this.author,
    required this.timeStamp,
    required this.commentDocId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  CommentEntity toEntity() {
    return CommentEntity(
      comment: comment,
      postInvolvedId: postInvolvedId,
      author: author.toEntity(),
      timeStamp: timeStamp,
      commentDocId: commentDocId,
    );
  }
}

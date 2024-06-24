// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      comment: json['comment'] as String,
      postInvolvedId: json['postInvolvedId'] as String,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      timeStamp: (json['timeStamp'] as num).toInt(),
      commentDocId: json['commentDocId'] as String,
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'commentDocId': instance.commentDocId,
      'postInvolvedId': instance.postInvolvedId,
      'author': instance.author.toJson(),
      'timeStamp': instance.timeStamp,
    };

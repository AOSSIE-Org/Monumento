// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      postId: json[r'$id'] as String,
      postType: (json['postType'] as num?)?.toInt() ?? 0,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      isPostLiked: json['isPostLiked'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      title: json['title'] as String,
      location: json['location'] as String?,
      timeStamp: DateTime.parse(json['timeStamp'] as String),
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      postByUid: json['postByUid'] as String,
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      r'$id': instance.postId,
      'imageUrl': instance.imageUrl,
      'title': instance.title,
      'location': instance.location,
      'timeStamp': instance.timeStamp.toIso8601String(),
      'author': instance.author.toJson(),
      'postByUid': instance.postByUid,
      'likesCount': instance.likesCount,
      'postType': instance.postType,
      'commentsCount': instance.commentsCount,
      'isPostLiked': instance.isPostLiked,
    };

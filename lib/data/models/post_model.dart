import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/domain/entities/post_entity.dart';

import 'user_model.dart';

part 'post_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PostModel {
  final String postId;
  final String? imageUrl;
  final String title;
  final String location;
  final int timeStamp;
  final UserModel author;
  final String postByUid;
  final int? likesCount;
  final int? postType;
  final int? commentsCount;
  final bool? isPostLiked;

  PostModel({
    required this.postId,
    this.postType = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPostLiked = false,
    this.imageUrl,
    required this.title,
    required this.location,
    required this.timeStamp,
    required this.author,
    required this.postByUid,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return _$PostModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      postId: entity.postId,
      imageUrl: entity.imageUrl,
      title: entity.title,
      location: entity.location,
      timeStamp: entity.timeStamp,
      author: UserModel.fromEntity(entity.author),
      postByUid: entity.postByUid,
      likesCount: entity.likesCount,
      postType: entity.postType,
      commentsCount: entity.commentsCount,
      isPostLiked: entity.isPostLiked,
    );
  }

  PostEntity toEntity() {
    return PostEntity(
      postId: postId,
      imageUrl: imageUrl,
      title: title,
      location: location,
      timeStamp: timeStamp,
      author: author.toEntity(),
      postByUid: postByUid,
      likesCount: likesCount,
      postType: postType,
      commentsCount: commentsCount,
      isPostLiked: isPostLiked,
    );
  }
}

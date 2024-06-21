import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/user_entity.dart';

class PostEntity extends Equatable {
  final String postId;
  final String? imageUrl;
  final String title;
  final String location;
  final int timeStamp;
  final UserEntity author;
  final String postByUid;
  final int? likesCount;
  final int? postType;
  final int? commentsCount;
  final bool? isPostLiked;

  const PostEntity({
    required this.postId,
    this.imageUrl,
    this.postType = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPostLiked = false,
    required this.title,
    required this.location,
    required this.timeStamp,
    required this.author,
    required this.postByUid,
  });

  // update fields of the post
  PostEntity copyWith({
    String? imageUrl,
    String? title,
    String? location,
    int? timeStamp,
    UserEntity? author,
    String? postByUid,
    int? likesCount,
    int? postType,
    int? commentsCount,
    bool? isPostLiked,
  }) {
    return PostEntity(
      postId: postId,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      location: location ?? this.location,
      timeStamp: timeStamp ?? this.timeStamp,
      author: author ?? this.author,
      postByUid: postByUid ?? this.postByUid,
      likesCount: likesCount ?? this.likesCount,
      postType: postType ?? this.postType,
      commentsCount: commentsCount ?? this.commentsCount,
      isPostLiked: isPostLiked ?? this.isPostLiked,
    );
  }

  @override
  List<Object?> get props => [
        postId,
        imageUrl,
        title,
        location,
        timeStamp,
        author,
        postByUid,
        likesCount,
        postType,
        commentsCount,
        isPostLiked
      ];
}

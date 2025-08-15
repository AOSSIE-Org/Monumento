import 'package:appwrite/models.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/user_entity.dart';

class PostEntity extends Equatable {
  final String postId;
  final String? imageUrl;
  final String title;
  final String? location;
  final DateTime timeStamp;
  final UserEntity author;
  final String postByUid;
  final int? likesCount;
  final int? postType;
  final int? commentsCount;
  final bool? isPostLiked;
  final bool? isFromCommunity;
  final String? communityId;

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
    this.isFromCommunity = false,
    this.communityId,
  });

  /// Creates a [PostEntity] from an Appwrite document
  factory PostEntity.fromDocument(Document document, {UserEntity? author}) {
    final data = document.data;
    // Convert timestamp from DateTime to int (milliseconds since epoch)
    final timestamp = data['timeStamp'] != null
        ? DateTime.parse(data['timeStamp'])
        : DateTime.now();

    return PostEntity(
      postId: data['\$id'] ?? '',
      title: data['title'] ?? '',
      location: data['location'],
      imageUrl: data['imageUrl'],
      timeStamp: timestamp,
      postByUid: data['postByUid'] ?? '',
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      postType: data['postType'] ?? 0,
      author: author ?? UserEntity.fromMap(data['author']),
      isPostLiked: false, // Default value as it's not stored in the document
      isFromCommunity: data['isFromCommunity'] == 1 ? true : false,
      communityId: data['communityId'],
    );
  }

  // update fields of the post
  PostEntity copyWith({
    String? imageUrl,
    String? title,
    String? location,
    DateTime? timeStamp,
    UserEntity? author,
    String? postByUid,
    int? likesCount,
    int? postType,
    int? commentsCount,
    bool? isPostLiked,
    bool? isFromCommunity,
    String? communityId,
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
      isFromCommunity: isFromCommunity ?? this.isFromCommunity,
      communityId: communityId ?? this.communityId,
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
        isPostLiked,
        isFromCommunity,
        communityId,
      ];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/entities/post_entity.dart';

class PostModel {
  final String postId;
  final String imageUrl;
  final String title;
  final String location;
  final int timeStamp;
  final DocumentSnapshot documentSnapshot;
  final UserModel author;
  final String postByUid;

  PostModel(
      {@required this.postId,
      @required this.imageUrl,
      @required this.title,
      @required this.location,
      @required this.timeStamp,
      @required this.documentSnapshot,
      @required this.author,
      @required this.postByUid});

  PostModel copyWith(
      {String postId,
      String imageUrl,
      String title,
      String location,
      int timeStamp,
      DocumentSnapshot documentSnapshot,
      UserModel author,
      String postByUid}) {
    return PostModel(
        postId: postId ?? this.postId,
        imageUrl: imageUrl ?? this.imageUrl,
        title: title ?? this.title,
        location: location ?? this.location,
        timeStamp: timeStamp ?? this.timeStamp,
        documentSnapshot: documentSnapshot ?? this.documentSnapshot,
        author: author ?? this.author,
        postByUid: postByUid ?? this.postByUid);
  }

  PostEntity toEntity() {
    return PostEntity(
        postByUid: postByUid,
        postId: postId,
        imageUrl: imageUrl,
        title: title,
        location: location,
        timeStamp: timeStamp,
        author: author.toEntity());
  }

  factory PostModel.fromEntity(
      {@required PostEntity entity, DocumentSnapshot documentSnapshot}) {
    return PostModel(
        postId: entity.postId,
        imageUrl: entity.imageUrl,
        title: entity.title,
        location: entity.location,
        timeStamp: entity.timeStamp,
        documentSnapshot: documentSnapshot,
        author: UserModel.fromEntity(userEntity: entity.author),
        postByUid: entity.postByUid);
  }

  @override
  String toString() {
    return 'PostModel(postId: $postId, imageUrl: $imageUrl, title: $title, location: $location, timeStamp: $timeStamp, author: $author, postByUid: $postByUid)';
  }
}

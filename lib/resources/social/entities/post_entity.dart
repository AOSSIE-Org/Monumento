import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';

class PostEntity {
  final String postId;
  final String imageUrl;
  final String title;
  final String location;
  final int timeStamp;
  final UserEntity author;
  final String postByUid;
  PostEntity(
      {@required this.postId,
      @required this.imageUrl,
      @required this.title,
      @required this.location,
      @required this.timeStamp,
      @required this.author,
      @required this.postByUid});

  PostEntity copyWith(
      {String postId,
      String imageUrl,
      String title,
      String location,
      int timeStamp,
      UserEntity author,
      String postByUid}) {
    return PostEntity(
        postId: postId ?? this.postId,
        imageUrl: imageUrl ?? this.imageUrl,
        title: title ?? this.title,
        location: location ?? this.location,
        timeStamp: timeStamp ?? this.timeStamp,
        author: author ?? this.author,
        postByUid: postByUid ?? this.postByUid);
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'imageUrl': imageUrl,
      'title': title,
      'location': location,
      'timeStamp': timeStamp,
      'author': author.toMap(),
      'postByUid': postByUid
    };
  }

  factory PostEntity.fromSnapshot(DocumentSnapshot docSnap) {
    final Map<String, dynamic> data = docSnap.data();
    return PostEntity(
        postId: docSnap.id,
        imageUrl: data["imageUrl"],
        title: data["title"],
        location: data["location"],
        timeStamp: data["timeStamp"],
        author: UserEntity.fromMap(data["author"]),
        postByUid: data["postByUid"]);
  }

  factory PostEntity.fromMap(Map<String, dynamic> map) {
    return PostEntity(
        postId: map['postId'],
        imageUrl: map['imageUrl'],
        title: map['title'],
        location: map['location'],
        timeStamp: map['timeStamp'],
        author: UserEntity.fromMap(map['author']),
        postByUid: map['postByUid']);
  }

  String toJson() => json.encode(toMap());

  factory PostEntity.fromJson(String source) =>
      PostEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PostEntity(postId: $postId, imageUrl: $imageUrl, title: $title, location: $location, timeStamp $timeStamp,, author: $author, postBYUid : $postByUid)';
  }
}

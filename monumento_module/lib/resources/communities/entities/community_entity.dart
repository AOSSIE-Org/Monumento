import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommunityEntity extends Equatable {
  final String communityId;
  final String monumentId;
  final String monumentName;
  final String imageUrl;

  CommunityEntity(
      {
        this.communityId,
        this.monumentId,
        this.monumentName,
        this.imageUrl
      });

  @override
  List<Object> get props => [communityId];

  factory CommunityEntity.fromMap(Map<String, Object> data) {
    return CommunityEntity(
        communityId: data['communityId'] as String,
        monumentId: data['monumentId'] as String,
        monumentName: data['monumentName'] as String,
        imageUrl: data['imageUrl'] as String);
  }

  factory CommunityEntity.fromSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> data = snapshot.data();
    return CommunityEntity(
        communityId: data['communityId'] as String,
        monumentId: data['monumentId'] as String,
        monumentName: data['monumentName'] as String,
        imageUrl: data['imageUrl'] as String);
  }

  Map<String, Object> toMap() {
    return {
      'communityId': communityId,
      'monumentId': monumentId,
      'monumentName': monumentName,
      'imageUrl': imageUrl
    };
  }

  String toJson() => json.encode(toMap());

  factory CommunityEntity.fromJson(String source) =>
      CommunityEntity.fromMap(json.decode(source));
}

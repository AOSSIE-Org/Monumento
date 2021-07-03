import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String profilePictureUrl;
  final String status;
  final String username;
  final DocumentSnapshot documentSnapshot;

  UserModel(
      {this.email, this.uid, this.name, this.profilePictureUrl, this.status = "",this.username,this.documentSnapshot});

  UserModel copyWith({String email,String name,String profilePictureUrl,String status,String username,String uid}) {
    return UserModel(
        email: email ?? this.email,
        uid: uid ?? this.uid,
        name: name ?? this.name,
        profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
        status: status ?? this.status,username: username ?? this.username,documentSnapshot: documentSnapshot);
  }

  UserEntity toEntity() {
    return UserEntity(
        email: email,
        uid: uid,
        name: name,
        profilePictureUrl: profilePictureUrl,
        status: status);
  }

  static UserModel fromEntity(
      {@required UserEntity userEntity, DocumentSnapshot snapshot}) {
    return UserModel(
        uid: userEntity.uid,
        name: userEntity.name,
        email: userEntity.email,
        profilePictureUrl: userEntity.profilePictureUrl,
        status: userEntity.status,username: userEntity.username,documentSnapshot: snapshot);
  }
  @override
  String toString() {
    return 'UserModel(profilePictureUrl:$profilePictureUrl)';
  }
}

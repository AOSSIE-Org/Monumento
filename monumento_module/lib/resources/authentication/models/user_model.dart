import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String profilePictureUrl;
  final String status;
  final String username;
  final DocumentSnapshot documentSnapshot;
  final List<String> following;
  final List<String> followers;

  UserModel(
      {this.following,
      this.followers,
      this.email,
      this.uid,
      this.name,
      this.profilePictureUrl,
      this.status = "",
      this.username,
      this.documentSnapshot});

  UserModel copyWith(
      {String email,
      String name,
      String profilePictureUrl,
      String status,
      String username,
      String uid,
      List<String> following,
      List<String> followers}) {
    return UserModel(
        email: email ?? this.email,
        uid: uid ?? this.uid,
        name: name ?? this.name,
        profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
        status: status ?? this.status,
        username: username ?? this.username,
        documentSnapshot: documentSnapshot,
        followers: followers ?? this.followers,
        following: following ?? this.following);
  }

  UserEntity toEntity() {
    return UserEntity(
        email: email,
        uid: uid,
        name: name,
        profilePictureUrl: profilePictureUrl,
        status: status,
        following: following,
        followers: followers,
        username: username);
  }

  static UserModel fromEntity(
      {@required UserEntity userEntity, DocumentSnapshot snapshot}) {
    return UserModel(
        uid: userEntity.uid,
        name: userEntity.name,
        email: userEntity.email,
        profilePictureUrl: userEntity.profilePictureUrl,
        status: userEntity.status,
        username: userEntity.username,
        documentSnapshot: snapshot,
        followers: userEntity.followers,
        following: userEntity.following);
  }

  @override
  String toString() {
    return 'UserModel(profilePictureUrl:$profilePictureUrl)';
  }

  @override
  // TODO: implement props
  List<Object> get props => [uid];
}

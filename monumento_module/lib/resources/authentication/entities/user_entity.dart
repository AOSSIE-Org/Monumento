import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String profilePictureUrl;
  final String status;
  final String username;


  UserEntity(
      {this.email,
      this.uid,
      this.name = "Monumento User",
      this.profilePictureUrl,
      this.status = " hgh",this.username});

  @override
  List<Object> get props {
    return [uid];
  }

  factory UserEntity.fromMap(Map<String, Object> data) {
    print(data.toString()+"userfrommap");
    return UserEntity(
        uid: data['uid'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        profilePictureUrl: data['profilePictureUrl'] as String,
        status: data['status'] as String, username: data['username'] as String);
  }

  factory UserEntity.fromSnapshot(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data();

    return UserEntity(
        uid: data['uid'],
        name: data['name'],
        email: data['email'],
        profilePictureUrl: data['profilePictureUrl'],
        status: data['status'], username: data['username']);
  }
  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(json.decode(source));

  Map<String, Object> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'status': status,
      'username':username
    };
  }

  String toJson() => json.encode(toMap());
}

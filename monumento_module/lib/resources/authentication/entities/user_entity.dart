import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String profilePictureUrl;
  final String status;

  UserEntity(
      {this.email, this.uid, this.name = "Monumento User", this.profilePictureUrl, this.status=" hgh"});

  @override
  List<Object> get props {
    return [uid];
  }

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'status': status
    };
  }

  static UserEntity fromJson(Map<String, Object> json) {
    return UserEntity(
        uid: json['uid'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        profilePictureUrl: json['profilePictureUrl'] as String,
        status: json['status'] as String);
  }

  static UserEntity fromSnapshot(DocumentSnapshot snap) {
    return UserEntity(
        uid: snap.data['uid'],
        name: snap.data['name'],
        email: snap.data['email'],
        profilePictureUrl: snap.data['profilePictureUrl'],
        status: snap.data['status']);
  }

  Map<String, Object> toDocument() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'status': status
    };
  }
}

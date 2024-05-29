import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profilePictureUrl;
  final String status;
  final String? username;
  final List<String> following;
  final List<String> followers;

  const UserModel({
    this.following = const [],
    this.followers = const [],
    required this.email,
    required this.uid,
    this.name = "Monumento User",
    this.profilePictureUrl,
    this.status = " Status",
    this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return _$UserModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      profilePictureUrl: entity.profilePictureUrl,
      status: entity.status,
      username: entity.username,
      followers: entity.followers,
      following: entity.following,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      name: name,
      profilePictureUrl: profilePictureUrl,
      status: status,
      username: username,
      followers: followers,
      following: following,
    );
  }

  factory UserModel.fromMap(Map<String, Object> data) {
    List<String> mappedFollowers = data['followers'] != null
        ? (data['followers'] as List).map<String>((e) => e).toList()
        : [];
    List<String> mappedFollowing = data['following'] != null
        ? (data['following'] as List).map<String>((e) => e).toList()
        : [];

    return UserModel(
      uid: data['uid'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      profilePictureUrl: data['profilePictureUrl'] as String,
      status: data['status'] as String,
      username: data['username'] as String,
      followers: mappedFollowers,
      following: mappedFollowing,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'status': status,
      'username': username,
      'followers': followers,
      'following': following,
    };
  }
}

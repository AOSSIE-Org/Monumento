import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  @JsonKey(name: '\$id')
  final String uid;
  final String email;
  final String name;
  final String? profilePictureUrl;
  final String status;
  final String? username;
  final List<String> following;
  final List<String> followers;
  final List<String> posts;
  final List<MonumentModel> savedMonuments;
  final List<MonumentModel> checkedInMonuments;

  const UserModel({
    this.following = const [],
    this.followers = const [],
    this.posts = const [],
    this.savedMonuments = const [],
    this.checkedInMonuments = const [],
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
      posts: entity.posts,
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
      posts: posts,
    );
  }

  factory UserModel.fromMap(Map<String, Object> data) {
    List<String> mappedFollowers = data['followers'] != null
        ? (data['followers'] as List).map<String>((e) => e).toList()
        : [];
    List<String> mappedFollowing = data['following'] != null
        ? (data['following'] as List).map<String>((e) => e).toList()
        : [];
    List<String> mappedPosts = data['posts'] != null
        ? (data['posts'] as List).map<String>((e) => e).toList()
        : [];

    return UserModel(
      uid: data['\$id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      profilePictureUrl: data['profilePictureUrl'] as String,
      status: data['status'] as String,
      username: data['username'] as String,
      followers: mappedFollowers,
      following: mappedFollowing,
      posts: mappedPosts,
      savedMonuments: data['savedMonuments'] != null
          ? (data['savedMonuments'] as List)
              .map<MonumentModel>((e) => MonumentModel.fromJson(e))
              .toList()
          : [],
      checkedInMonuments: data['checkedInMonuments'] != null
          ? (data['checkedInMonuments'] as List)
              .map<MonumentModel>((e) => MonumentModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '\$id': uid,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'status': status,
      'username': username,
      'followers': followers,
      'following': following,
      'posts': posts,
      'savedMonuments': savedMonuments.map((e) => e.toJson()).toList(),
      'checkedInMonuments': checkedInMonuments.map((e) => e.toJson()).toList(),
    };
  }
}

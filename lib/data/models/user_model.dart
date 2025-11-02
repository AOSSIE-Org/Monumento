import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/data/models/monument_model.dart';
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
  final List<String> posts;
  final List<MonumentModel> savedMonuments;
  final List<String> myCommunities;
  final List<String> joinedCommunities;

  // NEW: Contribution & Reward System
  final int contributionPoints;
  final bool isTrustedUser;
  final int monumentsSubmitted;
  final int reviewsCompleted;
  final List<String> votedMonuments;

  const UserModel({
    this.following = const [],
    this.followers = const [],
    this.posts = const [],
    required this.email,
    required this.uid,
    this.name = "Monumento User",
    this.profilePictureUrl,
    this.savedMonuments = const [],
    this.status = " Status",
    this.username,
    this.myCommunities = const [],
    this.joinedCommunities = const [],
    this.contributionPoints = 0,
    this.isTrustedUser = false,
    this.monumentsSubmitted = 0,
    this.reviewsCompleted = 0,
    this.votedMonuments = const [],
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
      savedMonuments: entity.savedMonuments
          .map((monument) => MonumentModel.fromEntity(monument))
          .toList(),
      myCommunities: List<String>.from(entity.myCommunities),
      joinedCommunities: List<String>.from(entity.joinedCommunities),
      // New mappings
      contributionPoints: entity.contributionPoints,
      isTrustedUser: entity.isTrustedUser,
      monumentsSubmitted: entity.monumentsSubmitted,
      reviewsCompleted: entity.reviewsCompleted,
      votedMonuments: List<String>.from(entity.votedMonuments),
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
      myCommunities: List<String>.from(myCommunities),
      joinedCommunities: List<String>.from(joinedCommunities),
      // New mappings
      contributionPoints: contributionPoints,
      isTrustedUser: isTrustedUser,
      monumentsSubmitted: monumentsSubmitted,
      reviewsCompleted: reviewsCompleted,
      votedMonuments: List<String>.from(votedMonuments),
      savedMonuments:
          savedMonuments.map((monument) => monument.toEntity()).toList(),
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
      uid: data['uid'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      profilePictureUrl: data['profilePictureUrl'] as String,
      status: data['status'] as String,
      username: data['username'] as String,
      followers: mappedFollowers,
      following: mappedFollowing,
      posts: mappedPosts,
      joinedCommunities: data['joinedCommunities'] as List<String>,
      myCommunities: data['myCommunities'] as List<String>,
      // New fields
      contributionPoints: data['contributionPoints'] as int? ?? 0,
      isTrustedUser: data['isTrustedUser'] as bool? ?? false,
      monumentsSubmitted: data['monumentsSubmitted'] as int? ?? 0,
      reviewsCompleted: data['reviewsCompleted'] as int? ?? 0,
      votedMonuments: data['votedMonuments'] as List<String>? ??
          [], // List<String>.from(data['votedMonuments'] ?? []),
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
      'posts': posts,
      'myCommunities': myCommunities,
      'joinedCommunities': joinedCommunities,
      // New mappings
      'contributionPoints': contributionPoints,
      'isTrustedUser': isTrustedUser,
      'monumentsSubmitted': monumentsSubmitted,
      'reviewsCompleted': reviewsCompleted,
      'votedMonuments': votedMonuments,
    };
  }
}

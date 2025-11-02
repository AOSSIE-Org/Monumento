import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:equatable/equatable.dart';

import 'monument_entity.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String? profilePictureUrl;
  final String status;
  final String? username;
  final List<String> following;
  final List<String> followers;
  final List<String> posts;
  final List<MonumentEntity> savedMonuments;
  final List<String> myCommunities;
  final List<String> joinedCommunities;

  /// NEW: Contribution & Reward System
  final int contributionPoints;
  final bool isTrustedUser;
  final int monumentsSubmitted;
  final int reviewsCompleted;
  final List<String> votedMonuments;

  const UserEntity({
    this.following = const [],
    this.followers = const [],
    this.posts = const [],
    this.savedMonuments = const [],
    required this.email,
    required this.uid,
    this.name = "Monumento User",
    required this.profilePictureUrl,
    this.status = " Status",
    required this.username,
    this.myCommunities = const [],
    this.joinedCommunities = const [],
    this.contributionPoints = 0,
    this.isTrustedUser = false,
    this.monumentsSubmitted = 0,
    this.reviewsCompleted = 0,
    this.votedMonuments = const [],
  });

  @override
  List<Object?> get props {
    return [
      uid,
      email,
      name,
      profilePictureUrl,
      status,
      username,
      followers,
      following,
      posts,
      myCommunities,
      joinedCommunities,
      contributionPoints,
      isTrustedUser,
      monumentsSubmitted,
      reviewsCompleted,
      votedMonuments,
    ];
  }

  factory UserEntity.fromDocument(Document doc) {
    Map<String, dynamic> data = doc.data;
    List<String> mappedFollowers = data['followers'] != null
        ? (data['followers'] as List).map<String>((e) => e).toList()
        : [];
    List<String> mappedFollowing = data['following'] != null
        ? (data['following'] as List).map<String>((e) => e).toList()
        : [];
    List<String> mappedPosts = data['posts'] != null
        ? (data['posts'] as List).map<String>((e) => e).toList()
        : [];

    return UserEntity(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      profilePictureUrl: data['profilePictureUrl'],
      status: data['status'] ?? 'Status',
      username: data['username'],
      followers: mappedFollowers,
      following: mappedFollowing,
      posts: mappedPosts,
      myCommunities: data['myCommunities'] != null
          ? (data['myCommunities'] as List).map<String>((e) => e).toList()
          : [],
      joinedCommunities: data['joinedCommunities'] != null
          ? (data['joinedCommunities'] as List).map<String>((e) => e).toList()
          : [],
      // NEW
      contributionPoints: data['contributionPoints'] ?? 0,
      isTrustedUser: data['isTrustedUser'] ?? false,
      monumentsSubmitted: data['monumentsSubmitted'] ?? 0,
      reviewsCompleted: data['reviewsCompleted'] ?? 0,
      votedMonuments: List<String>.from(data['votedMonuments'] ?? []),
    );
  }
  factory UserEntity.fromMap(Map<String, dynamic> data) {
    return UserEntity(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'Monumento User',
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      status: data['status'] ?? 'Status',
      username: data['username'],
      followers:
          (data['followers'] as List?)?.map((e) => e.toString()).toList() ?? [],
      following:
          (data['following'] as List?)?.map((e) => e.toString()).toList() ?? [],
      posts: (data['posts'] as List?)?.map((e) => e.toString()).toList() ?? [],
      // savedMonuments: (data['savedMonuments'] as List?)
      //         ?.map((e) => MonumentEntity.fromMap(Map<String, dynamic>.from(e)))
      //         .toList()
      //     ?? [],
      myCommunities:
          (data['myCommunities'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      joinedCommunities: (data['joinedCommunities'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      // NEW
      contributionPoints: data['contributionPoints'] as int? ?? 0,
      isTrustedUser: data['isTrustedUser'] as bool? ?? false,
      monumentsSubmitted: data['monumentsSubmitted'] as int? ?? 0,
      reviewsCompleted: data['reviewsCompleted'] as int? ?? 0,
      votedMonuments: (data['votedMonuments'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, Object> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl ?? "",
      'status': status,
      'username': username ?? "",
      'following': following,
      'followers': followers,
      'posts': posts,
      'myCommunities': myCommunities,
      'joinedCommunities': joinedCommunities,
      // NEW
      'contributionPoints': contributionPoints,
      'isTrustedUser': isTrustedUser,
      'monumentsSubmitted': monumentsSubmitted,
      'reviewsCompleted': reviewsCompleted,
      'votedMonuments': votedMonuments,
    };
  }

  String toJson() => json.encode(toMap());
}

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

  final List<String> searchParams;
  final List<MonumentEntity> savedMonuments;
  final List<String> myCommunities;
  final List<String> joinedCommunities;

  final int contributionPoints;
  final bool isTrustedUser;
  final int monumentsSubmitted;
  final int reviewsCompleted;
  final List<String> votedMonuments;

  const UserEntity({
    this.following = const [],
    this.followers = const [],
    this.posts = const [],
    this.searchParams = const [],
    this.savedMonuments = const [],
    required this.email,
    required this.uid,
    this.name = "Monumento User",
    this.profilePictureUrl,
    this.status = "Status",
    this.username,
    this.myCommunities = const [],
    this.joinedCommunities = const [],
    this.contributionPoints = 0,
    this.isTrustedUser = false,
    this.monumentsSubmitted = 0,
    this.reviewsCompleted = 0,
    this.votedMonuments = const [],
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        profilePictureUrl,
        status,
        username,
        followers,
        following,
        posts,
        searchParams,
        savedMonuments,
        myCommunities,
        joinedCommunities,
        contributionPoints,
        isTrustedUser,
        monumentsSubmitted,
        reviewsCompleted,
        votedMonuments,
      ];

  factory UserEntity.fromDocument(Document doc) {
    final data = doc.data;

    return UserEntity(
      uid: data['uid'],
      email: data['email'],
      name: data['name'] ?? 'Monumento User',
      profilePictureUrl: data['profilePictureUrl'],
      status: data['status'] ?? 'Status',
      username: data['username'],
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      posts: List<String>.from(data['posts'] ?? []),
      searchParams: List<String>.from(data['searchParams'] ?? []),
      savedMonuments: (data['savedMonuments'] as List<dynamic>?)
              ?.map((e) =>
                  MonumentEntity.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      myCommunities: List<String>.from(data['myCommunities'] ?? []),
      joinedCommunities: List<String>.from(data['joinedCommunities'] ?? []),
      contributionPoints: data['contributionPoints'] ?? 0,
      isTrustedUser: data['isTrustedUser'] ?? false,
      monumentsSubmitted: data['monumentsSubmitted'] ?? 0,
      reviewsCompleted: data['reviewsCompleted'] ?? 0,
      votedMonuments: List<String>.from(data['votedMonuments'] ?? []),
    );
  }

  factory UserEntity.fromSnapshot(DocumentSnapshot snap) {
    return UserEntity.fromMap(snap.data() as Map<String, dynamic>);
  }

  factory UserEntity.fromMap(Map<String, dynamic> data) {
    return UserEntity(
      uid: data['uid'],
      email: data['email'],
      name: data['name'] ?? 'Monumento User',
      profilePictureUrl: data['profilePictureUrl'],
      status: data['status'] ?? 'Status',
      username: data['username'],
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      posts: List<String>.from(data['posts'] ?? []),
      searchParams: List<String>.from(data['searchParams'] ?? []),
      savedMonuments: (data['savedMonuments'] as List<dynamic>?)
              ?.map((e) =>
                  MonumentEntity.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      myCommunities: List<String>.from(data['myCommunities'] ?? []),
      joinedCommunities: List<String>.from(data['joinedCommunities'] ?? []),
      contributionPoints: data['contributionPoints'] ?? 0,
      isTrustedUser: data['isTrustedUser'] ?? false,
      monumentsSubmitted: data['monumentsSubmitted'] ?? 0,
      reviewsCompleted: data['reviewsCompleted'] ?? 0,
      votedMonuments: List<String>.from(data['votedMonuments'] ?? []),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'status': status,
      'username': username,
      'following': following,
      'followers': followers,
      'posts': posts,
      'searchParams': searchParams,
      'savedMonuments':
          savedMonuments.map((monument) => monument.toMap()).toList(),
      'myCommunities': myCommunities,
      'joinedCommunities': joinedCommunities,
      'contributionPoints': contributionPoints,
      'isTrustedUser': isTrustedUser,
      'monumentsSubmitted': monumentsSubmitted,
      'reviewsCompleted': reviewsCompleted,
      'votedMonuments': votedMonuments,
    };
  }

  String toJson() => json.encode(toMap());
}

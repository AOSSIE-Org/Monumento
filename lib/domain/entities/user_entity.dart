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
  });

  @override
  List<Object> get props {
    return [uid];
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
      'joinedCommunities': joinedCommunities
    };
  }

  String toJson() => json.encode(toMap());
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      following: (json['following'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      posts:
          (json['posts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      email: json['email'] as String,
      uid: json['uid'] as String,
      name: json['name'] as String? ?? "Monumento User",
      profilePictureUrl: json['profilePictureUrl'] as String?,
      status: json['status'] as String? ?? " Status",
      username: json['username'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'name': instance.name,
      'profilePictureUrl': instance.profilePictureUrl,
      'status': instance.status,
      'username': instance.username,
      'following': instance.following,
      'followers': instance.followers,
      'posts': instance.posts,
    };

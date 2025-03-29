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
      savedMonuments: (json['savedMonuments'] as List<dynamic>?)
              ?.map((e) => MonumentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      checkedInMonuments: (json['checkedInMonuments'] as List<dynamic>?)
              ?.map((e) => MonumentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      email: json['email'] as String,
      uid: json[r'$id'] as String,
      name: json['name'] as String? ?? "Monumento User",
      profilePictureUrl: json['profilePictureUrl'] as String?,
      status: json['status'] as String? ?? " Status",
      username: json['username'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      r'$id': instance.uid,
      'email': instance.email,
      'name': instance.name,
      'profilePictureUrl': instance.profilePictureUrl,
      'status': instance.status,
      'username': instance.username,
      'following': instance.following,
      'followers': instance.followers,
      'posts': instance.posts,
      'savedMonuments': instance.savedMonuments.map((e) => e.toJson()).toList(),
      'checkedInMonuments':
          instance.checkedInMonuments.map((e) => e.toJson()).toList(),
    };

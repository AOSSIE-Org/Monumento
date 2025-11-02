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
      savedMonuments: (json['savedMonuments'] as List<dynamic>?)
              ?.map((e) => MonumentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: json['status'] as String? ?? " Status",
      username: json['username'] as String?,
      myCommunities: (json['myCommunities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      joinedCommunities: (json['joinedCommunities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      contributionPoints: (json['contributionPoints'] as num?)?.toInt() ?? 0,
      isTrustedUser: json['isTrustedUser'] as bool? ?? false,
      monumentsSubmitted: (json['monumentsSubmitted'] as num?)?.toInt() ?? 0,
      reviewsCompleted: (json['reviewsCompleted'] as num?)?.toInt() ?? 0,
      votedMonuments: (json['votedMonuments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
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
      'savedMonuments': instance.savedMonuments.map((e) => e.toJson()).toList(),
      'myCommunities': instance.myCommunities,
      'joinedCommunities': instance.joinedCommunities,
      'contributionPoints': instance.contributionPoints,
      'isTrustedUser': instance.isTrustedUser,
      'monumentsSubmitted': instance.monumentsSubmitted,
      'reviewsCompleted': instance.reviewsCompleted,
      'votedMonuments': instance.votedMonuments,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monument_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonumentModel _$MonumentModelFromJson(Map<String, dynamic> json) =>
    MonumentModel(
      modelLink: json['modelLink'] as String?,
      rating: (json['rating'] as num).toDouble(),
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      id: json[r'$id'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      imageUrl: json['image'] as String,
      image_1x1_: json['image_1x1_'] as String,
      name: json['name'] as String,
      wiki: json['wikipediaLink'] as String,
      wikiPageId: json['wikiPageId'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      has3DModel: json['has3DModel'] as bool? ?? false,
      localExperts: (json['localExperts'] as List<dynamic>?)
              ?.map((e) => LocalExpertModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      approvalStatus: $enumDecodeNullable(
              _$MonumentApprovalStatusEnumMap, json['approvalStatus']) ??
          MonumentApprovalStatus.pending,
      upVotingPoints: (json['upVotingPoints'] as num?)?.toInt() ?? 0,
      downVotingPoints: (json['downVotingPoints'] as num?)?.toInt() ?? 0,
      submittedByUserId: json['submittedByUserId'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      reviewNotes: json['reviewNotes'] as String?,
      upvotedBy: (json['upvotedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      downvotedBy: (json['downvotedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MonumentModelToJson(MonumentModel instance) =>
    <String, dynamic>{
      r'$id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'country': instance.country,
      'image': instance.imageUrl,
      'image_1x1_': instance.image_1x1_,
      'wikipediaLink': instance.wiki,
      'wikiPageId': instance.wikiPageId,
      'rating': instance.rating,
      'coordinates': instance.coordinates,
      'images': instance.images,
      'modelLink': instance.modelLink,
      'has3DModel': instance.has3DModel,
      'localExperts': instance.localExperts.map((e) => e.toJson()).toList(),
      'approvalStatus':
          _$MonumentApprovalStatusEnumMap[instance.approvalStatus]!,
      'upVotingPoints': instance.upVotingPoints,
      'downVotingPoints': instance.downVotingPoints,
      'submittedByUserId': instance.submittedByUserId,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'reviewNotes': instance.reviewNotes,
      'upvotedBy': instance.upvotedBy,
      'downvotedBy': instance.downvotedBy,
    };

const _$MonumentApprovalStatusEnumMap = {
  MonumentApprovalStatus.pending: 'pending',
  MonumentApprovalStatus.approved: 'approved',
  MonumentApprovalStatus.rejected: 'rejected',
};

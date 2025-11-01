import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/data/models/monument_approval_status.dart';
import 'package:monumento/domain/entities/monument_entity.dart';

import 'local_expert_model.dart';

part 'monument_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MonumentModel {
  @JsonKey(name: '\$id')
  final String id;
  final String name;
  final String city;
  final String country;
  @JsonKey(name: 'image')
  final String imageUrl;
  final String image_1x1_;
  @JsonKey(name: 'wikipediaLink')
  final String wiki;
  final String wikiPageId;
  final double rating;
  final List<double> coordinates;
  final List<String> images;
  final String? modelLink;
  final bool has3DModel;
  final List<LocalExpertModel> localExperts;

  // NEW: Review System Fields
  final MonumentApprovalStatus approvalStatus;
  final int upVotingPoints;
  final int downVotingPoints;
  final String? submittedByUserId;
  final DateTime? submittedAt;
  final String? reviewNotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;

  const MonumentModel({
    this.modelLink,
    required this.rating,
    required this.coordinates,
    required this.id,
    required this.city,
    required this.country,
    required this.imageUrl,
    required this.image_1x1_,
    required this.name,
    required this.wiki,
    required this.wikiPageId,
    this.images = const [],
    this.has3DModel = false,
    this.localExperts = const [],
    this.approvalStatus = MonumentApprovalStatus.pending,
    this.upVotingPoints = 0,
    this.downVotingPoints = 0,
    this.submittedByUserId,
    this.submittedAt,
    this.reviewNotes,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
  });

  factory MonumentModel.fromJson(Map<String, dynamic> json) {
    return _$MonumentModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MonumentModelToJson(this);

  factory MonumentModel.fromEntity(MonumentEntity entity) {
    return MonumentModel(
      id: entity.id,
      name: entity.name,
      city: entity.city,
      country: entity.country,
      imageUrl: entity.imageUrl,
      image_1x1_: entity.image_1x1_,
      wiki: entity.wiki,
      rating: entity.rating,
      coordinates: entity.coordinates,
      wikiPageId: entity.wikiPageId,

      // ✅ New fields
      approvalStatus: entity.approvalStatus,
      upVotingPoints: entity.upVotingPoints,
      downVotingPoints: entity.downVotingPoints,
      submittedByUserId: entity.submittedByUserId,
      submittedAt: entity.submittedAt,
      reviewNotes: entity.reviewNotes,
      upvotedBy: entity.upvotedBy,
      downvotedBy: entity.downvotedBy,
      images: entity.images,
    );
  }

  MonumentEntity toEntity() {
    return MonumentEntity(
      id: id,
      name: name,
      city: city,
      country: country,
      imageUrl: imageUrl,
      image_1x1_: image_1x1_,
      wiki: wiki,
      rating: rating,
      coordinates: coordinates,
      wikiPageId: wikiPageId,
      images: images,
      modelLink: modelLink,
      has3DModel: has3DModel,
      localExperts: localExperts.map((e) => e.toEntity()).toList(),
      // ✅ New fields
      approvalStatus: approvalStatus,
      upVotingPoints: upVotingPoints,
      downVotingPoints: downVotingPoints,
      submittedByUserId: submittedByUserId,
      submittedAt: submittedAt,
      reviewNotes: reviewNotes,
      upvotedBy: upvotedBy,
      downvotedBy: downvotedBy,
    );
  }
}

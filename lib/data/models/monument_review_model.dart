import 'package:monumento/data/models/vote_type_model.dart';

class MonumentReview {
  String? id;
  String monumentId;
  String reviewerUserId;
  VoteType voteType;
  String? comment;
  DateTime reviewedAt;
  final bool isTrustedUserReview;

  MonumentReview({
    this.id,
    required this.monumentId,
    required this.reviewerUserId,
    required this.voteType,
    this.comment,
    required this.reviewedAt,
    required this.isTrustedUserReview,
  });

  factory MonumentReview.fromJson(Map<String, dynamic> json) {
    return MonumentReview(
      id: json['\$id'] ?? '',
      monumentId: json['monumentId'] ?? '',
      reviewerUserId: json['reviewerUserId'] ?? '',
      voteType: VoteType.fromString(json['voteType'] ?? 'upvote'),
      comment: json['comment'],
      reviewedAt: DateTime.parse(json['reviewedAt']),
      isTrustedUserReview: json['isTrustedUserReview'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monumentId': monumentId,
      // 'id': id,
      'reviewerUserId': reviewerUserId,
      'voteType': voteType.value,
      'comment': comment,
      'reviewedAt': reviewedAt.toIso8601String(),
      'isTrustedUserReview': isTrustedUserReview,
    };
  }
}

// lib/models/vote_type.dart
enum VoteType {
  upvote,
  downvote,
  suggestEdit;

  String get value => name.replaceAll('_', '');

  static VoteType fromString(String value) {
    return VoteType.values.firstWhere(
      (e) => e.name.replaceAll('_', '') == value,
      orElse: () => VoteType.upvote,
    );
  }
}

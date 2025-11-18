class StoryEntity {
  final String storyId;
  final String userId;
  final String mediaUrl;
  final String? caption;
  final String mediaType;
  final int expiryTime;
  final int uploadTimestamp;
  final int views;
  final List<String> viewedBy;

  StoryEntity({
    required this.storyId,
    required this.userId,
    required this.mediaUrl,
    this.caption,
    required this.mediaType,
    required this.expiryTime,
    required this.uploadTimestamp,
    this.views = 0,
    this.viewedBy = const [],
  });

  bool get isExpired {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentTime > expiryTime;
  }

  double get remainingHours {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (isExpired) return 0;
    return (expiryTime - currentTime) / (1000 * 60 * 60);
  }
}

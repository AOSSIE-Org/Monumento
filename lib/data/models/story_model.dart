import 'package:monumento/domain/entities/story_entity.dart';

class StoryModel {
  final String storyId;
  final String userId;
  final String mediaUrl;
  final String? caption;
  final String mediaType;
  final int expiryTime;
  final int uploadTimestamp;
  final int views;
  final List<String> viewedBy;
  final Map<String, dynamic>? author;

  StoryModel({
    required this.storyId,
    required this.userId,
    required this.mediaUrl,
    this.caption,
    required this.mediaType,
    required this.expiryTime,
    required this.uploadTimestamp,
    this.views = 0,
    this.viewedBy = const [],
    this.author,
  });

  // Convert from JSON (Appwrite document)
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      storyId: json['\$id'] ?? json['storyId'] ?? '',
      userId: json['userId'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      caption: json['caption'],
      mediaType: json['mediaType'] ?? 'image',
      expiryTime: json['expiryTime'] ?? 0,
      uploadTimestamp: json['uploadTimestamp'] ?? 0,
      views: json['views'] ?? 0,
      viewedBy: List<String>.from(json['viewedBy'] ?? []),
      author: json['author'] is Map ? json['author'] : null,
    );
  }

  // Convert to JSON for Appwrite
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'mediaType': mediaType,
      'expiryTime': expiryTime,
      'uploadTimestamp': uploadTimestamp,
      'views': views,
      'viewedBy': viewedBy,
    };
  }

  // Check if story is expired
  bool get isExpired {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentTime > expiryTime;
  }

  // Get remaining time in hours
  double get remainingHours {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (isExpired) return 0;
    return (expiryTime - currentTime) / (1000 * 60 * 60);
  }

  // Convert to entity
  StoryEntity toEntity() {
    return StoryEntity(
      storyId: storyId,
      userId: userId,
      mediaUrl: mediaUrl,
      caption: caption,
      mediaType: mediaType,
      expiryTime: expiryTime,
      uploadTimestamp: uploadTimestamp,
      views: views,
      viewedBy: viewedBy,
    );
  }

  // Copy with changes
  StoryModel copyWith({
    String? storyId,
    String? userId,
    String? mediaUrl,
    String? caption,
    String? mediaType,
    int? expiryTime,
    int? uploadTimestamp,
    int? views,
    List<String>? viewedBy,
    Map<String, dynamic>? author,
  }) {
    return StoryModel(
      storyId: storyId ?? this.storyId,
      userId: userId ?? this.userId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      mediaType: mediaType ?? this.mediaType,
      expiryTime: expiryTime ?? this.expiryTime,
      uploadTimestamp: uploadTimestamp ?? this.uploadTimestamp,
      views: views ?? this.views,
      viewedBy: viewedBy ?? this.viewedBy,
      author: author ?? this.author,
    );
  }
}

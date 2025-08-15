class CommunityModel {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final String createdByUserId;
  final List<String> adminIds;
  final List<String> memberIds;
  final int membersCount;
  final int postsCount;
  final DateTime createdAt;
  final bool isActive;

  CommunityModel({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.createdByUserId,
    required this.adminIds,
    required this.memberIds,
    required this.membersCount,
    required this.postsCount,
    required this.createdAt,
    required this.isActive,
  });

  factory CommunityModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
      coverImageUrl: map['coverImageUrl'],
      createdByUserId: map['createdByUserId'] ?? '',
      adminIds: List<String>.from(map['adminIds'] ?? []),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      membersCount: map['membersCount'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'createdByUserId': createdByUserId,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'membersCount': membersCount,
      'postsCount': postsCount,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  CommunityModel copyWith({
    String? name,
    String? description,
    String? coverImageUrl,
    String? createdByUserId,
    List<String>? adminIds,
    List<String>? memberIds,
    int? membersCount,
    int? postsCount,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return CommunityModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      membersCount: membersCount ?? this.membersCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool isUserAdmin(String userId) {
    return adminIds.contains(userId);
  }

  bool isUserMember(String userId) {
    return memberIds.contains(userId);
  }
}

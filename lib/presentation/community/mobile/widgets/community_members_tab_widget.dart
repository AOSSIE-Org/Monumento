import 'package:flutter/material.dart';
import 'package:monumento/data/repositories/appwrite_community_services_repository.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/utils/app_colors.dart';

class CommunityMembersTab extends StatefulWidget {
  final String communityId;

  const CommunityMembersTab({
    super.key,
    required this.communityId,
  });

  @override
  State<CommunityMembersTab> createState() => _CommunityMembersTabState();
}

class _CommunityMembersTabState extends State<CommunityMembersTab> {
  final CommunityService _communityService = CommunityService();
  List<UserEntity> members = [];
  List<String> adminIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommunityMembers();
  }

  Future<void> _loadCommunityMembers() async {
    try {
      final membersData =
          await _communityService.getCommunityMembers(widget.communityId);
      final community =
          await _communityService.getCommunityById(widget.communityId);

      setState(() {
        members = membersData;
        adminIds = community.adminIds;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading community members: $e');
    }
  }

  Future<void> _refreshMembers() async {
    setState(() {
      isLoading = true;
    });
    await _loadCommunityMembers();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.appPrimary),
      );
    }

    if (members.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshMembers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No members yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMembers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final isAdmin = adminIds.contains(member.uid);

          return _buildMemberCard(member, isAdmin);
        },
      ),
    );
  }

  Widget _buildMemberCard(UserEntity member, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.appWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColor.appPrimary,
            backgroundImage: member.profilePictureUrl != null
                ? NetworkImage(member.profilePictureUrl!)
                : null,
            child: member.profilePictureUrl == null
                ? Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColor.appWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColor.appBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.appPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            color: AppColor.appPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '@${member.username}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (member.status.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      member.status,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // Follow/Message Actions (Optional)
          IconButton(
            onPressed: () {
              // Navigate to user profile or show options
            },
            icon: Icon(
              Icons.person_outline,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

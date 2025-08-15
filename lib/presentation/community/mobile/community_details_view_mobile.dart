import 'package:flutter/material.dart';
import 'package:monumento/data/models/community_model.dart';
import 'package:monumento/data/repositories/appwrite_community_services_repository.dart';
import 'package:monumento/presentation/community/mobile/create_community_posts_view.dart';
import 'package:monumento/presentation/community/mobile/widgets/community_members_tab_widget.dart';
import 'package:monumento/presentation/community/mobile/widgets/community_posts_tab_widget.dart';
import 'package:monumento/utils/app_colors.dart';

class CommunityDetailsViewMobile extends StatefulWidget {
  final String communityId;
  final CommunityModel?
      community; // Optional, for when we already have the data

  const CommunityDetailsViewMobile({
    super.key,
    required this.communityId,
    this.community,
  });

  @override
  State<CommunityDetailsViewMobile> createState() =>
      _CommunityDetailsViewMobileState();
}

class _CommunityDetailsViewMobileState extends State<CommunityDetailsViewMobile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CommunityModel? community;
  bool isLoading = true;
  bool isJoined = false;
  bool isJoining = false;

  final CommunityService _communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.community != null) {
      community = widget.community;
      isLoading = false;
      _checkMembershipStatus();
    } else {
      _loadCommunityDetails();
    }
  }

  Future<void> _loadCommunityDetails() async {
    try {
      final communityData =
          await _communityService.getCommunityById(widget.communityId);
      setState(() {
        community = communityData;
        isLoading = false;
      });
      await _checkMembershipStatus();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading community: $e')),
      );
    }
  }

  Future<void> _checkMembershipStatus() async {
    try {
      final joined =
          await _communityService.isUserMemberOfCommunity(widget.communityId);
      setState(() {
        isJoined = joined;
      });
    } catch (e) {
      print('Error checking membership: $e');
    }
  }

  Future<void> _joinCommunity() async {
    setState(() {
      isJoining = true;
    });

    try {
      await _communityService.joinCommunity(widget.communityId);
      setState(() {
        isJoined = true;
        if (community != null) {
          community =
              community!.copyWith(membersCount: community!.membersCount + 1);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined the community!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error joining community: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isJoining = false;
      });
    }
  }

  void _createPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCommunityPostView(
          communityId: widget.communityId,
          communityName: community?.name ?? '',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColor.appWhite,
        body: const Center(
          child: CircularProgressIndicator(color: AppColor.appPrimary),
        ),
      );
    }

    if (community == null) {
      return Scaffold(
        backgroundColor: AppColor.appWhite,
        appBar: AppBar(
          backgroundColor: AppColor.appWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColor.appBlack),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Community not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.appWhite,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: AppColor.appWhite,
              elevation: 0,
              pinned: true,
              expandedHeight: 300,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColor.appBlack),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    // Cover Image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        image: community!.coverImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(community!.coverImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: community!.coverImageUrl == null
                          ? Icon(
                              Icons.groups,
                              size: 60,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),

                    // Community Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        community!.name,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.appBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (community!.description?.isNotEmpty ==
                                          true)
                                        Text(
                                          community!.description!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 120,
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: isJoining
                                        ? null
                                        : (isJoined ? null : _joinCommunity),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isJoined
                                          ? Colors.grey[400]
                                          : AppColor.appPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: isJoining
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: AppColor.appWhite,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            isJoined ? 'Joined' : 'Join',
                                            style: const TextStyle(
                                              color: AppColor.appWhite,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Stats Row
                            Row(
                              children: [
                                _buildStatItem(
                                  '${community!.membersCount}',
                                  community!.membersCount == 1
                                      ? 'Member'
                                      : 'Members',
                                ),
                                const SizedBox(width: 20),
                                _buildStatItem(
                                  '${community!.postsCount}',
                                  community!.postsCount == 1 ? 'Post' : 'Posts',
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppColor.appPrimary,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppColor.appPrimary,
                indicatorWeight: 2,
                padding: const EdgeInsets.symmetric(vertical: 0),
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Members'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            CommunityPostsTab(communityId: widget.communityId),
            CommunityMembersTab(communityId: widget.communityId),
          ],
        ),
      ),
      floatingActionButton: isJoined
          ? FloatingActionButton(
              onPressed: _createPost,
              backgroundColor: AppColor.appPrimary,
              child: const Icon(Icons.add, color: AppColor.appWhite),
            )
          : null,
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.appBlack,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

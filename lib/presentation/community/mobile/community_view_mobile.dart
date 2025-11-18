import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:monumento/data/repositories/appwrite_community_services_repository.dart';
import 'package:monumento/presentation/community/mobile/community_details_view_mobile.dart';
import 'package:monumento/presentation/community/mobile/create_community_view_mobile.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class CommunitiesViewMobile extends StatefulWidget {
  const CommunitiesViewMobile({super.key});

  @override
  State<CommunitiesViewMobile> createState() => _CommunitiesViewMobileState();
}

class _CommunitiesViewMobileState extends State<CommunitiesViewMobile> {
  late final CommunityService _communityService;
  List<Document> _communities = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _communityService = CommunityService();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final communities = await _communityService.getUserCreatedCommunities();
      setState(() {
        _communities = communities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load communities: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshCommunities() async {
    await _loadCommunities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appWhite,
      appBar: CustomMobileAppBar(
        logoPath: 'assets/monumento_logo.svg',
        title: 'Communities',
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCommunities,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Create New Community Button
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateCommunityViewMobile(),
                      ),
                    ).then((_) => _refreshCommunities());
                  },
                  icon: const Icon(
                    Icons.add,
                    color: AppColor.appWhite,
                  ),
                  label: const Text(
                    'Create New Community',
                    style: TextStyle(
                      color: AppColor.appWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.appPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Header with filter options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Communities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.appBlack,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (value) {
                      // Handle filter selection
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'all',
                        child: Text('All Communities'),
                      ),
                      const PopupMenuItem(
                        value: 'joined',
                        child: Text('Joined'),
                      ),
                      const PopupMenuItem(
                        value: 'admin',
                        child: Text('Admin'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Communities List
              Expanded(
                child: _buildCommunitiesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunitiesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.appPrimary)),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load communities',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _refreshCommunities,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.appPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_communities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No communities yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first community to get started!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _communities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final community = _communities[index];
        return _buildCommunityItem(community);
      },
    );
  }

  Widget _buildCommunityItem(Document community) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.appWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to community details
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CommunityDetailsViewMobile(communityId: community.$id),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Community Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: community.data['coverImageUrl'] != null
                    ? Image.network(
                        community.data['coverImageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(Icons.groups, color: Colors.grey[400]),
                          );
                        },
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: Icon(Icons.groups, color: Colors.grey[400]),
                      ),
              ),
              const SizedBox(width: 16),

              // Community Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.data['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      community.data['description'] ?? 'No description',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people_alt_outlined,
                            size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${community.data['membersCount'] ?? 0} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Navigation arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

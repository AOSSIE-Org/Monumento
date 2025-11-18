// lib/presentation/screens/review_hub/review_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:monumento/application/monument_review_hub/add_monument_view.dart';
import 'package:monumento/application/monument_review_hub/my_submissions_tab_view.dart';
import 'package:monumento/application/monument_review_hub/review_hub_provider.dart';
import 'package:monumento/application/monument_review_hub/widgets/reject_reason_dialog_widget.dart';
import 'package:monumento/data/models/edit_suggestion_model.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:provider/provider.dart';

import '../../data/models/vote_type_model.dart';

class ReviewHubScreen extends StatefulWidget {
  final String userId;

  const ReviewHubScreen({super.key, required this.userId});

  @override
  State<ReviewHubScreen> createState() => _ReviewHubScreenState();
}

class _ReviewHubScreenState extends State<ReviewHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReviewHubProvider>();
      provider.loadUserProfile(widget.userId);
      provider.loadPendingMonumentModels(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<ReviewHubProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadPendingMonumentModels();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildUserStats(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReviewTab(),
                  const MySubmissionsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMonumentScreen(),
            ),
          );
        },
        backgroundColor: AppColor.appPrimary,
        icon: const Icon(Icons.add, color: AppColor.appSecondary),
        label: const Text(
          'Add Monument',
          style: TextStyle(
            color: AppColor.appSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColor.appWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.appPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: AppColor.appSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Hub',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.appSecondary,
                  ),
                ),
                Text(
                  'Help build the community',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.appTextGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Consumer<ReviewHubProvider>(
      builder: (context, provider, child) {
        if (provider.currentUser == null) {
          return const SizedBox.shrink();
        }

        return UserStatsCard(user: provider.currentUser!);
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.appWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColor.appPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppColor.appSecondary,
        unselectedLabelColor: AppColor.appTextGrey,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Pending Reviews'),
          Tab(text: 'My Submissions'),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    return Consumer<ReviewHubProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.pendingMonumentModels.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColor.appPrimary,
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColor.appWarningRed,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColor.appTextGrey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.loadPendingMonumentModels(refresh: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.appPrimary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.pendingMonumentModels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: AppColor.appPrimary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Pending Reviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.appSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'All submissions have been reviewed!',
                  style: TextStyle(color: AppColor.appTextGrey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadPendingMonumentModels(refresh: true);
          },
          color: AppColor.appPrimary,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.pendingMonumentModels.length +
                (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.pendingMonumentModels.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: AppColor.appPrimary,
                    ),
                  ),
                );
              }

              final monument = provider.pendingMonumentModels[index];
              return MonumentReviewCard(
                monument: monument,
                userId: widget.userId,
                isTrustedUser: provider.isTrustedUser,
              );
            },
          ),
        );
      },
    );
  }
}

// lib/presentation/screens/review_hub/widgets/user_stats_card.dart
class UserStatsCard extends StatelessWidget {
  final dynamic user; // UserModel

  const UserStatsCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.appSecondary,
            AppColor.appSecondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.appSecondary.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          if (user.isTrustedUser)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: AppColor.appSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Trusted User',
                    style: TextStyle(
                      color: AppColor.appSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.stars,
                label: 'Points',
                value: user.contributionPoints.toString(),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColor.appWhite.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.upload,
                label: 'Submitted',
                value: user.monumentsSubmitted.toString(),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColor.appWhite.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.rate_review,
                label: 'Reviews',
                value: user.reviewsCompleted.toString(),
              ),
            ],
          ),
          if (!user.isTrustedUser) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: user.contributionPoints / 100,
                backgroundColor: AppColor.appWhite.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColor.appPrimary,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${100 - user.contributionPoints} points to Trusted User',
              style: TextStyle(
                color: AppColor.appWhite.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColor.appPrimary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColor.appWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColor.appWhite.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// lib/presentation/screens/review_hub/widgets/monument_review_card.dart
class MonumentReviewCard extends StatefulWidget {
  final MonumentModel monument; // MonumentModel
  final String userId;
  final bool isTrustedUser;

  const MonumentReviewCard({
    super.key,
    required this.monument,
    required this.userId,
    required this.isTrustedUser,
  });

  @override
  State<MonumentReviewCard> createState() => _MonumentReviewCardState();
}

class _MonumentReviewCardState extends State<MonumentReviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Image.network(
              widget.monument.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: AppColor.appGreyAccent,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppColor.appTextGrey,
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and trusted user badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.monument.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.appSecondary,
                        ),
                      ),
                    ),
                    if (widget.isTrustedUser)
                      IconButton(
                        onPressed: () => _showTrustedUserActions(),
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColor.appSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColor.appTextGrey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.monument.city}, ${widget.monument.country}',
                        style: const TextStyle(
                          color: AppColor.appTextGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Expand/Collapse button
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColor.appPrimary,
                  ),
                  label: Text(
                    _isExpanded ? 'Show Less' : 'Show More Details',
                    style: const TextStyle(color: AppColor.appPrimary),
                  ),
                ),

                // Expanded details
                if (_isExpanded) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildDetailRow('Coordinates',
                      widget.monument.coordinates.join(', ') ?? 'N/A'),
                  _buildDetailRow('Wikipedia', 'Available'),
                  if (widget.monument.has3DModel)
                    _buildDetailRow('3D Model', 'Available'),
                  const SizedBox(height: 8),
                ],

                // Vote counts
                Row(
                  children: [
                    _buildVoteCount(
                      Icons.thumb_up,
                      widget.monument.upVotingPoints,
                      Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildVoteCount(
                      Icons.thumb_down,
                      widget.monument.downVotingPoints,
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleVote(context, VoteType.upvote),
                        icon: const Icon(Icons.thumb_up, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _handleVote(context, VoteType.downvote),
                        icon: const Icon(Icons.thumb_down, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.appWarningRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditSuggestionDialog(context),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Suggest Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.appSecondary,
                      side: const BorderSide(color: AppColor.appSecondary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.appTextGrey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColor.appSecondaryBlack,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteCount(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _handleVote(BuildContext context, VoteType voteType) async {
    final provider = context.read<ReviewHubProvider>();

    final success = await provider.voteOnMonumentModel(
      widget.monument.id,
      widget.userId,
      voteType,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            voteType == VoteType.upvote
                ? 'Vote submitted! +2 points'
                : 'Vote submitted! +2 points',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: AppColor.appWarningRed,
        ),
      );
    }
  }

  void _showTrustedUserActions() {
    TrustedUserActionSheet.show(
      context,
      onApprove: () async {
        final provider = context.read<ReviewHubProvider>();
        final success = await provider.instantApprove(
          widget.monument.id,
          widget.userId,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Monument approved instantly!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onReject: () async {
        //TODO: solve error here

        const reason = RejectReasonDialog();
        final provider = context.read<ReviewHubProvider>();
        final success = await provider.instantReject(
          widget.monument.id,
          widget.userId,
          "reason", //TODO: solve error here
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Monument rejected!'),
              backgroundColor: AppColor.appWarningRed,
            ),
          );
        }
      },
    );
  }

  void _showEditSuggestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditSuggestionDialog(
        monumentId: widget.monument.id,
        userId: widget.userId,
      ),
    );
  }
}

// lib/presentation/screens/review_hub/edit_suggestion_dialog.dart
class EditSuggestionDialog extends StatefulWidget {
  final String monumentId;
  final String userId;

  const EditSuggestionDialog({
    super.key,
    required this.monumentId,
    required this.userId,
  });

  @override
  State<EditSuggestionDialog> createState() => _EditSuggestionDialogState();
}

class _EditSuggestionDialogState extends State<EditSuggestionDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedField;
  final _currentValueController = TextEditingController();
  final _suggestedValueController = TextEditingController();
  final _reasonController = TextEditingController();

  final List<String> _editableFields = [
    'name',
    'city',
    'country',
    'coordinates',
    'wikipediaLink',
    'image',
  ];

  @override
  void dispose() {
    _currentValueController.dispose();
    _suggestedValueController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Suggest an Edit',
        style: TextStyle(
          color: AppColor.appSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help improve this monument by suggesting corrections',
                style: TextStyle(
                  color: AppColor.appTextGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Field selection
              DropdownButtonFormField<String>(
                value: _selectedField,
                decoration: const InputDecoration(
                  labelText: 'Field to Edit',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: _editableFields.map((field) {
                  return DropdownMenuItem(
                    value: field,
                    child: Text((field)), //!_formatFieldName
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedField = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a field';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Current value
              TextFormField(
                controller: _currentValueController,
                decoration: const InputDecoration(
                  labelText: 'Current Value (Optional)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Suggested value
              TextFormField(
                controller: _suggestedValueController,
                decoration: const InputDecoration(
                  labelText: 'Suggested Value',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a suggested value';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Edit',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason';
                  }
                  if (value.trim().length < 10) {
                    return 'Reason must be at least 10 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final editSuggestion = EditSuggestion(
                monumentId: widget.monumentId,
                currentValue: _currentValueController.text,
                suggestedValue: _suggestedValueController.text,
                reason: _reasonController.text,
                id: widget.userId,
                suggestedByUserId: widget.userId,
                fieldName:
                    _selectedField!, // _formatFieldName(_selectedField!),
                status: SuggestionStatus.pending,
                suggestedAt: DateTime.now(),
              );
              Navigator.pop(context, editSuggestion);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

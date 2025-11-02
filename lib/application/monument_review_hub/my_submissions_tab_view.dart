import 'package:flutter/material.dart';
import 'package:monumento/application/monument_review_hub/review_hub_provider.dart';
import 'package:monumento/data/models/monument_approval_status.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/presentation/popular_monuments/mobile/monument_details_view_mobile.dart';
import 'package:provider/provider.dart';

class MySubmissionsTab extends StatefulWidget {
  const MySubmissionsTab({super.key});

  @override
  State<MySubmissionsTab> createState() => _MySubmissionsTabState();
}

class _MySubmissionsTabState extends State<MySubmissionsTab> {
  @override
  void initState() {
    super.initState();
    // Load user submissions when tab is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReviewHubProvider>();
      final userId = provider.currentUser?.uid;
      if (userId != null) {
        provider.loadUserSubmissions(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewHubProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final userId = provider.currentUser?.uid;
            if (userId != null) {
              await provider.loadUserSubmissions(userId);
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TrustedUserBanner(
                isTrustedUser: provider.isTrustedUser,
              ),
              const SizedBox(height: 16),
              _SubmissionsList(
                submissions: provider.userSubmissions,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrustedUserBanner extends StatelessWidget {
  final bool isTrustedUser;

  const _TrustedUserBanner({
    required this.isTrustedUser,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTrustedUser) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[700]!, Colors.purple[400]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified, color: Colors.white, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trusted User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You can instantly approve or reject monuments',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionsList extends StatelessWidget {
  final List<MonumentModel> submissions;

  const _SubmissionsList({
    required this.submissions,
  });

  @override
  Widget build(BuildContext context) {
    if (submissions.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.upload_file, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No submissions yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit your first monument to get started!',
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigator.pushNamed(context, '/add-monument');
                },
                icon: const Icon(Icons.add),
                label: const Text('Submit Monument'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Submissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${submissions.length} ${submissions.length == 1 ? 'monument' : 'monuments'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...submissions.map((monument) => SubmissionCard(monument: monument)),
      ],
    );
  }
}

class SubmissionCard extends StatelessWidget {
  final MonumentModel monument;

  const SubmissionCard({super.key, required this.monument});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MonumentDetailsViewMobile(
                monument: monument.toEntity(),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Monument Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  monument.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Monument Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monument.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${monument.city}, ${monument.country}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _buildStatusChip(monument.approvalStatus),
                  ],
                ),
              ),

              // Vote Count (only for pending)
              if (monument.approvalStatus == MonumentApprovalStatus.pending)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getVoteColor(
                            monument.upVotingPoints - monument.downVotingPoints)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${monument.upVotingPoints - monument.downVotingPoints >= 0 ? '+' : ''}${monument.upVotingPoints - monument.downVotingPoints}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getVoteColor(monument.upVotingPoints -
                              monument.downVotingPoints),
                        ),
                      ),
                      Text(
                        'votes',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getVoteColor(int netVotes) {
    if (netVotes > 0) return Colors.green;
    if (netVotes < 0) return Colors.red;
    return Colors.grey;
  }

  Widget _buildStatusChip(MonumentApprovalStatus status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case MonumentApprovalStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        text = 'Pending Review';
        break;
      case MonumentApprovalStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Approved';
        break;
      case MonumentApprovalStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

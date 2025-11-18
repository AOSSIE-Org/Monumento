// lib/widgets/enhanced_monument_review_card.dart
import 'package:flutter/material.dart';
import 'package:monumento/application/monument_review_hub/review_hub_provider.dart';
import 'package:monumento/application/monument_review_hub/widgets/reject_reason_dialog_widget.dart';
import 'package:monumento/data/models/edit_suggestion_model.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/data/models/vote_type_model.dart';
import 'package:provider/provider.dart';

class EnhancedMonumentReviewCard extends StatelessWidget {
  final MonumentModel monument;

  const EnhancedMonumentReviewCard({
    super.key,
    required this.monument,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewHubProvider>();
    final isTrustedUser = provider.isTrustedUser;
    final currentUserId = provider.currentUser?.uid ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monument Image with Trusted User Badge
          Stack(
            children: [
              const ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                ),
              ),
              if (isTrustedUser)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Trusted',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monument Name
                Text(
                  monument.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${monument.city ?? 'Unknown'}, ${monument.country}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),

                // Wikipedia Link if available
                ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Has Wikipedia reference',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Vote Stats
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.thumb_up, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        '${monument.upVotingPoints}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.thumb_down, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        '${monument.downVotingPoints}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (monument.upVotingPoints -
                                      monument.downVotingPoints) >=
                                  0
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Net: ${(monument.upVotingPoints - monument.downVotingPoints) >= 0 ? '+' : ''}${monument.upVotingPoints - monument.downVotingPoints}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (monument.upVotingPoints -
                                        monument.downVotingPoints) >=
                                    0
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Threshold Progress (for non-trusted users)
                if (!isTrustedUser) ...[
                  const SizedBox(height: 12),
                  _buildThresholdProgress(context),
                ],

                const SizedBox(height: 16),

                // Action Buttons
                if (isTrustedUser)
                  _buildTrustedUserActions(context, currentUserId)
                else
                  _buildRegularUserActions(context, currentUserId),

                // View Details Button
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/monument-details',
                        arguments: monument,
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Full Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdProgress(BuildContext context) {
    final remaining = 10 - monument.upVotingPoints;
    final progress = monument.upVotingPoints / 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Approval Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              remaining > 0
                  ? '$remaining more ${remaining == 1 ? 'vote' : 'votes'} needed'
                  : 'Ready for approval!',
              style: TextStyle(
                fontSize: 12,
                color: remaining > 0 ? Colors.grey[600] : Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress > 1.0 ? 1.0 : progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : Colors.blue,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRegularUserActions(BuildContext context, String userId) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleVote(context, userId, VoteType.upvote),
            icon: const Icon(Icons.thumb_up_outlined),
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
            onPressed: () => _handleVote(context, userId, VoteType.downvote),
            icon: const Icon(Icons.thumb_down_outlined),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showEditSuggestionDialog(context),
          icon: const Icon(Icons.edit_outlined),
          style: IconButton.styleFrom(
            backgroundColor: Colors.orange[100],
            foregroundColor: Colors.orange[800],
            padding: const EdgeInsets.all(12),
          ),
          tooltip: 'Suggest Edit',
        ),
      ],
    );
  }

  Widget _buildTrustedUserActions(BuildContext context, String userId) {
    return Column(
      children: [
        // Instant Actions for Trusted Users
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.flash_on, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              Text(
                'Instant Actions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleInstantApprove(context, userId),
                icon: const Icon(Icons.check_circle),
                label: const Text('Instant Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleInstantReject(context, userId),
                icon: const Icon(Icons.cancel),
                label: const Text('Instant Reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Regular vote option for trusted users
        TextButton.icon(
          onPressed: () {
            TrustedUserActionSheet.show(
              context,
              onApprove: () => _handleInstantApprove(context, userId),
              onReject: () => _handleInstantReject(context, userId),
            );
          },
          icon: const Icon(Icons.more_horiz),
          label: const Text('More Options'),
        ),
      ],
    );
  }

  Future<void> _handleVote(
    BuildContext context,
    String userId,
    VoteType voteType,
  ) async {
    final provider = context.read<ReviewHubProvider>();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          voteType == VoteType.upvote
              ? 'Approve Monument?'
              : 'Reject Monument?',
        ),
        content: Text(
          voteType == VoteType.upvote
              ? 'You will vote to approve "${monument.name}". You\'ll earn 2 contribution points.'
              : 'You will vote to reject "${monument.name}". You\'ll earn 2 contribution points.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  voteType == VoteType.upvote ? Colors.green : Colors.red,
            ),
            child: Text(voteType == VoteType.upvote ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await provider.voteOnMonumentModel(
      monument.id,
      userId,
      voteType,
    );

    // Close loading dialog
    if (context.mounted) Navigator.pop(context);

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to vote'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vote recorded! +2 points'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Stats',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to profile/stats page
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleInstantApprove(
      BuildContext context, String userId) async {
    final provider = context.read<ReviewHubProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified, color: Colors.purple),
            SizedBox(width: 8),
            Text('Instant Approve'),
          ],
        ),
        content: Text(
          'As a trusted user, you can instantly approve "${monument.name}". This will make it publicly visible immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await provider.instantApprove(monument.id, userId);

    if (context.mounted) Navigator.pop(context);

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to approve'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monument instantly approved!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleInstantReject(BuildContext context, String userId) async {
    final provider = context.read<ReviewHubProvider>();

    // Get rejection reason
    final String? reason = await showDialog<String>(
      context: context,
      builder: (context) => const RejectReasonDialog(),
    );

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await provider.instantReject(monument.id, userId, reason!);

    if (context.mounted) Navigator.pop(context);

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to reject'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monument instantly rejected'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showEditSuggestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditSuggestionDialog(monument: monument),
    );
  }
}

// lib/widgets/edit_suggestion_dialog.dart (Updated)
class EditSuggestionDialog extends StatefulWidget {
  final MonumentModel monument;

  const EditSuggestionDialog({super.key, required this.monument});

  @override
  State<EditSuggestionDialog> createState() => _EditSuggestionDialogState();
}

class _EditSuggestionDialogState extends State<EditSuggestionDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedField;
  final _suggestionController = TextEditingController();
  final _reasonController = TextEditingController();

  final Map<String, String> _editableFields = {
    'name': 'Monument Name',
    'city': 'City',
    'country': 'Country',
    'wikipediaLink': 'Wikipedia Link',
    'image': 'Main Image URL',
  };

  @override
  void dispose() {
    _suggestionController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String? _getCurrentValue(String field) {
    switch (field) {
      case 'name':
        return widget.monument.name;
      case 'city':
        return widget.monument.city;
      case 'country':
        return widget.monument.country;
      case 'wikipediaLink':
        return widget.monument.wiki; //!check
      case 'image':
        return widget.monument.imageUrl;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suggest Edit'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help improve "${widget.monument.name}"',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedField,
                decoration: const InputDecoration(
                  labelText: 'Field to Edit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                items: _editableFields.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedField = value),
                validator: (value) =>
                    value == null ? 'Please select a field' : null,
              ),
              if (_selectedField != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Current: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Expanded(
                        child: Text(
                          _getCurrentValue(_selectedField!) ?? 'Not set',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _suggestionController,
                decoration: const InputDecoration(
                  labelText: 'Suggested Value',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lightbulb_outline),
                ),
                maxLines: 2,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a suggestion' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  hintText: 'Why is this change needed?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
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
          onPressed: _submitSuggestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit Suggestion'),
        ),
      ],
    );
  }

  void _submitSuggestion() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<ReviewHubProvider>();

      final suggestion = EditSuggestion(
        id: '',
        monumentId: widget.monument.id,
        suggestedByUserId: provider.currentUser?.uid ?? '',
        fieldName: _selectedField!,
        currentValue: _getCurrentValue(_selectedField!),
        suggestedValue: _suggestionController.text.trim(),
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        status: SuggestionStatus.pending,
        suggestedAt: DateTime.now(),
      );

      Navigator.pop(context);

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await provider.submitEditSuggestion(suggestion);

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Edit suggestion submitted successfully!'
                  : 'Failed to submit suggestion',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

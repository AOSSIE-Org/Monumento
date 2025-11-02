// lib/presentation/widgets/approval_status_banner.dart
// Create this as a reusable widget

import 'package:flutter/material.dart';
import 'package:monumento/data/models/monument_approval_status.dart';
import 'package:monumento/domain/entities/monument_entity.dart';

class ApprovalStatusBanner extends StatelessWidget {
  final MonumentEntity monument;

  const ApprovalStatusBanner({
    super.key,
    required this.monument,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusBanner(),
        if (monument.approvalStatus == MonumentApprovalStatus.pending)
          _buildVotingInfo(),
      ],
    );
  }

  Widget _buildStatusBanner() {
    final statusConfig = _getStatusConfig(monument.approvalStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusConfig.borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              statusConfig.icon,
              color: statusConfig.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusConfig.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusConfig.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusConfig.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusConfig.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingInfo() {
    final netVotes = monument.upVotingPoints - monument.downVotingPoints;
    final progress = monument.upVotingPoints / 10;
    final votesNeeded = 10 - monument.upVotingPoints;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Community Votes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: netVotes >= 0 ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      netVotes >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color:
                          netVotes >= 0 ? Colors.green[700] : Colors.red[700],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${netVotes >= 0 ? '+' : ''}$netVotes',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            netVotes >= 0 ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.thumb_up_outlined,
                        size: 14, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${monument.upVotingPoints}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.thumb_down_outlined,
                        size: 14, color: Colors.red[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${monument.downVotingPoints}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            votesNeeded > 0
                ? '$votesNeeded more ${votesNeeded == 1 ? 'vote' : 'votes'} needed'
                : 'Ready for approval! ✓',
            style: TextStyle(
              fontSize: 11,
              color: votesNeeded > 0 ? Colors.grey[600] : Colors.green[700],
              fontWeight: votesNeeded > 0 ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  StatusConfig _getStatusConfig(MonumentApprovalStatus status) {
    switch (status) {
      case MonumentApprovalStatus.pending:
        return StatusConfig(
          backgroundColor: Colors.orange[50]!,
          borderColor: Colors.orange[300]!,
          textColor: Colors.orange[900]!,
          iconColor: Colors.orange[700]!,
          icon: Icons.pending_outlined,
          title: 'Pending Review',
          description: 'Awaiting community approval',
        );
      case MonumentApprovalStatus.approved:
        return StatusConfig(
          backgroundColor: Colors.green[50]!,
          borderColor: Colors.green[300]!,
          textColor: Colors.green[900]!,
          iconColor: Colors.green[700]!,
          icon: Icons.verified_outlined,
          title: 'Community Verified',
          description: 'Approved by the community',
        );
      case MonumentApprovalStatus.rejected:
        return StatusConfig(
          backgroundColor: Colors.red[50]!,
          borderColor: Colors.red[300]!,
          textColor: Colors.red[900]!,
          iconColor: Colors.red[700]!,
          icon: Icons.cancel_outlined,
          title: 'Rejected',
          description: 'Not approved by reviewers',
        );
    }
  }
}

class StatusConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;

  StatusConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
  });
}

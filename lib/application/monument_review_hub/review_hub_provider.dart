// lib/providers/review_hub_provider.dart
import 'package:flutter/material.dart';
import 'package:monumento/data/models/edit_suggestion_model.dart';
import 'package:monumento/data/models/monument_review_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/data/models/vote_type_model.dart';
import 'package:monumento/domain/repositories/review_hub_repository.dart';

import '../../data/models/monument_model.dart';

class ReviewHubProvider with ChangeNotifier {
  final ReviewHubRepository _repository;

  ReviewHubProvider(this._repository);

  // State
  final List<MonumentModel> _pendingMonumentModels = [];
  List<MonumentModel> _userSubmissions = [];
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _cursor;
  bool _hasMore = true;

  // Getters
  List<MonumentModel> get pendingMonumentModels => _pendingMonumentModels;
  List<MonumentModel> get userSubmissions => _userSubmissions;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isTrustedUser => _currentUser?.isTrustedUser ?? false;
  int get contributionPoints => _currentUser?.contributionPoints ?? 0;

  // Load current user profile
  Future<void> loadUserProfile(String userId) async {
    try {
      _currentUser = await _repository.getUserProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load pending MonumentModels for review
  Future<void> loadPendingMonumentModels({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _pendingMonumentModels.clear();
      _cursor = null;
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final MonumentModels = await _repository.getPendingMonumentModels(
        limit: 20,
        cursor: _cursor,
      );

      if (MonumentModels.isEmpty) {
        _hasMore = false;
      } else {
        _pendingMonumentModels.addAll(MonumentModels);
        _cursor = MonumentModels.last.id;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user's submissions
  Future<void> loadUserSubmissions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userSubmissions = await _repository.getUserSubmissions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit a new MonumentModel
  Future<bool> submitMonumentModel(
      MonumentModel monumentModel, String userId) async {
    try {
      final submitted = await _repository.submitMonumentModel(
        monumentModel,
      );
      _userSubmissions.insert(0, submitted);

      // Reload user profile to update stats
      await loadUserProfile(userId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Vote on a MonumentModel
  Future<bool> voteOnMonumentModel(
    String monumentModelId,
    String userId,
    VoteType voteType, {
    String? comment,
  }) async {
    try {
      // Check if user already voted
      // if (_currentUser?.(MonumentModelId) ?? false) {
      //   _error = 'You have already voted on this MonumentModel';
      //   notifyListeners();
      //   return false;
      // }

      await _repository.voteOnMonumentModel(
        monumentModelId,
        voteType,
        comment: comment,
      );

      // Remove from pending list
      //! check this issue related to it later
      // _pendingMonumentModels.removeWhere((m) => m.id == MonumentModelId);
      await loadPendingMonumentModels(refresh: true);
      // Reload user profile to update stats
      await loadUserProfile(userId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Instant approve (trusted users only)
  Future<bool> instantApprove(
      String MonumentModelId, String trustedUserId) async {
    try {
      if (!isTrustedUser) {
        _error = 'Only trusted users can instantly approve';
        notifyListeners();
        return false;
      }

      await _repository.instantApprove(MonumentModelId);

      // Remove from pending list
      _pendingMonumentModels.removeWhere((m) => m.id == MonumentModelId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Instant reject (trusted users only)
  Future<bool> instantReject(
    String MonumentModelId,
    String trustedUserId,
    String reason,
  ) async {
    try {
      if (!isTrustedUser) {
        _error = 'Only trusted users can instantly reject';
        notifyListeners();
        return false;
      }

      await _repository.instantReject(MonumentModelId, reason);

      // Remove from pending list
      _pendingMonumentModels.removeWhere((m) => m.id == MonumentModelId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Submit edit suggestion
  Future<bool> submitEditSuggestion(EditSuggestion suggestion) async {
    try {
      await _repository.submitEditSuggestion(suggestion);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get reviews for a MonumentModel
  Future<List<MonumentReview>> getMonumentReviews(
      String MonumentModelId) async {
    try {
      return await _repository.getMonumentReviews(MonumentModelId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Remove a MonumentModel from pending list (after action)
  void removeFromPending(String MonumentModelId) {
    _pendingMonumentModels.removeWhere((m) => m.id == MonumentModelId);
    notifyListeners();
  }
}

// lib/providers/MonumentModel_submission_provider.dart
class MonumentModelSubmissionProvider with ChangeNotifier {
  MonumentModel? _draftMonumentModel;
  bool _isSubmitting = false;
  String? _error;

  MonumentModel? get draftMonumentModel => _draftMonumentModel;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  void updateDraft(MonumentModel MonumentModel) {
    _draftMonumentModel = MonumentModel;
    notifyListeners();
  }

  void clearDraft() {
    _draftMonumentModel = null;
    notifyListeners();
  }

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

class TrustedUserActionSheet extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const TrustedUserActionSheet({
    super.key,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.verified, color: Colors.purple),
              SizedBox(width: 12),
              Text(
                'Trusted User Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            leading:
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
            title: const Text('Instant Approve'),
            subtitle: const Text('Approve this MonumentModel immediately'),
            onTap: () {
              Navigator.pop(context);
              onApprove();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red, size: 32),
            title: const Text('Instant Reject'),
            subtitle: const Text('Reject this MonumentModel with a reason'),
            onTap: () {
              Navigator.pop(context);
              onReject();
            },
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TrustedUserActionSheet(
        onApprove: onApprove,
        onReject: onReject,
      ),
    );
  }
}

// lib/widgets/reject_reason_dialog.

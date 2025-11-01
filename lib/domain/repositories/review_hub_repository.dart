import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monumento/data/models/edit_suggestion_model.dart';
import 'package:monumento/data/models/monument_approval_status.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/data/models/monument_review_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/data/models/vote_type_model.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';

abstract class ReviewHubRepository {
  // MonumentModel Submission
  Future<MonumentModel> submitMonumentModel(MonumentModel monumentModelId);
  Future<MonumentModel?> updateMonumentModelSubmission(
      String monumentModelId, Map<String, dynamic> updates);

  // Voting
  Future<void> voteOnMonumentModel(String monumentModelId, VoteType voteType,
      {String? comment});
  Future<void> removeVote(String monumentModelId);

  // Trusted User Actions
  Future<void> instantApprove(String monumentModelId);
  Future<void> instantReject(String monumentModelId, String reason);

  // Fetching
  Future<List<MonumentModel>> getPendingMonumentModels(
      {int limit = 20, String? cursor});
  Future<List<MonumentModel>> getUserSubmissions();
  Future<List<MonumentReview>> getMonumentReviews(String monumentModelId);
  Future<(int upvotingPoints, int downVotingPoints)> getMonumentPoints(
      String monumentModelId);

  // Edit Suggestions
  Future<EditSuggestion> submitEditSuggestion(EditSuggestion suggestion);
  Future<List<EditSuggestion>> getEditSuggestions(String monumentModelId);

  // User Points & Status
  Future<void> updateUserPoints(int points);
  Future<UserModel?> getUserProfile();
}

class ReviewHubRepositoryImpl implements ReviewHubRepository {
  final Databases databases;
  final String databaseId;
  final AuthenticationRepository authenticationRepository;
  static const int VOTE_POINTS = 2;
  static const int SUBMISSION_APPROVED_POINTS = 10;
  static const int APPROVAL_THRESHOLD = 10;
  static const int TRUSTED_USER_THRESHOLD = 100;
  static final String monumentDbId = dotenv.env['APPWRITE_MONUMENTS_ID']!;

  ReviewHubRepositoryImpl({
    required this.databases,
    required this.databaseId,
    required this.authenticationRepository,
  });

  @override
  Future<MonumentModel> submitMonumentModel(MonumentModel monumentModel) async {
    try {
      final monumentModelData = monumentModel.toJson();
      final user = await getUserProfile();
      monumentModelData['submittedByUserId'] = user!.uid;
      monumentModelData['submittedAt'] = DateTime.now().toIso8601String();
      monumentModelData['approvalStatus'] =
          MonumentApprovalStatus.pending.value;

      await databases.createDocument(
        databaseId: databaseId,
        collectionId: monumentDbId,
        documentId: ID.unique(),
        data: monumentModelData,
      );

      // Update user's MonumentModels submitted count
      await _incrementUserMonumentModelsSubmitted();

      return monumentModel;
    } catch (e) {
      throw Exception('Failed to submit MonumentModel: $e');
    }
  }

  @override
  Future<MonumentModel?> updateMonumentModelSubmission(
    String MonumentModelId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await databases.updateDocument(
        databaseId: databaseId,
        collectionId: monumentDbId,
        documentId: MonumentModelId,
        data: updates,
      );
      return MonumentModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update MonumentModel: $e');
    }
  }

  @override
  Future<void> voteOnMonumentModel(String MonumentModelId, VoteType voteType,
      {String? comment}) async {
    try {
      // Check if user already voted
      final MonumentModel = await _getMonumentModel(MonumentModelId);
      final user = await getUserProfile();

      if (user == null) throw Exception('User not found');
      // if (user.hasVoted(MonumentModelId)) {
      //   throw Exception('User has already voted on this MonumentModel');
      // }

      // Create review record
      final review = MonumentReview(
        monumentId: MonumentModelId,
        reviewerUserId: user.uid,
        voteType: voteType,
        comment: comment,
        reviewedAt: DateTime.now(),
        isTrustedUserReview: user.isTrustedUser,
      );

      await databases.createDocument(
        databaseId: databaseId,
        collectionId: 'MonumentReviews',
        documentId: ID.unique(),
        data: review.toJson(),
      );

      // Update MonumentModel vote counts
      final updates = <String, dynamic>{};
      if (voteType == VoteType.upvote) {
        updates['upVotingPoints'] = MonumentModel.upVotingPoints + 1;
        updates['upvotedBy'] = [...MonumentModel.upvotedBy, user.uid];
      } else if (voteType == VoteType.downvote) {
        updates['downVotingPoints'] = MonumentModel.downVotingPoints + 1;
        updates['downvotedBy'] = [...MonumentModel.downvotedBy, user.uid];
      }

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: monumentDbId,
        documentId: MonumentModelId,
        data: updates,
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.user(user.uid)),
        ],
      );

      // Update user's voted MonumentModels and points
      await _updateUserAfterVote(MonumentModelId);

      // Check if MonumentModel should be auto-approved/rejected
      await _checkAutoApproval(MonumentModelId);
    } catch (e) {
      throw Exception('Failed to vote on MonumentModel: $e');
    }
  }

  @override
  Future<void> removeVote(String MonumentModelId) async {
    try {
      final MonumentModel = await _getMonumentModel(MonumentModelId);
      final userId = await getUserProfile().then((user) => user!.uid);
      final updates = <String, dynamic>{};

      if (MonumentModel.upvotedBy.contains(userId)) {
        updates['upVotingPoints'] = MonumentModel.upVotingPoints - 1;
        updates['upvotedBy'] =
            MonumentModel.upvotedBy.where((id) => id != userId).toList();
      } else if (MonumentModel.downvotedBy.contains(userId)) {
        updates['downVotingPoints'] = MonumentModel.downVotingPoints - 1;
        updates['downvotedBy'] =
            MonumentModel.downvotedBy.where((id) => id != userId).toList();
      }

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: monumentDbId,
        documentId: MonumentModelId,
        data: updates,
      );

      // Remove from user's voted MonumentModels
      final user = await getUserProfile();
      if (user != null) {
        final updatedVoted =
            user.votedMonuments.where((id) => id != MonumentModelId).toList();
        await databases.updateDocument(
          databaseId: databaseId,
          collectionId: 'users',
          documentId: user.uid,
          data: {'votedMonuments': updatedVoted},
        );
      }
    } catch (e) {
      throw Exception('Failed to remove vote: $e');
    }
  }

  @override
  Future<void> instantApprove(String MonumentModelId) async {
    try {
      final user = await getUserProfile();
      if (user == null || !user.isTrustedUser) {
        throw Exception('User is not a trusted user');
      }

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: monumentDbId,
        documentId: MonumentModelId,
        data: {'approvalStatus': MonumentApprovalStatus.approved.value},
      );

      // Award points to MonumentModel submitter
      final MonumentModel = await _getMonumentModel(MonumentModelId);
      if (MonumentModel.submittedByUserId != null) {
        await updateUserPoints(SUBMISSION_APPROVED_POINTS);
      }

      // Create review record
      final review = MonumentReview(
        // id: '',
        monumentId: MonumentModelId,
        reviewerUserId: user.uid,
        voteType: VoteType.upvote,
        comment: 'Instantly approved by trusted user',
        reviewedAt: DateTime.now(),
        isTrustedUserReview: true,
      );

      await databases.createDocument(
        databaseId: databaseId,
        collectionId: 'MonumentReviews',
        documentId: ID.unique(),
        data: review.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to instant approve: $e');
    }
  }

  @override
  Future<void> instantReject(String MonumentModelId, String reason) async {
    try {
      final user = await getUserProfile();
      if (user == null || !user.isTrustedUser) {
        throw Exception('User is not a trusted user');
      }

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: monumentDbId,
        documentId: MonumentModelId,
        data: {
          'approvalStatus': MonumentApprovalStatus.rejected.value,
          'reviewNotes': reason,
        },
      );

      // Create review record
      final review = MonumentReview(
        id: '',
        monumentId: MonumentModelId,
        reviewerUserId: user.uid,
        voteType: VoteType.downvote,
        comment: reason,
        reviewedAt: DateTime.now(),
        isTrustedUserReview: true,
      );

      await databases.createDocument(
        databaseId: databaseId,
        collectionId: 'MonumentReviews',
        documentId: ID.unique(),
        data: review.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to instant reject: $e');
    }
  }

  @override
  Future<List<MonumentModel>> getPendingMonumentModels(
      {int limit = 20, String? cursor}) async {
    try {
      final queries = [
        Query.equal('approvalStatus', MonumentApprovalStatus.pending.value),
        Query.orderDesc('\$createdAt'),
        Query.limit(limit),
      ];

      if (cursor != null) {
        queries.add(Query.cursorAfter(cursor));
      }

      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: monumentDbId,
        queries: queries,
      );

      return response.documents
          .map((doc) => MonumentModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending MonumentModels: $e');
    }
  }

  @override
  Future<List<MonumentModel>> getUserSubmissions() async {
    try {
      final user = await getUserProfile();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: monumentDbId,
        queries: [
          Query.equal('submittedByUserId', user.uid),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return response.documents
          .map((doc) => MonumentModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user submissions: $e');
    }
  }

  @override
  Future<List<MonumentReview>> getMonumentReviews(
      String MonumentModelId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: 'MonumentReviews',
        queries: [
          Query.equal('MonumentModelId', MonumentModelId),
          Query.orderDesc('reviewedAt'),
        ],
      );

      return response.documents
          .map((doc) => MonumentReview.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  @override
  Future<EditSuggestion> submitEditSuggestion(EditSuggestion suggestion) async {
    try {
      final response = await databases.createDocument(
        databaseId: databaseId,
        collectionId: 'editSuggestions',
        documentId: ID.unique(),
        data: suggestion.toJson(),
      );

      return EditSuggestion.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to submit edit suggestion: $e');
    }
  }

  @override
  Future<List<EditSuggestion>> getEditSuggestions(
      String MonumentModelId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: 'editSuggestions',
        queries: [
          Query.equal('MonumentModelId', MonumentModelId),
          Query.equal('status', SuggestionStatus.pending.name),
        ],
      );

      return response.documents
          .map((doc) => EditSuggestion.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch edit suggestions: $e');
    }
  }

  @override
  Future<void> updateUserPoints(int points) async {
    try {
      final user = await getUserProfile();
      if (user == null) return;

      final newPoints = user.contributionPoints + points;
      final updates = <String, dynamic>{
        'contributionPoints': newPoints,
      };

      // Check if user should become trusted
      if (!user.isTrustedUser && newPoints >= TRUSTED_USER_THRESHOLD) {
        updates['isTrustedUser'] = true;
      }

      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: 'users',
        documentId: user.uid,
        data: updates,
      );
    } catch (e) {
      throw Exception('Failed to update user points: $e');
    }
  }

  @override
  Future<UserModel?> getUserProfile() async {
    try {
      final user = await authenticationRepository.getUser();

      return user.$2;
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  Future<MonumentModel> _getMonumentModel(String MonumentModelId) async {
    final response = await databases.getDocument(
      databaseId: databaseId,
      collectionId: monumentDbId,
      documentId: MonumentModelId,
    );
    return MonumentModel.fromJson(response.data);
  }

  Future<void> _incrementUserMonumentModelsSubmitted() async {
    final user = await getUserProfile();
    if (user != null) {
      await databases.updateDocument(
          databaseId: databaseId,
          collectionId: 'users',
          documentId: user.uid,
          data: {
            'monumentsSubmitted': user.monumentsSubmitted + 1,
          });
    }
  }

  Future<void> _updateUserAfterVote(String MonumentModelId) async {
    final user = await getUserProfile();
    if (user == null) return;

    final updatedVoted = [...user.votedMonuments, MonumentModelId];
    final newReviewsCount = user.reviewsCompleted + 1;

    await databases.updateDocument(
      databaseId: databaseId,
      collectionId: 'users',
      documentId: user.uid,
      data: {
        'votedMonuments': updatedVoted,
        'reviewsCompleted': newReviewsCount,
      },
    );

    // Award points for reviewing
    await updateUserPoints(VOTE_POINTS);
  }

  Future<void> _checkAutoApproval(String MonumentModelId) async {
    final MonumentModel = await _getMonumentModel(MonumentModelId);

    if (MonumentModel.approvalStatus != MonumentApprovalStatus.pending) {
      return;
    }

    // Auto-approve if threshold reached
    if (MonumentModel.upVotingPoints >= APPROVAL_THRESHOLD) {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: monumentDbId,
        documentId: MonumentModelId,
        data: {'approvalStatus': MonumentApprovalStatus.approved.value},
      );

      // Award points to submitter
      if (MonumentModel.submittedByUserId != null) {
        await updateUserPoints(SUBMISSION_APPROVED_POINTS);
      }
    }
    // Auto-reject if downvotes exceed threshold
    else if (MonumentModel.downVotingPoints >= APPROVAL_THRESHOLD) {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: monumentDbId,
        documentId: MonumentModelId,
        data: {
          'approvalStatus': MonumentApprovalStatus.rejected.value,
          'reviewNotes': 'Rejected by community vote',
        },
      );
    }
  }

  @override
  Future<(int upvotingPoints, int downVotingPoints)> getMonumentPoints(
      String monumentModelId) async {
    try {
      final monument = await _getMonumentModel(monumentModelId);

      final upvotingPoints = monument.upVotingPoints;
      final downVotingPoints = monument.downVotingPoints;
      return (upvotingPoints, downVotingPoints);
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }
}

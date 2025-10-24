import 'dart:io';
import 'dart:typed_data';

import 'package:monumento/data/models/comment_model.dart';
import 'package:monumento/data/models/notification_model.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/data/models/story_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/entities/user_entity.dart';

abstract interface class SocialRepository {
  Future<String> uploadImageForUrl(
      {required File file, required String address});

  Future<String> uploadProfilePicForUrl({required Uint8List fileBytes});

  Future<UserModel> getUserByUid({required String uid});

  Future<void> updateUserProfile({required Map<Object, dynamic> userInfo});

  Future<List<UserModel>> searchPeople({required String searchQuery});

  Future<List<UserModel>> getMoreSearchResults(
      {required String searchQuery, required String startAfterDocId});

  Future<bool> checkUserNameAvailability({required String username});

  Future<List<PostModel>> getInitialFeedPosts();

  Future<List<PostModel>> getInitialDiscoverPosts();

  Future<List<PostModel>> getMorePosts({required String startAfterDocId});

  Future<void> likePost({required String postId});

  Future<void> unlikePost({required String postId});

  Future<CommentModel> addNewComment(
      {required String postDocId, required String comment});

  Future<List<CommentModel>> getInitialComments({required String postDocId});

  Future<List<CommentModel>> getMoreComments(
      {required String postDocId, required String startAfterDocId});

  Future<List<UserModel>> getRecommendedUsers();

  Future<PostModel> uploadNewPost({
    required String title,
    String? location,
    String? imageUrl,
    required int postType,
  });

  Future<List<PostModel>> getInitialProfilePosts();

  Future<List<PostModel>> getMoreProfilePosts(
      {required String startAfterDocId});

  Future<void> followUser({required UserEntity targetUser});

  Future<void> unfollowUser({required UserEntity targetUser});

  Future<bool> getFollowStatus({required UserEntity targetUser});

  Future<List<PostModel>> getInitialUserPosts({required String uid});

  Future<NotificationModel> addNewNotification(
      {required UserModel targetUser, required NotificationModel notification});

  Future<List<NotificationModel>> getInitialNotifications();

  Future<List<NotificationModel>> getMoreNotifications(
      {required String startAfterDocId});

  Future<bool> monumentCheckIn({required String monumentId, String? title});

  Future<bool> checkInStatus({required String monumentId});

  Future<List<UserModel>> loadUser(List<String> userConnections);
  // Stories methods
  /// Upload a new story with optional caption
  /// Returns the created [StoryModel]
  Future<StoryModel> addStory({
    required File imageFile,
    String? caption,
  });

  /// Fetch all active (non-expired) stories
  /// Returns a list of [StoryModel] sorted by upload time
  Future<List<StoryModel>> fetchStories();

  /// Add a view to a story
  /// Records that a user has viewed the story and increments view count
  /// Only counts once per user
  Future<void> addStoryView({
    required String storyId,
    required String userId,
  });

  /// Delete a story (only story owner can delete)
  /// Throws exception if user doesn't own the story
  Future<void> deleteStory({required String storyId});

  /// Get all stories from a specific user
  /// Returns a list of active stories from the specified user
  Future<List<StoryModel>> getUserStories({required String userId});
}

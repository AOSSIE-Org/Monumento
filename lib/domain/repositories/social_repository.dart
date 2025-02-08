import 'dart:io';
import 'dart:typed_data';

import 'package:monumento/data/models/comment_model.dart';
import 'package:monumento/data/models/notification_model.dart';
import 'package:monumento/data/models/post_model.dart';
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
}

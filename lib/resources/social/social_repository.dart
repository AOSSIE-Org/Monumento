import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/models/comment_model.dart';
import 'package:monumento/resources/social/models/notification_model.dart';

import 'models/post_model.dart';

abstract class SocialRepository {
  Future<List<PostModel>> getInitialFeedPosts();

  Future<List<PostModel>> getMorePosts(
      {@required DocumentSnapshot startAfterDoc});

  Future<PostModel> uploadNewPost(
      {@required String title,
      @required String location,
      @required String imageUrl});

  Future<String> uploadImageForUrl(
      {@required File file, @required String address});

  Future<String> uploadProfilePicForUrl({@required File file});

  Future<List<UserModel>> searchPeople({@required String searchQuery});

  Future<List<UserModel>> getMoreSearchResults(
      {@required String searchQuery, @required DocumentSnapshot startAfterDoc});

  Future<CommentModel> addNewComment(
      {@required DocumentReference postDocReference, @required String comment});

  Future<List<CommentModel>> getInitialComments(
      {@required DocumentReference postDocReference});

  Future<List<CommentModel>> getMoreComments(
      {@required DocumentReference postDocReference,
      @required DocumentSnapshot startAfterDoc});

  Future<List<NotificationModel>> getInitialNotifications();

  Future<List<NotificationModel>> getMoreNotifications(
      {@required DocumentSnapshot startAfterDoc});

  Future<List<PostModel>> getInitialDiscoverPosts();

  Future<List<PostModel>> getMoreDiscoverPosts(
      {@required DocumentSnapshot startAfterDoc});

  Future<List<PostModel>> getInitialProfilePosts({@required String uid});

  Future<List<PostModel>> getMoreProfilePosts(
      {@required DocumentSnapshot startAfterDoc, @required String uid});

  Future<void> followUser(
      {@required UserModel targetUser, @required UserModel currentUser});

  Future<void> unfollowUser(
      {@required UserModel targetUser, @required UserModel currentUser});

  Future<bool> getFollowStatus(
      {@required UserModel targetUser, @required UserModel currentUser});

  Future<NotificationModel> addNewNotification(
      {@required UserModel targetUser,
      @required NotificationModel notification});
  Future<bool> checkUserNameAvailability({@required String username});
}

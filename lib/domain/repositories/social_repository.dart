import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monumento/data/models/comment_model.dart';
import 'package:monumento/data/models/post_model.dart';
import 'package:monumento/data/models/user_model.dart';

abstract interface class SocialRepository {
  Future<String> uploadImageForUrl(
      {required File file, required String address});

  Future<String> uploadProfilePicForUrl({required File file});

  Future<List<UserModel>> searchPeople({required String searchQuery});

  Future<List<UserModel>> getMoreSearchResults(
      {required String searchQuery, required DocumentSnapshot startAfterDoc});

  Future<bool> checkUserNameAvailability({required String username});

  Future<List<PostModel>> getInitialFeedPosts();

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
}

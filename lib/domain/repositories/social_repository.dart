import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monumento/data/models/user_model.dart';

abstract interface class SocialRepository {
  Future<String> uploadImageForUrl(
      {required File file, required String address});

  Future<String> uploadProfilePicForUrl({required File file});

  Future<List<UserModel>> searchPeople({required String searchQuery});

  Future<List<UserModel>> getMoreSearchResults(
      {required String searchQuery, required DocumentSnapshot startAfterDoc});

  Future<bool> checkUserNameAvailability({required String username});
}

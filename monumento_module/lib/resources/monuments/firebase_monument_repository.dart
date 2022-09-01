import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/monuments/entities/bookmarked_monument_entity.dart';
import 'package:monumento/resources/monuments/entities/monument_entity.dart';
import 'package:monumento/resources/monuments/monument_repository.dart';

import 'models/bookmarked_monument_model.dart';
import 'models/monument_model.dart';

class FirebaseMonumentRepository implements MonumentRepository {
  FirebaseFirestore _database;

  FirebaseMonumentRepository({FirebaseFirestore database})
      : _database = database ?? FirebaseFirestore.instance;

  Future<List<MonumentModel>> getPopularMonuments() async {
    final docs = await _database.collection('monuments').get();
    final List<MonumentModel> popularMonumentsDocs = docs.docs
        .map(
            (doc) => MonumentModel.fromEntity(MonumentEntity.fromSnapshot(doc)))
        .toList();
    return popularMonumentsDocs;
  }

  Stream<List<BookmarkedMonumentModel>> getBookmarkedMonuments(String userId) {
    Stream<List<BookmarkedMonumentModel>> streamBookmarkedMonuments = _database
        .collection('bookmarks')
        .where("uid", isEqualTo: userId)
        .snapshots()
        .map((querySnap) => querySnap.docs
            .map((doc) => BookmarkedMonumentModel.fromEntity(
                BookmarkedMonumentEntity.fromSnapshot(doc)))
            .toList());

    return streamBookmarkedMonuments;
  }

  Future<UserModel> getProfileData(String userId) async {
    final snap = await _database.collection('users').doc(userId).get();
    if (snap.exists) {
      return UserModel.fromEntity(
          userEntity: UserEntity.fromSnapshot(snap), snapshot: snap);
    }
    return null;
  }
}

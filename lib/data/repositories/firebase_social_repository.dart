import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseSocialRepository implements SocialRepository {
  final FirebaseFirestore _database;
  final FirebaseStorage _storage;

  FirebaseSocialRepository(
      {FirebaseFirestore? database, FirebaseStorage? storage})
      : _database = database ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadImageForUrl(
      {required File file, required String address}) async {
    String fileName = const Uuid().v4();
    UploadTask task =
        _storage.ref().child(address).child("$fileName.jpg").putFile(file);

    TaskSnapshot snapshot = await task.whenComplete(() => null);

    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<String> uploadProfilePicForUrl({required File file}) async {
    String fileName = const Uuid().v4();

    UploadTask task = _storage
        .ref()
        .child("profilePictures")
        .child("$fileName.jpg")
        .putFile(file);

    TaskSnapshot snapshot = await task.whenComplete(() => null);

    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<List<UserModel>> searchPeople({required String searchQuery}) async {
    // TODO: implement dateJoined field.
    String query = searchQuery.toLowerCase().replaceAll(' ', '');
    QuerySnapshot snap = await _database
        .collection("users")
        .where("searchParams", arrayContains: query)
        .limit(10)
        .get();
    // .orderBy("dateJoined",descending: false)
    List<UserModel> users = snap.docs
        .map((e) => UserModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
    return users;
  }

  @override
  Future<List<UserModel>> getMoreSearchResults(
      {required String searchQuery,
      required DocumentSnapshot<Object?> startAfterDoc}) async {
    QuerySnapshot snap = await _database
        .collection("users")
        .where("searchParams", arrayContains: searchQuery)
        .orderBy("dateJoined", descending: false)
        .startAfterDocument(startAfterDoc)
        .limit(10)
        .get();
    List<UserModel> users = snap.docs
        .map((e) => UserModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
    return users;
  }

  Future<UserModel> getUserByUid(String uid) async {
    DocumentSnapshot snap = await _database.collection('user').doc(uid).get();

    UserModel user = UserModel.fromJson(snap.data() as Map<String, dynamic>);
    return user;
  }

  @override
  Future<bool> checkUserNameAvailability({required String username}) async {
    QuerySnapshot<Map<String, dynamic>> docs = await _database
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return docs.docs.isEmpty;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';
import 'package:monumento/resources/monuments/entities/bookmarked_monument_entity.dart';
import 'package:monumento/resources/monuments/entities/monument_entity.dart';
import 'package:monumento/resources/monuments/monument_repository.dart';

class FirebaseMonumentRepository implements MonumentRepository {
  Firestore _database = Firestore.instance;
  Future<List<MonumentEntity>> getPopularMonuments() async {
    final docs = await _database.collection('popular_monuments').getDocuments();
    final List<MonumentEntity> popularMonumentsDocs = docs.documents.map((doc) => MonumentEntity.fromSnapshot(doc)).toList();
    return popularMonumentsDocs;

  }

  Stream<List<BookmarkedMonumentEntity>> getBookmarkedMonuments(String userId) {
    Stream<List<BookmarkedMonumentEntity>> streamBookmarkedMonuments = Firestore.instance
        .collection('bookmarks')
        .where("uid", isEqualTo: userId)
        .snapshots().map((querySnap) => querySnap.documents.map((doc) => BookmarkedMonumentEntity.fromSnapshot(doc)).toList());
      
      

    return streamBookmarkedMonuments;
  }

  Future<UserEntity> getProfileData(String userId) async {
    final snap = await Firestore.instance
        .collection('users')
        .document(userId)
        .get();
    if(snap.exists){
      return UserEntity.fromSnapshot(snap);
    }
    return null;
  }
}

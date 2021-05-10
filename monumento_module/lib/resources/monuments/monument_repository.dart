import 'package:cloud_firestore/cloud_firestore.dart';

abstract class MonumentRepository {
  Future<List<DocumentSnapshot>> getPopularMonuments();
  Stream<QuerySnapshot> getBookmarkedMonuments(String userId);
  Future<DocumentSnapshot> getProfileData(String userId);
}

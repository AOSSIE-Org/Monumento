import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monumento/resources/monuments/monument_repository.dart';

class FirebaseMonumentRepository implements MonumentRepository {
  Firestore _database = Firestore.instance;
  Future<List<DocumentSnapshot>> getPopularMonuments() async {
    final docs = await _database.collection('popular_monuments').getDocuments();
    final List<DocumentSnapshot> popularMonumentsDocs = docs.documents;
    return popularMonumentsDocs;

    // for(DocumentSnapshot doc in popMonumentDocs){
    //   monumentMapList.add(doc.data);
    // }
  }

  Stream<QuerySnapshot> getBookmarkedMonuments(String userId) {
    final docs = Firestore.instance
        .collection('bookmarks')
        .where("auth_id", isEqualTo: userId)
        .snapshots();

    return docs;
  }

  Future<DocumentSnapshot> getProfileData(String userId) async {
    final docs = await Firestore.instance
        .collection('users')
        .where("auth_id", isEqualTo: userId)
        .limit(1)
        .getDocuments();

    if (docs != null && docs.documents.length != 0) {
      return docs.documents[0];
    }
    return null;
  }
}

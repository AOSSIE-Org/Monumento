import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monumento/data/models/bookmarked_monument_model.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/data/models/wiki_data_model.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';
import 'package:wikipedia/wikipedia.dart';

class FirebaseMonumentRepository implements MonumentRepository {
  final FirebaseFirestore _database;

  FirebaseMonumentRepository({FirebaseFirestore? database})
      : _database = database ?? FirebaseFirestore.instance;

  @override
  Future<List<MonumentModel>> getPopularMonuments() async {
    final docs = await _database.collection('monuments').get();
    final List<MonumentModel> popularMonumentsDocs =
        docs.docs.map((doc) => MonumentModel.fromJson(doc.data())).toList();
    return popularMonumentsDocs;
  }

  @override
  Stream<List<BookmarkedMonumentModel>> getBookmarkedMonuments(String userId) {
    Stream<List<BookmarkedMonumentModel>> streamBookmarkedMonuments = _database
        .collection('bookmarks')
        .where("uid", isEqualTo: userId)
        .snapshots()
        .map((querySnap) => querySnap.docs
            .map((doc) => BookmarkedMonumentModel.fromJson(doc.data()))
            .toList());

    return streamBookmarkedMonuments;
  }

  @override
  Future<UserModel?> getProfileData(String userId) async {
    final snap = await _database.collection('users').doc(userId).get();
    if (snap.exists) {
      return UserModel.fromJson(snap.data()!);
    }
    return null;
  }

  @override
  Future<WikiDataModel> getMonumentWikiDetails(String wikiId) async {
    Wikipedia instance = Wikipedia();
    var res = await instance.searchSummaryWithPageId(pageId: int.parse(wikiId));
    return WikiDataModel(
      extract: res!.extract!,
      title: res.title!,
      description: res.description!,
      pageId: wikiId,
    );
  }
}

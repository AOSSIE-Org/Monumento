import 'package:monumento/data/models/bookmarked_monument_model.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/data/models/wiki_data_model.dart';

abstract interface class MonumentRepository {
  Future<List<MonumentModel>> getPopularMonuments();
  Stream<List<BookmarkedMonumentModel>> getBookmarkedMonuments(String userId);
  Future<UserModel?> getProfileData(String userId);
  Future<WikiDataModel> getMonumentWikiDetails(String wikiId);
}

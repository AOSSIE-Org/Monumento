import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/data/models/user_model.dart';
import 'package:monumento/data/models/wiki_data_model.dart';

abstract interface class MonumentRepository {
  Future<List<MonumentModel>> getPopularMonuments();
  Future<List<MonumentModel>> getBookmarkedMonuments();
  Future<UserModel?> getProfileData(String userId);
  Future<WikiDataModel> getMonumentWikiDetails(String wikiId);
  Future<bool> bookmarkMonument(String monumentId);
  Future<bool> unbookmarkMonument(String monumentId);
  Future<bool> isMonumentBookmarked(String monumentId);
}

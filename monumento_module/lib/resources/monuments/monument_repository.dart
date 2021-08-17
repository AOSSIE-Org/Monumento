import 'package:monumento/resources/authentication/models/user_model.dart';

import 'models/bookmarked_monument_model.dart';
import 'models/monument_model.dart';

abstract class MonumentRepository {
  Future<List<MonumentModel>> getPopularMonuments();
  Stream<List<BookmarkedMonumentModel>> getBookmarkedMonuments(String userId);
  Future<UserModel> getProfileData(String userId);
}

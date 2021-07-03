import 'package:monumento/resources/authentication/entities/user_entity.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/monuments/entities/bookmarked_monument_entity.dart';
import 'package:monumento/resources/monuments/entities/monument_entity.dart';

import 'models/bookmarked_monument_model.dart';
import 'models/monument_model.dart';

abstract class MonumentRepository {
  //TODO convert entity->model
  //TODO shift profieldata method to social repo
  Future<List<MonumentModel>> getPopularMonuments();
  Stream<List<BookmarkedMonumentModel>> getBookmarkedMonuments(String userId);
  Future<UserModel> getProfileData(String userId);
}

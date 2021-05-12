import 'package:monumento/resources/authentication/entities/user_entity.dart';
import 'package:monumento/resources/monuments/entities/bookmarked_monument_entity.dart';
import 'package:monumento/resources/monuments/entities/monument_entity.dart';

abstract class MonumentRepository {
  Future<List<MonumentEntity>> getPopularMonuments();
  Stream<List<BookmarkedMonumentEntity>> getBookmarkedMonuments(String userId);
  Future<UserEntity> getProfileData(String userId);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monumento/resources/communities/community_repository.dart';
import 'package:monumento/resources/communities/entities/community_entity.dart';
import 'package:monumento/resources/communities/models/community_model.dart';

class FirebaseCommunityRepository implements CommunityRepository {
  FirebaseFirestore _database;

  FirebaseCommunityRepository({FirebaseFirestore database})
      : _database = database ?? FirebaseFirestore.instance;

  //TODO: Add limit to this function
  @override
  Future<List<CommunityModel>> getInitialCommunity(
      {DocumentReference<Object> postDocReference}) async {
    final docs = await _database.collection('communities').get();
    final List<CommunityModel> communitiesDocs = docs.docs
        .map((doc) =>
            CommunityModel.fromEntity(CommunityEntity.fromSnapshot(doc)))
        .toList();
    return communitiesDocs;
  }

  @override
  Future<List<CommunityModel>> getMoreCommunities(
      {DocumentReference<Object> postDocReference,
      DocumentSnapshot<Object> startAfterDoc}) {
    // TODO: implement getMoreCommunities
    throw UnimplementedError();
  }
}

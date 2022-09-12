
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/communities/models/community_model.dart';

abstract class CommunityRepository{
  Future<List<CommunityModel>> getInitialCommunity(
      {@required DocumentReference postDocReference});

  Future<List<CommunityModel>> getMoreCommunities(
      {@required DocumentReference postDocReference,
        @required DocumentSnapshot startAfterDoc});
}
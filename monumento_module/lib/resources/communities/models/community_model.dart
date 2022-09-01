import 'package:meta/meta.dart';
import 'package:monumento/resources/communities/entities/community_entity.dart';

class CommunityModel {
  final String communityId;
  final String monumentId;
  final String monumentName;
  final String imageUrl;

  CommunityModel(
      {@required this.communityId, this.monumentId, this.monumentName, this.imageUrl});

  CommunityModel copyWith() {
    return CommunityModel(
        communityId: communityId,
        monumentId: monumentId,
        monumentName: monumentName,
        imageUrl: imageUrl);
  }

  CommunityEntity toEntity() {
    return CommunityEntity(
        communityId: communityId,
        monumentId: monumentId,
        monumentName: monumentName,
        imageUrl: imageUrl);
  }

  static CommunityModel fromEntity(CommunityEntity communityEntity){
    return CommunityModel(
      communityId: communityEntity.communityId,
      monumentId: communityEntity.monumentId,
      monumentName: communityEntity.monumentName,
      imageUrl: communityEntity.imageUrl
    );
  }

}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/communities/models/community_model.dart';
import 'package:monumento/ui/widgets/community_image_loading.dart';

class CommunityTile extends StatelessWidget {
  const CommunityTile({Key key, @required this.community, @required this.user})
      : super(key: key);
  final CommunityModel community;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CachedNetworkImage(
            imageUrl: community.imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image:
                  DecorationImage(image: imageProvider, fit: BoxFit.fill)),
              height: 220.0,
              width: MediaQuery.of(context).size.width,
              child: Align(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    community.monumentName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                alignment: Alignment.bottomLeft,
              ),
            ),
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: CommunityImageLoading(),
              height: 120,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )),
    );
  }
}

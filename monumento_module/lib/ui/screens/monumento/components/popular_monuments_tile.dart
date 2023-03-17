import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/monuments/models/monument_model.dart';
import 'package:monumento/ui/screens/monument_detail/detail_screen.dart';
import 'package:monumento/ui/widgets/feed_image_loading.dart';

class PopularMonumentTile extends StatelessWidget {
  const PopularMonumentTile(
      {Key key, @required this.monument, @required this.user})
      : super(key: key);
  final MonumentModel monument;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, DetailScreen.route,
          arguments: DetailScreenArguments(
              monument: monument, user: user, isBookmarked: false)),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CachedNetworkImage(
            imageUrl: monument.imageUrl,
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
                    monument.name,
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
              child: FeedImageLoading(),
              height: 120,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )),
    );
  }
}

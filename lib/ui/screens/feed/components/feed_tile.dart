import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/ui/screens/comments/comments_screen.dart';
import 'package:monumento/ui/widgets/feed_image_loading.dart';
import 'package:monumento/ui/widgets/profile_picture_loading.dart';
import 'package:monumento/utilities/constants.dart';

class FeedTile extends StatelessWidget {
  final String title;
  final String location;
  final String imageUrl;
  final UserModel author;
  final int timeStamp;
  final DocumentReference postDocumentRef;

  const FeedTile(
      {@required this.location,
      @required this.title,
      @required this.imageUrl,
      @required this.author,
      @required this.timeStamp,
      @required this.postDocumentRef});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: false,
            leading: ClipOval(
              child: CachedNetworkImage(
                imageUrl: author.profilePictureUrl,
                width: 50,
                height: 50,
                placeholder: (_, __) {
                  return ProfilePictureLoading();
                },
              ),
            ),
            title: Text(
              author.name,
              style: kStyle12W600,
            ),
            subtitle: Text(
              "@${author.username}",
              style: kStyle12W400,
            ),
          ),
          ClipRRect(
            child: CachedNetworkImage(
              imageUrl: imageUrl ?? '',
              placeholder: (_, __) {
                return FeedImageLoading();
              },
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SvgPicture.asset(
                "assets/favourite_icon_outline.svg",
              ),
              SizedBox(
                width: 16,
              ),
              GestureDetector(
                child: SvgPicture.asset(
                  "assets/comment_icon.svg",
                ),
                onTap: () => Navigator.of(context).pushNamed(
                    CommentsScreen.route,
                    arguments: CommentsScreenArguments(
                        postDocumentRef: postDocumentRef)),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            title,
            style: kStyle16W600,
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
              ),
              SizedBox(
                width: 2,
              ),
              Text(
                location,
                style: kStyle12W400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

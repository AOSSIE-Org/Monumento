import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/screens/comments/comments_screen.dart';

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
    print("hello $author");
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipOval(
              child: CachedNetworkImage(
                imageUrl: author.profilePictureUrl,
                width: 50,
                height: 50,
              ),
            ),
            title: Text(author.name),
            subtitle: Text("@${author.email.split("@")[0]}"),
          ),
          ClipRRect(
            child: CachedNetworkImage(imageUrl: imageUrl ?? "lul"),
            borderRadius: BorderRadius.circular(5),
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.star_border_outlined,
                size: 24,
              ),
              SizedBox(
                width: 16,
              ),
              IconButton(
                icon: Icon(Icons.message_outlined),
                onPressed: () => Navigator.of(context).pushNamed(
                    CommentsScreen.route,
                    arguments: CommentsScreenArguments(
                        postDocumentRef: postDocumentRef)),
              ),
              Spacer(),
              Icon(
                Icons.bookmark_add_outlined,
                size: 24,
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Text(title),
          SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Icon(Icons.location_on_outlined),
              SizedBox(
                width: 4,
              ),
              Text(location),
            ],
          ),
        ],
      ),
    );
  }
}

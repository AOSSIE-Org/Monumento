import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monumento/resources/social/models/comment_model.dart';

class CommentTile extends StatelessWidget {
  final CommentModel comment;

  const CommentTile({@required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: comment.author.profilePictureUrl,
              height: 40,
              width: 40,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: "@${comment.author.username}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(
                  text: " ${comment.comment}",
                  style: TextStyle(color: Colors.black))
            ])),
          )
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/models/notification_model.dart';
import 'package:monumento/resources/social/models/post_model.dart';
import 'package:monumento/utilities/constants.dart';

class NotificationTile extends StatelessWidget {
  final NotificationType notificationType;
  final UserModel userInvolved;
  final UserModel currentUser;
  final PostModel postInvolved;

  const NotificationTile(
      {this.notificationType,
      this.postInvolved,
      this.currentUser,
      this.userInvolved});

  final List<String> texts = const [
    " commented on your post",
    " liked your post",
    " followed you",
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {},
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: userInvolved.profilePictureUrl,
                    height: 36,
                    placeholder: (x, y) {
                      // return  ProfilePictureLoading();
                      return Container();
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: userInvolved.username + " ",
                    style: kStyle14W600.copyWith(color: Colors.black),
                    recognizer: TapGestureRecognizer()..onTap = () {}),
                TextSpan(
                  text: getText(),
                  style: TextStyle(color: Colors.black),
                ),
              ]),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          postInvolved != null
              ? ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: postInvolved.imageUrl,
                    height: 36,
                  ),
                  borderRadius: BorderRadius.circular(4),
                )
              : Container()
        ],
      ),
    );
  }

  String getText() {
    if (NotificationType.likeNotification == notificationType) {
      return texts[1];
    } else if (NotificationType.commentNotification == notificationType) {
      return texts[0];
    } else if (NotificationType.followedYou == notificationType) {
      return texts[2];
    }
    return "";
  }
}

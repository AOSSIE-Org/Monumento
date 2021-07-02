import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/entities/notification_entity.dart';
import 'package:monumento/resources/social/models/post_model.dart';

class NotificationModel {
  final NotificationType notificationType;
  final UserModel userInvolved;
  final PostModel postInvolved;
  final int timeStamp;
  final DocumentSnapshot documentSnapshot;

  NotificationModel(
      {this.notificationType,
      this.userInvolved,
      this.postInvolved,
      this.timeStamp,
      this.documentSnapshot});

  factory NotificationModel.fromEntity(
      {@required NotificationEntity entity, DocumentSnapshot documentSnapshot}) {
    return NotificationModel(
        notificationType: NotificationType.values[entity.notificationType],
        postInvolved: PostModel.fromEntity(entity: entity.postInvolved),
        documentSnapshot: documentSnapshot);
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      notificationType: notificationType.index,
      timeStamp: timeStamp,
      userInvolved:userInvolved.toEntity(),
      postInvolved:  (notificationType == NotificationType.likeNotification ||notificationType == NotificationType.commentNotification ) ? postInvolved.toEntity() : null,
    );
  }
}

enum NotificationType {
  likeNotification,
  commentNotification,
  followRequest,
  acceptedFollowRequested,
  followedYou,
}

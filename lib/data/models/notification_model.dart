import 'package:json_annotation/json_annotation.dart';
import 'package:monumento/domain/entities/notification_entity.dart';

import 'post_model.dart';
import 'user_model.dart';

part 'notification_model.g.dart';

@JsonSerializable(explicitToJson: true)
class NotificationModel {
  final NotificationType notificationType;
  final UserModel userInvolved;
  final PostModel? postInvolved;
  final int timeStamp;

  NotificationModel({
    required this.notificationType,
    required this.userInvolved,
    this.postInvolved,
    required this.timeStamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationEntity toEntity() {
    return NotificationEntity(
      notificationType: notificationType.toString(),
      userInvolved: userInvolved.toEntity(),
      postInvolved: postInvolved?.toEntity(),
      timeStamp: timeStamp,
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

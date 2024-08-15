// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      notificationType:
          $enumDecode(_$NotificationTypeEnumMap, json['notificationType']),
      userInvolved:
          UserModel.fromJson(json['userInvolved'] as Map<String, dynamic>),
      postInvolved: json['postInvolved'] == null
          ? null
          : PostModel.fromJson(json['postInvolved'] as Map<String, dynamic>),
      timeStamp: (json['timeStamp'] as num).toInt(),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'notificationType': _$NotificationTypeEnumMap[instance.notificationType]!,
      'userInvolved': instance.userInvolved.toJson(),
      'postInvolved': instance.postInvolved?.toJson(),
      'timeStamp': instance.timeStamp,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.likeNotification: 'likeNotification',
  NotificationType.commentNotification: 'commentNotification',
  NotificationType.followRequest: 'followRequest',
  NotificationType.acceptedFollowRequested: 'acceptedFollowRequested',
  NotificationType.followedYou: 'followedYou',
};

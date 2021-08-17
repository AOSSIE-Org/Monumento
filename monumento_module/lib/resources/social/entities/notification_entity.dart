import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/authentication/entities/user_entity.dart';
import 'package:monumento/resources/social/entities/post_entity.dart';

class NotificationEntity {
  final int notificationType;
  final UserEntity userInvolved;
  final PostEntity postInvolved;
  final int timeStamp;

  const NotificationEntity({
    @required this.notificationType,
    this.userInvolved,
    this.postInvolved,
    @required this.timeStamp,
  });

  NotificationEntity copyWith({
    int notificationType,
    UserEntity userInvolved,
    PostEntity postInvolved,
    int timeStamp,
  }) {
    return NotificationEntity(
      notificationType: notificationType ?? this.notificationType,
      userInvolved: userInvolved ?? this.userInvolved,
      postInvolved: postInvolved ?? this.postInvolved,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }

  @override
  String toString() {
    return 'NotificationEntity{notificationType: $notificationType, userInvolved: $userInvolved, postInvolved: $postInvolved, timeStamp: $timeStamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationEntity &&
          runtimeType == other.runtimeType &&
          notificationType == other.notificationType &&
          userInvolved == other.userInvolved &&
          postInvolved == other.postInvolved &&
          timeStamp == other.timeStamp);

  @override
  int get hashCode =>
      notificationType.hashCode ^
      userInvolved.hashCode ^
      postInvolved.hashCode ^
      timeStamp.hashCode;

  factory NotificationEntity.fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      notificationType: map['notificationType'] as int,
      userInvolved: map['userInvolved'] as UserEntity,
      postInvolved: map['postInvolved'] as PostEntity,
      timeStamp: map['timeStamp'] as int,
    );
  }

  factory NotificationEntity.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    return NotificationEntity(
      notificationType: data['notificationType'] as int,
      userInvolved: UserEntity.fromMap(data['userInvolved']),
      postInvolved: data['postInvolved'] != null
          ? PostEntity.fromMap(data['postInvolved'])
          : null,
      timeStamp: data['timeStamp'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return postInvolved != null
        ? {
            'notificationType': this.notificationType,
            'userInvolved': this.userInvolved.toMap(),
            'postInvolved': this.postInvolved.toMap(),
            'timeStamp': this.timeStamp,
          }
        : {
            'notificationType': this.notificationType,
            'userInvolved': this.userInvolved.toMap(),
            'timeStamp': this.timeStamp,
          };
  }
}

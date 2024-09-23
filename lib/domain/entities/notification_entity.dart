import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/domain/entities/user_entity.dart';

class NotificationEntity extends Equatable {
  final String notificationType;
  final UserEntity userInvolved;
  final PostEntity? postInvolved;
  final int timeStamp;

  const NotificationEntity({
    required this.notificationType,
    required this.userInvolved,
    this.postInvolved,
    required this.timeStamp,
  });

  @override
  List<Object?> get props =>
      [notificationType, userInvolved, postInvolved, timeStamp];
}

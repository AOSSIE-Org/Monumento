part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  @override
  List<Object> get props => [];
}

class InitialNotificationsLoaded extends NotificationsState {
  final List<NotificationModel> initialNotifications;

  InitialNotificationsLoaded({this.initialNotifications});

  @override
  List<Object> get props => [initialNotifications];
}

class MoreNotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  bool hasReachedMax;
  MoreNotificationsLoaded({@required this.notifications}) {
    if (notifications.isEmpty) {
      hasReachedMax = true;
    } else {
      hasReachedMax = false;
    }
  }
  @override
  List<Object> get props => [notifications];
}

class InitialNotificationsLoadingFailed extends NotificationsState {
  @override
  List<Object> get props => [];
}

class MoreNotificationsLoadingFailed extends NotificationsState {
  @override
  List<Object> get props => [];
}

class LoadingInitialNotifications extends NotificationsState {
  @override
  List<Object> get props => [];
}

class LoadingMoreNotifications extends NotificationsState {
  @override
  List<Object> get props => [];
}

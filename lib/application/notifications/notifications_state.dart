part of 'notifications_bloc.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

final class NotificationsInitial extends NotificationsState {}

class InitialNotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> initialNotifications;

  const InitialNotificationsLoaded({required this.initialNotifications});

  @override
  List<Object> get props => [initialNotifications];
}

class MoreNotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final bool hasReachedMax;
  const MoreNotificationsLoaded(
      {required this.notifications, required this.hasReachedMax});

  @override
  List<Object> get props => [notifications, hasReachedMax];
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

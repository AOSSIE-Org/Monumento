part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class LoadInitialNotifications extends NotificationsEvent {
  @override
  List<Object> get props => [];
}

class LoadMoreNotifications extends NotificationsEvent {
  final String startAfterDocId;

  const LoadMoreNotifications({required this.startAfterDocId});
  @override
  List<Object> get props => [startAfterDocId];
}

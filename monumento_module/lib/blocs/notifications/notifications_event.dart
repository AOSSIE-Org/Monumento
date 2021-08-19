part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
}

class LoadInitialNotifications extends NotificationsEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoadMoreNotifications extends NotificationsEvent {
  final DocumentSnapshot startAfterDoc;

  LoadMoreNotifications({@required this.startAfterDoc});
  @override
  List<Object> get props => [startAfterDoc.id];
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monumento/resources/social/models/notification_model.dart';
import 'package:monumento/resources/social/social_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final SocialRepository _socialRepository;

  NotificationsBloc({SocialRepository socialRepository})
      : assert(socialRepository != null),
        _socialRepository = socialRepository,
        super(NotificationsInitial());

  @override
  Stream<NotificationsState> mapEventToState(
    NotificationsEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is LoadInitialNotifications) {
      yield* _mapLoadInitialNotificationsToState();
    } else if (event is LoadMoreNotifications) {
      yield* _mapLoadMoreNotificationsToState(
          startAfterDoc: event.startAfterDoc);
    }
  }

  Stream<NotificationsState> _mapLoadInitialNotificationsToState() async* {
    try {
      yield LoadingInitialNotifications();
      List<NotificationModel> notifications =
          await _socialRepository.getInitialNotifications();
      yield InitialNotificationsLoaded(initialNotifications: notifications);
    } catch (e) {
      yield InitialNotificationsLoadingFailed();
      print(e.toString());
    }
  }

  Stream<NotificationsState> _mapLoadMoreNotificationsToState(
      {DocumentSnapshot<Object> startAfterDoc}) async* {
    try {
      yield LoadingMoreNotifications();
      List<NotificationModel> notifications = await _socialRepository
          .getMoreNotifications(startAfterDoc: startAfterDoc);
      yield MoreNotificationsLoaded(notifications: notifications);
    } catch (e) {
      yield MoreNotificationsLoadingFailed();
      print(e.toString());
    }
  }
}

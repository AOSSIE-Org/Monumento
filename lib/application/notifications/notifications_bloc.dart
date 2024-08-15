import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/data/models/notification_model.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final SocialRepository _socialRepository;
  NotificationsBloc(this._socialRepository) : super(NotificationsInitial()) {
    on<LoadInitialNotifications>(_mapLoadInitialNotificationsToState);
    on<LoadMoreNotifications>(_mapLoadMoreNotificationsToState);
  }

  Future<void> _mapLoadInitialNotificationsToState(
    LoadInitialNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(LoadingInitialNotifications());
    try {
      List<NotificationModel> notifications =
          await _socialRepository.getInitialNotifications();
      emit(InitialNotificationsLoaded(initialNotifications: notifications));
    } catch (e) {
      emit(InitialNotificationsLoadingFailed());
    }
  }

  Future<void> _mapLoadMoreNotificationsToState(
    LoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is MoreNotificationsLoaded &&
        (state as MoreNotificationsLoaded).hasReachedMax) return;
    emit(LoadingMoreNotifications());
    try {
      final notifications = await _socialRepository.getMoreNotifications(
          startAfterDocId: event.startAfterDocId);
      emit(MoreNotificationsLoaded(
        hasReachedMax: notifications.isEmpty,
        notifications: notifications,
      ));
    } catch (e) {
      emit(MoreNotificationsLoadingFailed());
    }
  }
}

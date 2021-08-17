import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:monumento/blocs/notifications/notifications_bloc.dart';
import 'package:monumento/resources/social/models/notification_model.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:monumento/ui/screens/notifications/components/notification_tile.dart';
import 'package:monumento/ui/widgets/custom_app_bar.dart';
import 'package:monumento/utilities/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen();

  static final String route = "/notificationScreen";

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationsBloc _notificationsBloc;
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _notificationsBloc = NotificationsBloc(
        socialRepository: RepositoryProvider.of<SocialRepository>(context));
    _notificationsBloc.add(LoadInitialNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LazyLoadScrollView(
          scrollOffset: 300,
          onEndOfPage: _loadMoreNotifications,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: CustomAppBar(
                  title: 'Notifications',
                  textStyle: kStyle28W600,
                  showNotificationIcon: false,
                ),
              ),
              BlocBuilder<NotificationsBloc, NotificationsState>(
                bloc: _notificationsBloc,
                builder: (context, state) {
                  if (state is InitialNotificationsLoadingFailed) {
                    return SliverFillRemaining(
                        child: Center(child: Text("FAiled")));
                  }
                  if (state is InitialNotificationsLoaded ||
                      state is MoreNotificationsLoaded ||
                      state is LoadingMoreNotifications ||
                      state is MoreNotificationsLoadingFailed) {
                    if (state is InitialNotificationsLoaded) {
                      notifications = [];
                      notifications.insertAll(
                          notifications.length, state.initialNotifications);
                    }
                    if (state is MoreNotificationsLoaded) {
                      notifications.insertAll(
                          notifications.length, state.notifications);
                    }
                    if (notifications.isEmpty) {
                      return SliverFillRemaining(
                          child: Center(
                        child: Text("No notifications"),
                      ));
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((_, index) {
                        if (state is LoadingMoreNotifications &&
                            index == notifications.length - 1) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: NotificationTile(
                                    userInvolved:
                                        notifications[index].userInvolved,
                                    notificationType:
                                        notifications[index].notificationType,
                                    postInvolved:
                                        notifications[index].postInvolved),
                              ),
                              CircularProgressIndicator(),
                            ],
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: NotificationTile(
                              userInvolved: notifications[index].userInvolved,
                              notificationType:
                                  notifications[index].notificationType,
                              postInvolved: notifications[index].postInvolved),
                        );
                      }, childCount: notifications.length),
                    );
                  }
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _loadMoreNotifications() {
    _notificationsBloc.add(LoadMoreNotifications(
        startAfterDoc: notifications.last.documentSnapshot));
  }
}

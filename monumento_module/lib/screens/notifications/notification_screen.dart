import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:monumento/blocs/notifications/notifications_bloc.dart';
import 'package:monumento/constants.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/resources/social/models/notification_model.dart';
import 'package:monumento/resources/social/models/post_model.dart';
import 'package:monumento/utils/custom_app_bar.dart';

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
    _notificationsBloc = BlocProvider.of<NotificationsBloc>(context);
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

class NotificationTile extends StatelessWidget {
  final NotificationType notificationType;
  final UserModel userInvolved;
  final UserModel currentUser;
  final PostModel postInvolved;

  const NotificationTile(
      {this.notificationType,
        this.postInvolved,
        this.currentUser,
        this.userInvolved});

  final List<String> texts = const [
    " commented on your post",
    " liked your post",
    " followed you",
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {},
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: userInvolved.profilePictureUrl,
                    height: 36,
                    placeholder: (x, y) {
                      // return  ProfilePictureLoading();
                      return Container();
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: userInvolved.username + " ",
                    style: kStyle14W600.copyWith(color: Colors.black),
                    recognizer: TapGestureRecognizer()..onTap = () {}),
                TextSpan(
                  text: getText(),
                  style: TextStyle(color: Colors.black),
                ),
              ]),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          postInvolved != null
              ? ClipRRect(
            child: CachedNetworkImage(
              imageUrl: postInvolved.imageUrl,
              height: 36,
            ),
            borderRadius: BorderRadius.circular(4),
          )
              : Container()
        ],
      ),
    );
  }

  String getText() {
    if (NotificationType.likeNotification == notificationType) {
      return texts[1];
    } else if (NotificationType.commentNotification == notificationType) {
      return texts[0];
    } else if (NotificationType.followedYou == notificationType) {
      return texts[2];
    }
    return "";
  }
}

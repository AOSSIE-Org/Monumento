import 'package:flutter/material.dart';
import 'package:monumento/ui/screens/notifications/notification_screen.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar(
      {Key key,
      @required this.title,
      @required this.textStyle,
      this.showNotificationIcon = true})
      : super(key: key);
  final String title;
  final TextStyle textStyle;
  final bool showNotificationIcon;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          Text(
            title,
            style: textStyle,
          ),
          Spacer(),
          showNotificationIcon
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(NotificationsScreen.route);
                  },
                  icon: Icon(Icons.notifications_active_outlined))
              : Container()
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/resources/authentication/models/user_model.dart';
import 'package:monumento/ui/screens/notifications/notification_screen.dart';

import '../../navigation/arguments.dart';
import '../screens/profile/profile_screen.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key key,
    @required this.title,
    @required this.textStyle,
    this.userModel,
    this.showNotificationIcon = true,
    this.showProfileIcon = true})
      : super(key: key);
  final String title;
  final TextStyle textStyle;
  final bool showNotificationIcon;
  final bool showProfileIcon;
  final UserModel userModel;


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
              : Container(),
          showProfileIcon ?
          IconButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, ProfileScreen.route,
                    arguments: ProfileScreenArguments(user:userModel));
              },
              icon: Icon(Icons.person))
              : Container()
        ],
      ),
    );
  }
}

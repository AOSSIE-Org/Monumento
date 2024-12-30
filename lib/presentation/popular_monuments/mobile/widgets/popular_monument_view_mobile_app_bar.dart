import 'package:flutter/material.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/notification/desktop/notification_view_desktop.dart';
import 'package:monumento/utils/app_colors.dart';

//TODO: iam going to generalize it overall monumento app later
class PopularMonumnetsViewMobileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final double height;
  final double elevation;
  const PopularMonumnetsViewMobileAppBar(
      {Key? key, this.height = kToolbarHeight, this.elevation = 4})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.appBackground,
      elevation: elevation,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Assets.desktop.logoDesktop.svg(
            width: 161,
            height: 25,
          ),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) {
                      return const NotificationViewDesktop();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColor.appBlack))
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

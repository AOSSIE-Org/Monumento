import 'package:flutter/material.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class NavigationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NavigationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Popular Monuments',
        style: AppTextStyles.s28(
          color: AppColor.appSecondary,
          fontType: FontType.MEDIUM,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColor.appBlack,
      ),
      backgroundColor: AppColor.appBackground,
      elevation: 1,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColor.appSecondary,
          ),
          onPressed: () {},
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

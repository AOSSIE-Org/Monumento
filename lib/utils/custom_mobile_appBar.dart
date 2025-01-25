import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/utils/app_colors.dart';

class CustomMobileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final double height;
  final double elevation;
  // Accept a list of action widgets
  final List<Widget> actions;

  /// Accept logo as a string
  final String logoPath;

  const CustomMobileAppBar({
    Key? key,
    this.height = kToolbarHeight,
    this.elevation = 4,
    required this.actions,
    required this.logoPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.appBackground,
      foregroundColor: AppColor.appBlack,
      elevation: elevation,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            logoPath,
            height: 25,
            width: 161,
          ),
          ...actions,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

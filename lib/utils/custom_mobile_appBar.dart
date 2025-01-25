import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/utils/app_colors.dart';

class CustomMobileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final double height;
  final double elevation;
  // Accept a list of action widgets
  final List<Widget>? actions;

  /// Accept logo as a string
  final String logoPath;
  final Widget? leading;

  const CustomMobileAppBar({
    Key? key,
    this.height = kToolbarHeight,
    this.elevation = 4,
    this.actions,
    required this.logoPath,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.appBackground,
      foregroundColor: AppColor.appBlack,
      elevation: elevation,
      leading: leading,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            logoPath,
            height: 25,
            width: 161,
          ),
          ...?actions, //*This means if actions is null, it won't add anything to the widget tree
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

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
  final String? logoPath;
  final Widget? leading;
  final String? title;

  const CustomMobileAppBar({
    Key? key,
    this.height = kToolbarHeight,
    this.elevation = 1,
    this.actions,
    this.logoPath,
    this.leading,
    this.title,
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
          Row(
            spacing: 12,
            children: [
              if (logoPath != null)
                SvgPicture.asset(
                  logoPath!,
                  height: 25,
                  width: 161,
                ),
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    color: AppColor.appBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              if (actions != null) ...actions! else const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

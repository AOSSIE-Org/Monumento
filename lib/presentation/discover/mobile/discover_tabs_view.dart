import 'package:flutter/material.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/follow_button.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class DiscoverTabsView extends StatefulWidget {
  final UserEntity user;
  const DiscoverTabsView({super.key, required this.user});

  @override
  State<DiscoverTabsView> createState() => _DiscoverTabsViewState();
}

class _DiscoverTabsViewState extends State<DiscoverTabsView> {

  @override
  Widget build(BuildContext context) {
    bool isAccountOwner = false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'Posts',
          style: AppTextStyles.s16(
            color: AppColor.appSecondary,
            fontType: FontType.MEDIUM,
            isDesktop: true,
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
          width: 120,
          child: FollowButton(isAccountOwner: isAccountOwner, targetUser: widget.user))
      ],
    );
  }
}

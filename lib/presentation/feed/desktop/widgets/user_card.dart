import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class UserCard extends StatelessWidget {
  final UserEntity user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          user.profilePictureUrl ?? defaultProfilePicture,
        ),
      ),
      title: Text(user.name),
      subtitle: Text(user.username!),
      trailing: InkWell(
        onTap: () {},
        child: Container(
          width: 80.w,
          height: 30.h,
          decoration: BoxDecoration(
            color: AppColor.appPrimary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              'Follow',
              style: AppTextStyles.s12(
                color: AppColor.appSecondary,
                fontType: FontType.MEDIUM,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

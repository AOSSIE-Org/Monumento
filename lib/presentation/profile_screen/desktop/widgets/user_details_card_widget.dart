import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class UserDetailsCardWidget extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onPostsTap;
  final VoidCallback onBookmarksTap;
  final int currentPage;
  const UserDetailsCardWidget(
      {super.key,
      required this.user,
      required this.onPostsTap,
      required this.onBookmarksTap,
      this.currentPage = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 980,
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.profilePictureUrl ?? defaultProfilePicture,
                      fit: BoxFit.cover,
                      width: 52,
                      height: 52,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 24,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: AppTextStyles.s18(
                            color: AppColor.appSecondary,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text("/"),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          '@${user.username}',
                          style: AppTextStyles.s14(
                            color: AppColor.appSecondary,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          user.status,
                          style: AppTextStyles.s14(
                            color: AppColor.appSecondary,
                            fontType: FontType.REGULAR,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          user.posts.length.toString(),
                          style: AppTextStyles.s24(
                            color: AppColor.appSecondary,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Posts',
                          style: AppTextStyles.s14(
                            color: AppColor.appGrey,
                            fontType: FontType.REGULAR,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    Column(
                      children: [
                        Text(
                          user.followers.length.toString(),
                          style: AppTextStyles.s24(
                            color: AppColor.appSecondary,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Followers',
                          style: AppTextStyles.s14(
                            color: AppColor.appGrey,
                            fontType: FontType.REGULAR,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    Column(
                      children: [
                        Text(
                          user.following.length.toString(),
                          style: AppTextStyles.s24(
                            color: AppColor.appSecondary,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Following',
                          style: AppTextStyles.s14(
                            color: AppColor.appGrey,
                            fontType: FontType.REGULAR,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              color: AppColor.appGrey,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: onPostsTap,
                  child: Text(
                    'Posts',
                    style: AppTextStyles.s16(
                      color: currentPage == 0
                          ? AppColor.appSecondary
                          : AppColor.appTextGrey,
                      fontType: FontType.MEDIUM,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                GestureDetector(
                  onTap: onBookmarksTap,
                  child: Text(
                    'Bookmarks',
                    style: AppTextStyles.s16(
                      color: currentPage == 1
                          ? AppColor.appSecondary
                          : AppColor.appTextGrey,
                      fontType: FontType.MEDIUM,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

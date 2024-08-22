import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/presentation/profile_screen/mobile/user_connections_screen.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/follow_button.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class DiscoverProfileViewMobile extends StatefulWidget {
  final UserEntity user;
  const DiscoverProfileViewMobile({super.key, required this.user});

  @override
  State<DiscoverProfileViewMobile> createState() =>
      _DiscoverProfileViewMobileState();
}

class _DiscoverProfileViewMobileState extends State<DiscoverProfileViewMobile>
    with TickerProviderStateMixin {
  bool isAccountOwner = false;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppColor.appBackground,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: AppColor.appBlack,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/mobile/logo_profile.svg',
                  height: 25,
                  width: 161,
                ),
              ],
            )),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                                radius: 40,
                                backgroundImage: CachedNetworkImageProvider(
                                  widget.user.profilePictureUrl ??
                                      defaultProfilePicture,
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _tabController.animateTo(0);
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.user.posts.length.toString(),
                                        style: AppTextStyles.s18(
                                          color: AppColor.appBlack,
                                          fontType: FontType.SEMI_BOLD,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text("Posts",
                                          style: AppTextStyles.s12(
                                            color: AppColor.appGrey,
                                            fontType: FontType.MEDIUM,
                                          )),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const UserConnectionsScreen(
                                                index: 0,
                                              )),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.user.followers.length.toString(),
                                        style: AppTextStyles.s18(
                                          color: AppColor.appBlack,
                                          fontType: FontType.SEMI_BOLD,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text("Followers",
                                          style: AppTextStyles.s12(
                                            color: AppColor.appGrey,
                                            fontType: FontType.MEDIUM,
                                          )),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const UserConnectionsScreen(
                                                index: 1,
                                              )),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.user.following.length.toString(),
                                        style: AppTextStyles.s18(
                                          color: AppColor.appBlack,
                                          fontType: FontType.SEMI_BOLD,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text("Following",
                                          style: AppTextStyles.s12(
                                            color: AppColor.appGrey,
                                            fontType: FontType.MEDIUM,
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ]),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.user.name,
                        style: AppTextStyles.s16(
                          color: AppColor.appBlack,
                          fontType: FontType.MEDIUM,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        '@${widget.user.username}',
                        style: AppTextStyles.s12(
                          color: AppColor.appLightGrey,
                          fontType: FontType.REGULAR,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.user.status,
                        style: AppTextStyles.s12(
                          color: AppColor.appGrey,
                          fontType: FontType.REGULAR,
                        ),
                      ),
                    ],
                  )),
              FollowButton(
                  isAccountOwner: isAccountOwner, targetUser: widget.user),
              const Divider(thickness: 2),
            ],
          ),
        ));
  }
}

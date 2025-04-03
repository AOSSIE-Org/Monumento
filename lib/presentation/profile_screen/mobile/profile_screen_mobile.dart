import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/profile/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/notification/desktop/notification_view_desktop.dart';
import 'package:monumento/presentation/profile_screen/mobile/user_connections_screen.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/follow_button.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/profile_tabs_view.dart';
import 'package:monumento/presentation/settings/mobile/settings_view_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class ProfileScreenMobile extends StatefulWidget {
  const ProfileScreenMobile({super.key});

  @override
  State<ProfileScreenMobile> createState() => _ProfileScreenMobileState();
}

class _ProfileScreenMobileState extends State<ProfileScreenMobile>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future<void> _refreshData() async {
    // Reload user data and posts
    locator<AuthenticationBloc>().add(AppStarted());
    locator<AuthenticationBloc>().add(LoggedIn());
    locator<ProfilePostsBloc>().add(const LoadInitialProfilePosts());
  }

  @override
  Widget build(BuildContext context) {
    bool isAccountOwner = true;

    return Scaffold(
      appBar: CustomMobileAppBar(
        logoPath: Assets.mobile.logoProfile.path,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) {
                    return const NotificationViewDesktop();
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColor.appBlack,
            ),
          ),
          IconButton(
            onPressed: () {
              SettingsBottomSheet().settingsBottomSheet(context);
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColor.appBlack,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColor.appPrimary,
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          bloc: locator<AuthenticationBloc>(),
          builder: (context, state) {
            if (state is! Authenticated) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: CachedNetworkImageProvider(
                                state.user.profilePictureUrl ??
                                    defaultProfilePicture,
                              ),
                            ),
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
                                        state.user.posts.length.toString(),
                                        style: AppTextStyles.s16(
                                          color: AppColor.appBlack,
                                          fontType: FontType.MEDIUM,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Posts',
                                        style: AppTextStyles.s12(
                                          color: AppColor.appGrey,
                                          fontType: FontType.REGULAR,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserConnectionsScreen(
                                          index: 0,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        state.user.followers.length.toString(),
                                        style: AppTextStyles.s16(
                                          color: AppColor.appBlack,
                                          fontType: FontType.MEDIUM,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Followers',
                                        style: AppTextStyles.s12(
                                          color: AppColor.appGrey,
                                          fontType: FontType.REGULAR,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserConnectionsScreen(
                                          index: 1,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        state.user.following.length.toString(),
                                        style: AppTextStyles.s16(
                                          color: AppColor.appBlack,
                                          fontType: FontType.MEDIUM,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Following',
                                        style: AppTextStyles.s12(
                                          color: AppColor.appGrey,
                                          fontType: FontType.REGULAR,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          state.user.name,
                          style: AppTextStyles.s16(
                            color: AppColor.appBlack,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          '@${state.user.username}',
                          style: AppTextStyles.s12(
                            color: AppColor.appLightGrey,
                            fontType: FontType.REGULAR,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          state.user.status,
                          style: AppTextStyles.s12(
                            color: AppColor.appGrey,
                            fontType: FontType.REGULAR,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FollowButton(
                    isAccountOwner: isAccountOwner,
                    targetUser: state.user),
                  const Divider(thickness: 2),
                  ProfileTabsView(
                    tabController: _tabController,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

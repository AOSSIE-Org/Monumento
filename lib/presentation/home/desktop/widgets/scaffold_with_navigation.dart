import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'navigation_app_bar.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final String title;
  final Function(int) onDestinationSelected;
  const ScaffoldWithNavigation({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final breakpoint = ResponsiveBreakpoints.of(context).breakpoint;
    return switch (breakpoint.name) {
      MOBILE ||
      TABLET =>
        _ScaffoldWithDrawer(body, selectedIndex, onDestinationSelected, title),
      (_) =>
        _ScaffoldWithNavigationRail(body, selectedIndex, onDestinationSelected),
    };
  }
}

class _ScaffoldWithNavigationRail extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  const _ScaffoldWithNavigationRail(
      this.body, this.selectedIndex, this.onDestinationSelected);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              Expanded(
                child: _NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  expand: ResponsiveBreakpoints.of(context).screenWidth > 1000
                      ? true
                      : false,
                ),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: colorScheme.primary.withOpacity(0.2),
          ),
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}

class _ScaffoldWithDrawer extends StatelessWidget {
  final String title;
  final Widget body;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  const _ScaffoldWithDrawer(
      this.body, this.selectedIndex, this.onDestinationSelected, this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavigationAppBar(
        title: title,
      ),
      body: body,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(border: Border()),
              margin: EdgeInsets.zero,
              child: Center(
                  child: Image.asset(
                'assets/logo_auth.png',
                height: 72,
              )),
            ),
            Expanded(
              child: _NavigationRailDrawer(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                expand: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationRailDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  const _NavigationRailDrawer({
    required this.expand,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final bool expand;

  @override
  State<_NavigationRailDrawer> createState() => _NavigationRailDrawerState();
}

class _NavigationRailDrawerState extends State<_NavigationRailDrawer> {
  SideMenuController sideMenu = SideMenuController();

  @override
  void initState() {
    sideMenu.changePage(widget.selectedIndex);
    sideMenu.addListener((i) {
      widget.onDestinationSelected(i);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      items: [
        SideMenuItem(
          title: 'Home',
          onTap: (index, _) {
            sideMenu.changePage(index);
          },
          iconWidget: SvgPicture.asset(
            widget.selectedIndex == 0
                ? 'assets/icons/ic_home_selected.svg'
                : 'assets/icons/ic_home.svg',
            height: 18,
          ),
        ),
        SideMenuItem(
          title: 'Your Feed',
          onTap: (index, _) {
            sideMenu.changePage(index);
          },
          iconWidget: SvgPicture.asset(
            widget.selectedIndex == 1
                ? 'assets/icons/ic_feed_selected.svg'
                : 'assets/icons/ic_feed.svg',
            height: 18,
          ),
        ),
        SideMenuItem(
          title: 'Discover',
          onTap: (index, _) {
            sideMenu.changePage(index);
          },
          iconWidget: SvgPicture.asset(
            widget.selectedIndex == 2
                ? 'assets/icons/ic_discover_selected.svg'
                : 'assets/icons/ic_discover.svg',
            height: 18,
          ),
        ),
        SideMenuItem(
          title: 'Profile',
          onTap: (index, _) {
            sideMenu.changePage(index);
          },
          iconWidget: SvgPicture.asset(
            widget.selectedIndex == 3
                ? 'assets/icons/ic_profile_selected.svg'
                : 'assets/icons/ic_profile.svg',
            height: 18,
          ),
        ),
        SideMenuItem(
          title: 'Settings',
          onTap: (index, _) {
            sideMenu.changePage(index);
          },
          iconWidget: SvgPicture.asset(
            widget.selectedIndex == 4
                ? 'assets/icons/ic_settings_selected.svg'
                : 'assets/icons/ic_settings.svg',
            height: 18,
          ),
        ),
      ],
      style: SideMenuStyle(
        selectedColor: AppColor.appPrimary,
        itemHeight: 44,
        iconSize: 18,
        selectedTitleTextStyle: AppTextStyles.s16(
          color: AppColor.appSecondary,
          fontType: FontType.MEDIUM,
          isDesktop: true,
        ),
        unselectedTitleTextStyle: AppTextStyles.s14(
          color: AppColor.appTextGrey,
          fontType: FontType.MEDIUM,
          isDesktop: true,
        ),
      ),
      controller: sideMenu,
    );
  }
}

class _NavigationRail extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  const _NavigationRail({
    required this.expand,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final bool expand;

  @override
  State<_NavigationRail> createState() => _NavigationRailState();
}

class _NavigationRailState extends State<_NavigationRail> {
  SideMenuController sideMenu = SideMenuController();
  bool showHeader = true;
  @override
  void initState() {
    sideMenu.addListener((i) {
      widget.onDestinationSelected(i);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<SideMenuItem> items = [
      SideMenuItem(
        title: 'Home',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        iconWidget: SvgPicture.asset(
          widget.selectedIndex != 0
              ? 'assets/icons/ic_home.svg'
              : 'assets/icons/ic_home_selected.svg',
          height: 18,
        ),
      ),
      SideMenuItem(
        title: 'Your Feed',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        iconWidget: SvgPicture.asset(
          widget.selectedIndex != 1
              ? 'assets/icons/ic_feed.svg'
              : 'assets/icons/ic_feed_selected.svg',
          height: 18,
        ),
      ),
      SideMenuItem(
        title: 'Discover',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        iconWidget: SvgPicture.asset(
          widget.selectedIndex != 2
              ? 'assets/icons/ic_discover.svg'
              : 'assets/icons/ic_discover_selected.svg',
          height: 18,
        ),
      ),
      SideMenuItem(
        title: 'Profile',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        iconWidget: SvgPicture.asset(
          widget.selectedIndex != 3
              ? 'assets/icons/ic_profile.svg'
              : 'assets/icons/ic_profile_selected.svg',
          height: 18,
        ),
      ),
      SideMenuItem(
        title: 'Settings',
        onTap: (index, _) {
          sideMenu.changePage(index);
        },
        iconWidget: SvgPicture.asset(
          widget.selectedIndex != 4
              ? 'assets/icons/ic_settings.svg'
              : 'assets/icons/ic_settings_selected.svg',
          height: 18,
        ),
      ),
      SideMenuItem(
        title: 'Exit',
        onTap: (a, b) {},
        icon: const Icon(Icons.exit_to_app),
      ),
    ];
    return SideMenu(
      controller: sideMenu,
      style: SideMenuStyle(
        selectedColor: AppColor.appPrimary,
        itemHeight: 44,
        iconSize: 18,
        selectedTitleTextStyle: AppTextStyles.s14(
          color: AppColor.appSecondary,
          fontType: FontType.MEDIUM,
        ),
        unselectedTitleTextStyle: AppTextStyles.s14(
          color: AppColor.appTextGrey,
          fontType: FontType.MEDIUM,
        ),
      ),
      title: !showHeader
          ? SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    'assets/logo_black.png',
                    height: 36,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          : BlocBuilder<AuthenticationBloc, AuthenticationState>(
              bloc: locator<AuthenticationBloc>(),
              builder: (context, state) {
                state as Authenticated;
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      SvgPicture.asset(
                        'assets/desktop/logo_desktop.svg',
                        height: 24,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColor.appGreyAccent,
                              child: state.user.profilePictureUrl == null
                                  ? SvgPicture.asset(
                                      'assets/icons/ic_user.svg',
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: state.user.profilePictureUrl!,
                                      width: 64,
                                      height: 64,
                                    )),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            state.user.name,
                            style: AppTextStyles.s14(
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
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            state.user.status,
                            style: AppTextStyles.s12(
                              color: AppColor.appGrey,
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    state.user.posts.length.toString(),
                                    style: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.SEMI_BOLD,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
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
                              const SizedBox(
                                height: 40,
                                child: VerticalDivider(
                                  thickness: 1,
                                  width: 40,
                                  color: AppColor.appGreyAccent,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    state.user.followers.length.toString(),
                                    style: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.SEMI_BOLD,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
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
                              const SizedBox(
                                height: 40,
                                child: VerticalDivider(
                                  thickness: 1,
                                  width: 40,
                                  color: AppColor.appGreyAccent,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    state.user.following.length.toString(),
                                    style: AppTextStyles.s14(
                                      color: AppColor.appSecondary,
                                      fontType: FontType.SEMI_BOLD,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
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
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                );
              },
            ),
      onDisplayModeChanged: (mode) {
        if (mode == SideMenuDisplayMode.compact) {
          showHeader = false;
        } else {
          showHeader = true;
        }
      },
      collapseWidth: 1130,
      items: items,
    );
  }
}

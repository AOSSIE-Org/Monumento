import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
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
                child: Assets.logoAuth.image(height: 72),
              ),
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
                ? Assets.icons.icHomeSelected.path
                : Assets.icons.icHome.path,
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
                ? Assets.icons.icFeedSelected.path
                : Assets.icons.icFeed.path,
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
                ? Assets.icons.icDiscoverSelected.path
                : Assets.icons.icDiscover.path,
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
                ? Assets.icons.icProfileSelected.path
                : Assets.icons.icProfile.path,
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
                ? Assets.icons.icSettingsSelected.path
                : Assets.icons.icSettings.path,
            height: 18,
          ),
        ),
        SideMenuItem(
          title: 'Log Out',
          onTap: (a, b) {
            locator<AuthenticationBloc>().add(LogOutPressed());
          },
          icon: const Icon(Icons.exit_to_app),
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
              ? Assets.icons.icHome.path
              : Assets.icons.icHomeSelected.path,
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
              ? Assets.icons.icFeed.path
              : Assets.icons.icFeedSelected.path,
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
              ? Assets.icons.icDiscover.path
              : Assets.icons.icDiscoverSelected.path,
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
              ? Assets.icons.icProfile.path
              : Assets.icons.icProfileSelected.path,
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
              ? Assets.icons.icSettings.path
              : Assets.icons.icSettingsSelected.path,
          height: 18,
        ),
      ),
      SideMenuItem(
        title: 'Log Out',
        onTap: (a, b) {
          locator<AuthenticationBloc>().add(LogOutPressed());
        },
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
                  Assets.logoBlack.image(height: 36),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          : BlocConsumer<AuthenticationBloc, AuthenticationState>(
              bloc: locator<AuthenticationBloc>(),
              listener: (context, state) {
                if (state is Unauthenticated) {
                  while (context.canPop() == true) {
                    context.pop();
                  }
                  if (mounted) {
                    context.pushReplacement('/');
                  }
                }
              },
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
                      Assets.desktop.logoDesktop.svg(
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
                              foregroundImage: state.user.profilePictureUrl == null
                                  ? SvgPicture.asset(
                                      Assets.icons.icUser.path,
                                    ) as ImageProvider
                                  : CachedNetworkImageProvider(
                                      state.user.profilePictureUrl!,
                                      maxWidth: 64,
                                      maxHeight: 64,
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

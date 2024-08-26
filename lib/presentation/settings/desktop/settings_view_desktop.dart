import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

import 'edit_profile_widget.dart';

class SettingsViewDesktop extends StatefulWidget {
  const SettingsViewDesktop({super.key});

  @override
  State<SettingsViewDesktop> createState() => _SettingsViewDesktopState();
}

class _SettingsViewDesktopState extends State<SettingsViewDesktop> {
  SideMenuController sideMenu = SideMenuController();
  int selectedIndex = 0;
  @override
  void initState() {
    sideMenu.addListener((i) {
      setState(() {
        selectedIndex = i;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.appBackground,
        body: Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SideMenu(
                style: SideMenuStyle(
                  selectedColor: AppColor.appPrimary,
                  itemHeight: 44,
                  iconSize: 18,
                  selectedTitleTextStyle: AppTextStyles.s14(
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
                items: [
                  SideMenuItem(
                    title: 'Profile',
                    onTap: (index, _) {
                      sideMenu.changePage(index);
                    },
                  ),
                  SideMenuItem(
                    title: 'Notifications',
                    onTap: (index, _) {
                      sideMenu.changePage(index);
                    },
                  ),
                  SideMenuItem(
                    title: 'Privacy',
                    onTap: (index, _) {
                      sideMenu.changePage(index);
                    },
                  ),
                ],
                controller: sideMenu,
              ),
            )),
            const VerticalDivider(
              width: 1,
              thickness: 1,
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IndexedStack(
                  index: selectedIndex,
                  children: [
                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                      bloc: locator<AuthenticationBloc>(),
                      builder: (context, state) {
                        state as Authenticated;
                        return EditProfileWidget(user: state.user);
                      },
                    ),
                    Center(
                        child: const Text(
                            'In future you will be able to set preferences for notifications')),
                    Center(
                        child: const Text(
                            'In future you will be able to set privacy settings like private account')),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/discover/mobile/discover_view_mobile.dart';
import 'package:monumento/presentation/feed/mobile/widgets/new_post_bottom_sheet.dart';
import 'package:monumento/presentation/feed/mobile/your_feed_view_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/popular_monuments_view_mobile.dart';
import 'package:monumento/presentation/profile_screen/mobile/profile_screen_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';

class HomeViewMobile extends StatefulWidget {
  const HomeViewMobile({super.key});

  @override
  State<HomeViewMobile> createState() => _HomeViewMobileState();
}

class _HomeViewMobileState extends State<HomeViewMobile> {
  int selectedIndex = 0;

  @override
  void initState() {
    locator<PopularMonumentsBloc>().add(GetPopularMonuments());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          const PopularMonumentsViewMobile(),
          const YourFeedViewMobile(),
          Container(),
          const DiscoverViewMobile(),
          const ProfileScreenMobile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 2) {
            NewPostBottomSheet().newPostBottomSheet(context);
          } else {
            setState(() {
              selectedIndex = index;
            });
          }
        },
        backgroundColor: AppColor.appWhite,
        selectedItemColor: AppColor.appPrimary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              label: 'Home',
              icon: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SvgPicture.asset(
                  Assets.icons.icHomeSelected.path,
                ),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SvgPicture.asset(
                  Assets.icons.icHomeSelected.path,
                  // ignore: deprecated_member_use
                  color: AppColor.appPrimary,
                ),
              )),
          BottomNavigationBarItem(
              label: 'Feed',
              icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Assets.icons.icFeedSelected.svg(),
              ),
              activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SvgPicture.asset(
                    Assets.icons.icFeedSelected.path,
                    // ignore: deprecated_member_use
                    color: AppColor.appPrimary,
                  ))),
          BottomNavigationBarItem(
            label: 'Add Post',
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                      offset: Offset(0, -3),
                      blurRadius: 36)
                ],
                color: AppColor.appPrimary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.add,
                color: AppColor.appBlack,
              ),
            ),
          ),
          BottomNavigationBarItem(
              label: 'Discover',
              icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      SvgPicture.asset(Assets.icons.icDiscoverSelected.path)),
              activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SvgPicture.asset(Assets.icons.icDiscoverSelected.path,
                      // ignore: deprecated_member_use
                      color: AppColor.appPrimary))),
          BottomNavigationBarItem(
              label: 'Profile',
              icon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset(Assets.icons.icProfileSelected.path),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset(Assets.icons.icProfileSelected.path,
                    // ignore: deprecated_member_use
                    color: AppColor.appPrimary),
              )),
        ],
        currentIndex: selectedIndex,
      ),
    );
  }
}

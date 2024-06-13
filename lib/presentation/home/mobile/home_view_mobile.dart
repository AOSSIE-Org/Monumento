import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/presentation/home/mobile/widgets/new_post_bottom_sheet.dart';
import 'package:monumento/presentation/popular_monuments/mobile/popular_monuments_view_mobile.dart';
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
      appBar: AppBar(
          backgroundColor: AppColor.appBackground,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                'assets/desktop/logo_desktop.svg',
                height: 25,
                width: 161,
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColor.appBlack))
            ],
          )),
      body: IndexedStack(
        index: selectedIndex,
        children:[
          const PopularMonumentsViewMobile(),
          const Text("Feeds"),
          Container(),
          const Text("Discover"),
          const Text("Profile"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index==2){NewPostBottomSheet().newPostBottomSheet(context);}
          else{
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
                  'assets/icons/ic_home_selected.svg',
                ),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SvgPicture.asset(
                  'assets/icons/ic_home_selected.svg',
                  // ignore: deprecated_member_use
                  color: AppColor.appPrimary,
                ),
              )),
          BottomNavigationBarItem(
              label: 'Feed',
              icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SvgPicture.asset('assets/icons/ic_feed_selected.svg'),
              ),
              activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SvgPicture.asset(
                    'assets/icons/ic_feed_selected.svg',
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
                  child: SvgPicture.asset('assets/icons/ic_discover_selected.svg')),
              activeIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SvgPicture.asset('assets/icons/ic_discover_selected.svg',
                      // ignore: deprecated_member_use
                      color: AppColor.appPrimary))),
          BottomNavigationBarItem(
              label: 'Profile',
              icon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset('assets/icons/ic_profile_selected.svg'),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SvgPicture.asset('assets/icons/ic_profile_selected.svg',
                    // ignore: deprecated_member_use
                    color: AppColor.appPrimary),
              )),
        ],
        currentIndex: selectedIndex,
      ),
    );
  }
}

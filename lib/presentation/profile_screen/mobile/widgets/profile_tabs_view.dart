import 'package:flutter/material.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/bookmark_tab_view.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/user_post_tab_view.dart';
import 'package:monumento/utils/app_colors.dart';

class ProfileTabsView extends StatefulWidget {
  final TabController tabController;
  const ProfileTabsView({super.key, required this.tabController});

  @override
  State<ProfileTabsView> createState() => _ProfileTabsViewState();
}

class _ProfileTabsViewState extends State<ProfileTabsView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Column(
      children: [
        TabBar(
            controller: widget.tabController,
            labelColor: AppColor.appBlack,
            unselectedLabelColor: AppColor.appGrey,
            tabs: const [
              Tab(icon: Icon(Icons.window_rounded)),
              Tab(icon: Icon(Icons.bookmark_border_rounded)),
            ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          height: double.maxFinite,
          child: TabBarView(
            controller: widget.tabController,
            children: const [UserPostTabView(), BookmarkTabView()],
          ),
        ),
      ],
    ));
  }
}

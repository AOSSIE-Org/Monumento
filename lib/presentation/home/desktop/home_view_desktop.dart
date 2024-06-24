import 'package:flutter/material.dart';
import 'package:monumento/presentation/feed/desktop/your_feed_view_desktop.dart';
import 'package:monumento/presentation/popular_monuments/desktop/popular_monuments_view_desktop.dart';

import 'widgets/scaffold_with_navigation.dart';

class HomeViewDesktop extends StatefulWidget {
  const HomeViewDesktop({super.key});

  @override
  State<HomeViewDesktop> createState() => _HomeViewDesktopState();
}

class _HomeViewDesktopState extends State<HomeViewDesktop> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavigation(
        title: getAppBarTitle(selectedIndex),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        body: IndexedStack(
          index: selectedIndex,
          children: const [
            PopularMonumentsViewDesktop(),
            YourFeedViewDesktop(),
            Text('Discover'),
            Text('Profile'),
            Text('Settings'),
          ],
        ));
  }
}

String getAppBarTitle(int index) {
  switch (index) {
    case 0:
      return 'Popular Monuments';
    case 1:
      return 'Your Feed';
    case 2:
      return 'Discover';
    case 3:
      return 'Profile';
    case 4:
      return 'Settings';
    default:
      return 'Popular Monuments';
  }
}

import 'package:flutter/material.dart';
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
            Text('Your Feed'),
            Text('Discover'),
            Text('Profile'),
            Text('Settings'),
          ],
        ));
  }
}

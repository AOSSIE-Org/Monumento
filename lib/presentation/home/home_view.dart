import 'package:flutter/material.dart';
import 'package:monumento/presentation/home/desktop/home_view_desktop.dart';
import 'package:monumento/presentation/home/mobile/home_view_mobile.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const HomeViewMobile()
        : const HomeViewDesktop();
  }
}

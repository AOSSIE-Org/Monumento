import 'package:flutter/material.dart';
import 'package:monumento/presentation/discover/desktop/discover_view_desktop.dart';
import 'package:monumento/presentation/discover/mobile/discover_view_mobile.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const DiscoverViewMobile()
        : const DiscoverViewDesktop();
  }
}

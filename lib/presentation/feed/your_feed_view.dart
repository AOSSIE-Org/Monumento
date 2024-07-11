import 'package:flutter/material.dart';
import 'package:monumento/presentation/feed/desktop/your_feed_view_desktop.dart';
import 'package:monumento/presentation/feed/mobile/your_feed_view_mobile.dart';
import 'package:responsive_framework/responsive_framework.dart';

class YourFeedView extends StatelessWidget {
  const YourFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const YourFeedViewMobile()
        : const YourFeedViewDesktop();
  }
}
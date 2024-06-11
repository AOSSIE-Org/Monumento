import 'package:flutter/material.dart';
import 'package:monumento/presentation/popular_monuments/desktop/popular_monuments_view_desktop.dart';
import 'package:monumento/presentation/popular_monuments/mobile/popular_monuments_view_mobile.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PopularMonumentsView extends StatelessWidget {
  const PopularMonumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const PopularMonumentsViewMobile()
        : const PopularMonumentsViewDesktop();
  }
}

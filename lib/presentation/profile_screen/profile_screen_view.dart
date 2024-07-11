import 'package:flutter/material.dart';
import 'package:monumento/presentation/profile_screen/desktop/profile_screen_desktop.dart';
import 'package:monumento/presentation/profile_screen/mobile/profile_screen_mobile.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ProfileScreenView extends StatelessWidget {
  const ProfileScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const ProfileScreenMobile()
        : const ProfileScreenDesktop();
  }
}

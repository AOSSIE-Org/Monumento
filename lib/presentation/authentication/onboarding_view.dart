import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'desktop/onboarding_view_desktop.dart';
import 'mobile/onboarding_view_mobile.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const OnboardingViewMobile()
        : const OnboardingViewDesktop();
  }
}

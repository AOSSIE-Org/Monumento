import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'desktop/sign_up_view_desktop.dart';
import 'mobile/sign_up_view_mobile.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const SignUpViewMobile()
        : const SignUpViewDesktop();
  }
}

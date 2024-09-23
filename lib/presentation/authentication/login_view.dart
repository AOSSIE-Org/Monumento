import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'desktop/login_view_desktop.dart';
import 'mobile/login_view_mobile.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const LoginViewMobile()
        : const LoginViewDesktop();
  }
}

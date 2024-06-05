import 'package:flutter/material.dart';
import 'package:monumento/presentation/authentication/desktop/reset_password_view_desktop.dart';
import 'package:monumento/presentation/authentication/mobile/reset_password_view_mobile.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const ResetPasswordViewMobile()
        : const ResetPasswordViewDesktop();
  }
}

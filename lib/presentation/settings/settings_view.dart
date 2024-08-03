import 'package:flutter/widgets.dart';
import 'package:monumento/presentation/settings/desktop/settings_view_desktop.dart';
import 'package:monumento/presentation/settings/mobile/settings_view_mobile.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const SettingsViewMobile()
        : const SettingsViewDesktop();
  }
}
import 'package:flutter/material.dart';
import 'package:monumento/presentation/community/mobile/community_view_mobile.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CommunityView extends StatelessWidget {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile
        ? const CommunitiesViewMobile()
        : const CommunitiesViewMobile(); //! to be designed later
  }
}

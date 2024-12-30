import 'package:flutter/material.dart';
import 'package:monumento/application/popular_monuments/monument_3d_model/monument_3d_model_bloc.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/popular_monument_view_mobile_app_bar.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/populat_monuments_view_body_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/scan_monuments_screen.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class PopularMonumentsViewMobile extends StatefulWidget {
  const PopularMonumentsViewMobile({super.key});

  @override
  State<PopularMonumentsViewMobile> createState() =>
      _PopularMonumentsViewMobileState();
}

class _PopularMonumentsViewMobileState
    extends State<PopularMonumentsViewMobile> {
  @override
  void initState() {
    locator<Monument3dModelBloc>().add(const ViewMonument3DModel(
        monumentName: "Mount Rushmore National Memorial"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PopularMonumnetsViewMobileAppBar(),
      body: PopularMonumentsViewMobileBodyBlocBuilder(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ScanMonumentsScreen()));
        },
        label: Text(
          "Scan Monuments",
          style: AppTextStyles.textStyle(
              fontType: FontType.MEDIUM, size: 14, isBody: true),
        ),
        backgroundColor: AppColor.appPrimary,
        extendedPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

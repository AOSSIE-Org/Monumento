import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/popular_monuments/monument_3d_model/monument_3d_model_bloc.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/presentation/popular_monuments/desktop/widgets/monument_details_card.dart';
import 'package:monumento/presentation/popular_monuments/mobile/monument_details_view_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/popular_monument_view_mobile_app_bar.dart';
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
      body: BlocBuilder<PopularMonumentsBloc, PopularMonumentsState>(
          bloc: locator<PopularMonumentsBloc>(),
          builder: (context, state) {
            if (state is LoadingPopularMonuments) {
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: AppColor.appPrimary,
                ),
              );
            } else if (state is PopularMonumentsRetrieved) {
              return GridView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                itemCount: state.popularMonuments.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 600.w / 350.h,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return MonumentDetailsCard(
                    monument: state.popularMonuments[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) {
                            return MonumentDetailsViewMobile(
                              monument: state.popularMonuments[index],
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return Center(
                child: Text(state.toString()),
              );
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const ScanMonumentsScreen()),
          );
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

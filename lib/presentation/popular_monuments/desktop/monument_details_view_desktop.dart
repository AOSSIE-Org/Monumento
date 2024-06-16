import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/presentation/popular_monuments/desktop/widgets/image_tile_desktop.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class MonumentDetailsViewDesktop extends StatefulWidget {
  final MonumentEntity monument;
  const MonumentDetailsViewDesktop({super.key, required this.monument});

  @override
  State<MonumentDetailsViewDesktop> createState() =>
      _MonumentDetailsViewDesktopState();
}

class _MonumentDetailsViewDesktopState
    extends State<MonumentDetailsViewDesktop> {
  @override
  void initState() {
    locator<MonumentDetailsBloc>().add(
        GetMonumentWikiDetails(monumentWikiId: widget.monument.wikiPageId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = widget.monument.images;

    return Scaffold(
      backgroundColor: AppColor.appBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.appWhite,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.appBlack,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.appPrimary,
              ),
              onPressed: () {},
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/ic_3d.svg",
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Text(
                    "View in 3D",
                    style: AppTextStyles.s16(
                      color: AppColor.appSecondary,
                      fontType: FontType.MEDIUM,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.appPrimary,
              ),
              onPressed: () {},
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/ic_checkin.svg",
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Text(
                    "Check In",
                    style: AppTextStyles.s16(
                      color: AppColor.appSecondary,
                      fontType: FontType.MEDIUM,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 12.h,
            ),
            Row(
              children: [
                SizedBox(
                  width: 24.w,
                ),
                ImageTileDesktop(
                    index: 0, images: images, width: 584.w, height: 380.w),
                SizedBox(
                  width: 14.w,
                ),
                ImageTileDesktop(
                  index: 1,
                  images: images,
                  width: 380.w,
                  height: 380.w,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 14.w,
                ),
                Column(
                  children: [
                    ImageTileDesktop(
                      index: 2,
                      images: images,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      height: 12.w,
                    ),
                    ImageTileDesktop(
                      index: 3,
                      images: images,
                      color: Colors.yellow,
                    ),
                  ],
                ),
                SizedBox(
                  width: 14.w,
                ),
                Column(
                  children: [
                    ImageTileDesktop(
                      index: 4,
                      images: images,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      height: 14.w,
                    ),
                    ImageTileDesktop(
                      index: 5,
                      images: images,
                      color: Colors.yellow,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 12.w,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.monument.name,
                      style: AppTextStyles.s30(
                        color: AppColor.appSecondary,
                        fontType: FontType.MEDIUM,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "${widget.monument.city}, ${widget.monument.country}",
                      style: AppTextStyles.s18(
                        color: AppColor.appBlack,
                        fontType: FontType.REGULAR,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 36.h,
            ),
            BlocBuilder<MonumentDetailsBloc, MonumentDetailsState>(
              bloc: locator<MonumentDetailsBloc>(),
              builder: (context, state) {
                if (state is LoadingMonumentWikiDetails) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.appPrimary,
                    ),
                  );
                } else if (state is MonumentWikiDetailsRetrieved) {
                  return Column(
                    children: [
                      SizedBox(
                        width: 1024.w,
                        child: Card(
                          child: ExpansionTile(
                            collapsedBackgroundColor: AppColor.appWhite,
                            title: Text(state.wikiData.title),
                            children: [
                              ListTile(
                                title: Text(state.wikiData.description),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1024.w,
                        child: Card(
                          child: ExpansionTile(
                            collapsedBackgroundColor: AppColor.appWhite,
                            title: const Text("More Details"),
                            children: [
                              ListTile(
                                title: Text(state.wikiData.extract),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

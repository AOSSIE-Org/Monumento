import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monumento/application/popular_monuments/bookmark_monuments/bookmark_monuments_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_checkin/monument_checkin_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

import 'monument_model_view_desktop.dart';

class MonumentDetailsViewDesktop extends StatefulWidget {
  final MonumentEntity monument;
  final bool isBookmarked;
  const MonumentDetailsViewDesktop(
      {super.key, required this.monument, this.isBookmarked = false});

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
    if (!widget.isBookmarked) {
      locator<BookmarkMonumentsBloc>()
          .add(CheckIfMonumentIsBookmarked(widget.monument.id));
    }
    locator<MonumentCheckinBloc>()
        .add(CheckIfMonumentIsCheckedIn(monument: widget.monument));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          BlocConsumer<BookmarkMonumentsBloc, BookmarkMonumentsState>(
            bloc: locator<BookmarkMonumentsBloc>(),
            listener: (context, state) {
              if (state is MonumentBookmarked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Monument Bookmarked"),
                  ),
                );
              } else if (state is MonumentUnbookmarked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Removed Monument from Bookmarks"),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (widget.isBookmarked ||
                  (state is MonumentBookmarked ||
                      state is MonumentAlreadyBookmarked)) {
                return IconButton(
                  onPressed: () {
                    locator<BookmarkMonumentsBloc>().add(
                      UnbookmarkMonument(widget.monument),
                    );
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/ic_bookmark_filled.svg",
                    width: 24,
                    height: 24,
                  ),
                );
              } else {
                return IconButton(
                  onPressed: () {
                    locator<BookmarkMonumentsBloc>().add(
                      BookmarkMonument(widget.monument),
                    );
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/ic_bookmark.svg",
                    width: 24,
                    height: 24,
                  ),
                );
              }
            },
          ),
          const SizedBox(
            width: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.appPrimary,
              ),
              onPressed: () async {
                if (kIsWeb) {
                  if (widget.monument.has3DModel) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MonumentModelViewDesktop(
                          monument: widget.monument,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("3D Model not available for this monument"),
                      ),
                    );
                    return;
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "3D Model Viewer is only available on Web as of now"),
                    ),
                  );
                }
              },
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
          BlocConsumer<MonumentCheckinBloc, MonumentCheckinState>(
            bloc: locator<MonumentCheckinBloc>(),
            listener: (context, state) {
              if (state is MonumentCheckinSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Checked In Successfully"),
                  ),
                );
              } else if (state is MonumentCheckinFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.appPrimary,
                  ),
                  onPressed: () {
                    if (state is MonumentCheckedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Already Checked In"),
                        ),
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            "Mark this monument as visited?",
                            textAlign: TextAlign.center,
                          ),
                          content: Container(
                            height: 320,
                            width: 500,
                            child: Column(
                              children: [
                                Image.asset('assets/desktop/checkin.png'),
                                SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                  "Your current location will be used to figure out whether you are near to the Monument or not",
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Spacer(
                                      flex: 2,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: AppTextStyles.s16(
                                          color: AppColor.appSecondary,
                                          fontType: FontType.MEDIUM,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.appPrimary,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        "Check In",
                                        style: AppTextStyles.s14(
                                          color: AppColor.appSecondary,
                                          fontType: FontType.MEDIUM,
                                        ),
                                      ),
                                    ),
                                    const Spacer(
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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
                        state is MonumentCheckedIn ? "Checked In" : "Check In",
                        style: AppTextStyles.s16(
                          color: AppColor.appSecondary,
                          fontType: FontType.MEDIUM,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            width: 10,
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
                Container(
                  width: 584.w,
                  height: 380.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.sp),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        widget.monument.images[0],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 14.w,
                ),
                Container(
                  width: 380.w,
                  height: 380.w,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12.sp),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        widget.monument.images[1],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 14.w,
                ),
                Column(
                  children: [
                    Container(
                      width: 185.w,
                      height: 185.w,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12.sp),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            widget.monument.images[2],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12.w,
                    ),
                    Container(
                      width: 185.w,
                      height: 185.w,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(12.sp),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            widget.monument.images[3],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 14.w,
                ),
                Column(
                  children: [
                    Container(
                      width: 185.w,
                      height: 185.w,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12.sp),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            widget.monument.images[4],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 14.w,
                    ),
                    Container(
                      width: 185.w,
                      height: 185.w,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(12.sp),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            widget.monument.images[5],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
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

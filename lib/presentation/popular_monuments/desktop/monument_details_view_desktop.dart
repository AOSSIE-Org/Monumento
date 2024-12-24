import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/popular_monuments/bookmark_monuments/bookmark_monuments_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_checkin/monument_checkin_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/application/popular_monuments/nearby_places/nearby_places_bloc.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/popular_monuments/desktop/widgets/local_experts_card.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

import 'monument_model_view_desktop.dart';
import 'widgets/nearby_places_card.dart';

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
    locator<NearbyPlacesBloc>().add(
      GetNearbyPlaces(
        latitude: widget.monument.coordinates[0],
        longitude: widget.monument.coordinates[1],
      ),
    );
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
                  icon: Assets.icons.icBookmarkFilled.svg(
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
                  icon: Assets.icons.icBookmark.svg(
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
                  Assets.icons.ic3d.svg(
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
                      isDesktop: true,
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
                          content: SizedBox(
                            height: 320,
                            width: 500,
                            child: Column(
                              children: [
                                Assets.desktop.checkedin.image(),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                  "Your current location will be used to figure out whether you are near to the Monument or not",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
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
                                          isDesktop: true,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () {
                                        locator<MonumentCheckinBloc>().add(
                                          CheckinMonument(
                                            monument: widget.monument,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.appPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        "Check In",
                                        style: AppTextStyles.s14(
                                          color: AppColor.appSecondary,
                                          fontType: FontType.MEDIUM,
                                          isDesktop: true,
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
                      Assets.icons.icCheckin.svg(
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
                          isDesktop: true,
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
            if (widget.monument.images.isNotEmpty) // Add null check
              MediaQuery.of(context).size.width > 530
                  ? Container(
                      height: 380.w, // Match your previous container height
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                          aspectRatio: 2.0,
                          enlargeCenterPage: false,
                          viewportFraction: 1,
                          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                          enlargeFactor: 0.4,
                          height: 380.w, // Set explicit height
                        ),
                        itemCount: ((widget.monument.images.length + 1) ~/
                            2), // Better division handling
                        itemBuilder: (context, index, realIdx) {
                          final int first = index * 2;
                          final int second = first + 1;
                          return Row(
                            children: [first, second].map((idx) {
                              return Expanded(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: idx < widget.monument.images.length
                                      ? CachedNetworkImage(
                                          imageUrl: widget.monument.images[idx],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            width: double.infinity,
                                            height: 380.w,
                                            child: Center(
                                              child: SizedBox(
                                                width: 50,
                                                height: 50,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : Container(), // Handle odd number of images
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    )
                  : Container(
                      height: 380.w, // Match your previous container height
                      child: CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 2.0,
                          enlargeCenterPage: false,
                          viewportFraction: 1,
                          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                          enlargeFactor: 0.4,
                          height: 380.w, // Set explicit height
                        ),
                        items: widget.monument.images
                            .map((image) => CachedNetworkImage(
                                  imageUrl: image,
                                  placeholder: (context, url) =>
                                      new CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                ))
                            .toList(),
                      ),
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
                      style: AppTextStyles.responsive(
                        color: AppColor.appSecondary,
                        fontType: FontType.MEDIUM,
                        sizeDesktop: 26,
                        sizeTablet: 24,
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
                        isDesktop: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 36.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    BlocBuilder<MonumentDetailsBloc, MonumentDetailsState>(
                      bloc: locator<MonumentDetailsBloc>(),
                      builder: (context, state) {
                        if (state is LoadingMonumentWikiDetails) {
                          return SizedBox(
                            width: 1024.w,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColor.appPrimary,
                              ),
                            ),
                          );
                        } else if (state is MonumentWikiDetailsRetrieved) {
                          return Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width < 530
                                    ? 380.w
                                    : 1030.w,
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
                                width: MediaQuery.of(context).size.width < 530
                                    ? 380.w
                                    : 1030.w,
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
                    BlocConsumer<NearbyPlacesBloc, NearbyPlacesState>(
                      bloc: locator<NearbyPlacesBloc>(),
                      listener: (context, state) {
                        // TODO: implement listener
                      },
                      builder: (context, state) {
                        if (state is NearbyPlacesLoading) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width < 530
                                ? 380.w
                                : 1020.w,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColor.appPrimary,
                              ),
                            ),
                          );
                        }
                        if (state is NearbyPlacesLoaded) {
                          return NearbyPlacesCard(
                            nearbyPlaces: state.nearbyPlaces,
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
                widget.monument.localExperts.isEmpty ||
                        MediaQuery.sizeOf(context).width < 870
                    ? const SizedBox()
                    : LocalExpertsCard(
                        localExperts: widget.monument.localExperts,
                      ),
              ],
            ),
            widget.monument.localExperts.isEmpty ||
                    MediaQuery.sizeOf(context).width > 870
                ? const SizedBox()
                : LocalExpertsCard(
                    localExperts: widget.monument.localExperts,
                  ),
          ],
        ),
      ),
    );
  }
}

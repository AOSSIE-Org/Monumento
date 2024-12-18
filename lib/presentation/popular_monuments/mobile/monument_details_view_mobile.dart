import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/popular_monuments/bookmark_monuments/bookmark_monuments_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_checkin/monument_checkin_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/application/popular_monuments/nearby_places/nearby_places_bloc.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/popular_monuments/mobile/monument_model_view_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/image_tile_mobile.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/enums.dart';
import 'package:url_launcher/url_launcher.dart';

class MonumentDetailsViewMobile extends StatefulWidget {
  final MonumentEntity monument;
  final bool isBookmarked;
  const MonumentDetailsViewMobile(
      {super.key, required this.monument, this.isBookmarked = false});

  @override
  State<MonumentDetailsViewMobile> createState() =>
      _MonumentDetailsViewMobileState();
}

class _MonumentDetailsViewMobileState extends State<MonumentDetailsViewMobile> {
  int _selectedPlace = 0;

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
    List<String> images = widget.monument.images;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.appWhite,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColor.appBlack,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              ImageTile(index: 0, images: images, width: 367, height: 225),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  images.length,
                  (index) => ImageTile(index: index, images: images),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      backgroundColor: AppColor.appPrimary,
                    ),
                    onPressed: () async {
                      if (widget.monument.has3DModel) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MonumentModelViewMobile(
                              monument: widget.monument,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "3D Model not available for this monument"),
                          ),
                        );
                        return;
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 25,
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
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 27, vertical: 10),
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
                                  height: 350,
                                  width: 400,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 180,
                                        width: 200,
                                        child: Assets.desktop.checkedin.image(),
                                      ),
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
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () {
                                              locator<MonumentCheckinBloc>()
                                                  .add(
                                                CheckinMonument(
                                                  monument: widget.monument,
                                                ),
                                              );
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColor.appPrimary,
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                            Assets.icons.icCheckin.svg(
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            Text(
                              state is MonumentCheckedIn
                                  ? "Checked In"
                                  : "Check In",
                              style: AppTextStyles.s16(
                                color: AppColor.appSecondary,
                                fontType: FontType.MEDIUM,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Text(
                        overflow: TextOverflow.clip,
                        widget.monument.name,
                        style: AppTextStyles.s18(
                          color: AppColor.appSecondary,
                          fontType: FontType.MEDIUM,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_border,
                          color: AppColor.appPrimary,
                        ),
                        Text(
                          '${widget.monument.rating}',
                          style: AppTextStyles.s14(
                            color: AppColor.appSecondary,
                            fontType: FontType.MEDIUM,
                          ),
                        )
                      ],
                    )
                  ]),
              const SizedBox(
                height: 4,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "${widget.monument.city}, ${widget.monument.country}",
                      style: AppTextStyles.s12(
                        color: AppColor.appBlack,
                        fontType: FontType.REGULAR,
                      ),
                    ),
                  ],
                ),
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
                    return SizedBox(
                      width: 380,
                      child: Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                          const SizedBox(
                            height: 12,
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              const SizedBox(
                height: 12,
              ),
              widget.monument.localExperts.isEmpty
                  ? const SizedBox()
                  : Card(
                      child: SizedBox(
                        width: 350.w,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Local Guides and Experts",
                              style: AppTextStyles.s18(
                                  color: AppColor.appBlack,
                                  fontType: FontType.MEDIUM),
                            ),
                            const Divider(
                              thickness: BorderSide.strokeAlignCenter,
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (ctx, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      widget.monument.localExperts[index]
                                          .imageUrl,
                                    ),
                                  ),
                                  title: Text(
                                      widget.monument.localExperts[index].name),
                                  subtitle: Text(
                                    widget.monument.localExperts[index]
                                        .designation,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.phone),
                                    onPressed: () async {
                                      if (await canLaunchUrl(
                                        Uri.parse(
                                            'tel:${widget.monument.localExperts[index].phoneNumber}'),
                                      )) {
                                        launchUrl(
                                          Uri.parse(
                                              'tel:${widget.monument.localExperts[index].phoneNumber}'),
                                        );
                                      } else {
                                        if (mounted) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "Contact ${widget.monument.localExperts[index].name}"),
                                                content: Text(
                                                    "You can contact ${widget.monument.localExperts[index].name} at ${widget.monument.localExperts[index].phoneNumber}"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("Close"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      }
                                    },
                                  ),
                                );
                              },
                              separatorBuilder: (ctx, index) {
                                return const Divider();
                              },
                              itemCount: widget.monument.localExperts.length,
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(
                height: 12,
              ),
              BlocConsumer<NearbyPlacesBloc, NearbyPlacesState>(
                bloc: locator<NearbyPlacesBloc>(),
                listener: (context, state) {
                  // TODO: implement listener
                },
                builder: (context, state) {
                  if (state is NearbyPlacesLoading) {
                    return SizedBox(
                      width: 1024.w,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.appPrimary,
                        ),
                      ),
                    );
                  }
                  if (state is NearbyPlacesLoaded) {
                    return Card(
                      child: Container(
                        width: 350.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 12.h,
                            ),
                            Text(
                              "Places Nearby",
                              style: AppTextStyles.s18(
                                  color: AppColor.appSecondary,
                                  fontType: FontType.MEDIUM),
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
                            const Divider(),
                            ChipsChoice.single(
                              value: _selectedPlace,
                              onChanged: (v) {
                                setState(() {
                                  _selectedPlace = v;
                                });
                              },
                              choiceItems: const [
                                C2Choice(
                                  value: 0,
                                  label: 'Restaurants',
                                ),
                                C2Choice(
                                  value: 1,
                                  label: 'Toilets',
                                ),
                                C2Choice(
                                  value: 2,
                                  label: 'Hotels',
                                ),
                                C2Choice(
                                  value: 3,
                                  label: 'ATMs',
                                ),
                                C2Choice(
                                  value: 4,
                                  label: 'Supermarkets',
                                ),
                                C2Choice(
                                  value: 5,
                                  label: 'Pharmacies',
                                ),
                              ],
                            ),
                            state.nearbyPlaces
                                    .where((element) =>
                                        element.featureType ==
                                        FeatureType.values[_selectedPlace])
                                    .isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text("No nearby places found"),
                                    ),
                                  )
                                : Wrap(
                                    children: state.nearbyPlaces
                                        .where((element) =>
                                            element.featureType ==
                                            FeatureType.values[_selectedPlace])
                                        .map(
                                          (e) => Card(
                                            child: SizedBox(
                                              width: 450,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ListTile(
                                                  title: Text(e.name),
                                                  subtitle: Text(e.address),
                                                  trailing: IconButton(
                                                    icon: const Icon(
                                                        Icons.directions),
                                                    onPressed: () async {
                                                      if (await canLaunchUrl(
                                                        Uri.parse(
                                                            'https://www.google.com/maps/search/?api=1&query=${e.latitude},${e.longitude}'),
                                                      )) {
                                                        launchUrl(
                                                          Uri.parse(
                                                              'https://www.google.com/maps/search/?api=1&query=${e.latitude},${e.longitude}'),
                                                        );
                                                      } else {
                                                        if (mounted) {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Directions to ${e.name}"),
                                                                content: Text(
                                                                    "You can get directions to ${e.name} at ${e.address}"),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: const Text(
                                                                        "Close"),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  )
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ));
  }
}

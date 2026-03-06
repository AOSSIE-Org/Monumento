import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/popular_monuments/ai_chat_bot/ai_chat_bot_bloc.dart';
import 'package:monumento/application/popular_monuments/bookmark_monuments/bookmark_monuments_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_checkin/monument_checkin_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/application/popular_monuments/nearby_places/nearby_places_bloc.dart';
import 'package:monumento/data/models/monument_approval_status.dart';
import 'package:monumento/domain/entities/local_expert_entity.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/popular_monuments/mobile/ai_chat_view_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/monument_model_view_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/monument_more_details_view.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/image_tile_mobile.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/nearby_places_widget.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';
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

  String _getTruncatedText(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    // Try to cut at a sentence end
    final String truncated = text.substring(0, maxLength);
    final int lastPeriod = truncated.lastIndexOf('.');

    if (lastPeriod > maxLength / 2) {
      return truncated.substring(0, lastPeriod + 1);
    }

    // If no good sentence break, just cut and add ellipsis
    return "${truncated.substring(0, truncated.lastIndexOf(' '))}...";
  }
  // Add this widget inside _MonumentDetailsViewMobileState class

  Widget _buildApprovalStatusBanner(MonumentApprovalStatus status) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    IconData icon;
    String statusText;
    String description;

    switch (status) {
      case MonumentApprovalStatus.pending:
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[900]!;
        borderColor = Colors.orange[300]!;
        icon = Icons.pending_outlined;
        statusText = 'Pending Review';
        description = 'This monument is awaiting community approval';
        break;
      case MonumentApprovalStatus.approved:
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[900]!;
        borderColor = Colors.green[300]!;
        icon = Icons.verified_outlined;
        statusText = 'Community Verified';
        description = 'This monument has been approved by the community';
        break;
      case MonumentApprovalStatus.rejected:
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[900]!;
        borderColor = Colors.red[300]!;
        icon = Icons.cancel_outlined;
        statusText = 'Rejected';
        description = 'This submission was not approved';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppTextStyles.s16(
                    color: textColor,
                    fontType: FontType.BOLD,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.s12(
                    color: textColor,
                    fontType: FontType.REGULAR,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Add this widget for voting information (if pending)
  Widget _buildVotingInfo(MonumentEntity monument) {
    if (monument.approvalStatus != MonumentApprovalStatus.pending) {
      return const SizedBox.shrink();
    }

    final netVotes = monument.upVotingPoints - monument.downVotingPoints;
    final progress = monument.upVotingPoints / 10; // Assuming 10 votes needed
    final votesNeeded = 10 - monument.upVotingPoints;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community Votes',
                style: AppTextStyles.s14(
                  color: AppColor.appBlack,
                  fontType: FontType.BOLD,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: netVotes >= 0 ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      netVotes >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color:
                          netVotes >= 0 ? Colors.green[700] : Colors.red[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${netVotes >= 0 ? '+' : ''}$netVotes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            netVotes >= 0 ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.thumb_up_outlined,
                        size: 16, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${monument.upVotingPoints}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.thumb_down_outlined,
                        size: 16, color: Colors.red[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${monument.downVotingPoints}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            votesNeeded > 0
                ? '$votesNeeded more ${votesNeeded == 1 ? 'vote' : 'votes'} needed for approval'
                : 'Ready for approval!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
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
              const SizedBox(height: 10),

              // ADD APPROVAL STATUS BANNER HERE
              _buildApprovalStatusBanner(widget.monument.approvalStatus),

              // ADD VOTING INFO (only shows if pending)
              _buildVotingInfo(widget.monument),
              const SizedBox(height: 10),

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
                              state is MonumentCheckedIn ||
                                      state is MonumentCheckinSuccess
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
                          // ADD THIS AI CHAT BUTTON HERE - right after the monument info
                          _buildAiChatButton(state.wikiData.extract),
                          const SizedBox(height: 20),

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
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getTruncatedText(
                                            state.wikiData.extract, 200),
                                        style: AppTextStyles.s14(
                                          color: AppColor.appBlack,
                                          fontType: FontType.REGULAR,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MonumentDetailedPage(
                                                    wikiData: state.wikiData,
                                                    monumentName:
                                                        widget.monument.name,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Read More",
                                              style: AppTextStyles.s14(
                                                color: AppColor.appPrimary,
                                                fontType: FontType.MEDIUM,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final url =
                                                  'https://en.wikipedia.org/wiki?curid=${state.wikiData.pageId}';
                                              if (await canLaunchUrl(
                                                  Uri.parse(url))) {
                                                await launchUrl(Uri.parse(url));
                                              } else {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Could not open Wikipedia page"),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  "View on Wikipedia",
                                                  style: AppTextStyles.s14(
                                                    color: AppColor.appPrimary,
                                                    fontType: FontType.MEDIUM,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.open_in_new,
                                                  size: 16,
                                                  color: AppColor.appPrimary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                      final expertDetails =
                                          widget.monument.localExperts[index];
                                      await makeExpertCall(
                                        expertDetails,
                                        context,
                                      );
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
                  // Listener implementation if needed
                },
                builder: (context, state) {
                  if (state is NearbyPlacesLoading) {
                    return SizedBox(
                      width: 350.w,
                      child: const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColor.appPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (state is NearbyPlacesLoaded) {
                    return NearbyPlacesWidget(
                      nearbyPlaces: state.nearbyPlaces,
                      latitude: widget.monument.coordinates[0],
                      longitude: widget.monument.coordinates[1],
                    );
                  }
                  if (state is NearbyPlacesError) {
                    return SizedBox(
                      width: 350.w,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Places Nearby",
                                style: AppTextStyles.s18(
                                  color: AppColor.appSecondary,
                                  fontType: FontType.MEDIUM,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Unable to load nearby places",
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  locator<NearbyPlacesBloc>().add(
                                    GetNearbyPlaces(
                                      latitude: widget.monument.coordinates[0],
                                      longitude: widget.monument.coordinates[1],
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.appPrimary,
                                ),
                                child: Text(
                                  "Retry",
                                  style: AppTextStyles.s14(
                                    color: AppColor.appSecondary,
                                    fontType: FontType.MEDIUM,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildAiChatButton(String monumentDescription) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: AppColor.appSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlocProvider<AiChatBloc>(
                  create: (context) => locator<AiChatBloc>(),
                  child: AiChatViewMobile(
                    monument: widget.monument,
                    monumentDescription: monumentDescription,
                  ),
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.smart_toy,
            color: AppColor.appPrimary,
            size: 20,
          ),
          label: Text(
            "Ask AI Assistant",
            style: AppTextStyles.s16(
              color: AppColor.appPrimary,
              fontType: FontType.MEDIUM,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> makeExpertCall(
    LocalExpertEntity expertDetails, BuildContext context) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: expertDetails.phoneNumber);

  if (!await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
  } else {
    showAlertDialog(
      context,
      "Contact ${expertDetails.name}",
      "You can contact ${expertDetails.name} at ${expertDetails.phoneNumber}",
    );
  }
}

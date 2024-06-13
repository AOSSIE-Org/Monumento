import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class MonumentDetailedViewMobile extends StatefulWidget {
  final MonumentEntity monument;
  const MonumentDetailedViewMobile({super.key, required this.monument});

  @override
  State<MonumentDetailedViewMobile> createState() =>
      _MonumentDetailedViewMobileState();
}

class _MonumentDetailedViewMobileState
    extends State<MonumentDetailedViewMobile> {

  @override
  void initState() {
    locator<MonumentDetailsBloc>().add(
        GetMonumentWikiDetails(monumentWikiId: widget.monument.wikiPageId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_add_outlined,
                      color: AppColor.appBlack))
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
              Container(
                width: 367,
                height: 225,
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
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 64,
                    height: 64,
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
                  Container(
                    width: 64,
                    height: 64,
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
                  Container(
                    width: 64,
                    height: 64,
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
                  Container(
                    width: 64,
                    height: 64,
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
                  Container(
                    width: 64,
                    height: 64,
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
                  const SizedBox(
                    width: 25,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 27, vertical: 10),
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
                        IconButton(
                          //TODO:
                            onPressed: () {},
                            icon: const Icon(Icons.star_border)),
                        const Text("4.3")
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          const SizedBox(height: 12,),
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            ],
          ),
        ));
  }
}

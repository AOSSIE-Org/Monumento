import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/discover/mobile/widgets/discover_generic_grid_section.dart';
import 'package:monumento/presentation/discover/mobile/widgets/discover_section_header_widget.dart';
import 'package:monumento/presentation/discover/mobile/widgets/popular_monuments_section_bloc_builder.dart';
import 'package:monumento/presentation/notification/desktop/notification_view_desktop.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class DiscoverViewMobile extends StatefulWidget {
  const DiscoverViewMobile({Key? key}) : super(key: key);

  @override
  State<DiscoverViewMobile> createState() => _DiscoverViewMobileState();
}

class _DiscoverViewMobileState extends State<DiscoverViewMobile> {
  void initState() {
    locator<PopularMonumentsBloc>().add(GetPopularMonuments());
    super.initState();
  }

  // Dummy data methods for static sections
  List<ItineraryEntity> _getDummyItineraries() {
    return [
      ItineraryEntity(
        title: 'Indian Adventure',
        image:
            'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=400',
        id: '2',
        description: 'Discover incredible India',
      ),
      ItineraryEntity(
        title: 'European Journey',
        image:
            'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?w=400',
        id: '3',
        description: 'Historic European cities',
      ),
      ItineraryEntity(
        title: 'Australian Adventure',
        image:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        id: '4',
        description: 'Outback and cities',
      ),
    ];
  }

  List<CommunityEntity> _getDummyCommunities() {
    return [
      CommunityEntity(
        name: 'Traveling Friends',
        image:
            'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400',
        id: '2',
        memberCount: 890,
      ),
      CommunityEntity(
        name: 'WestMeath Community',
        image:
            'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
        id: '3',
        memberCount: 567,
      ),
      CommunityEntity(
        name: 'Global Explorers',
        image:
            'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=400',
        id: '4',
        memberCount: 2100,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMobileAppBar(
        logoPath: Assets.mobile.logoDiscover.path,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) {
                    return const NotificationViewDesktop();
                  },
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          SizedBox(height: 24.h),
          // Search Bar
          const SearchBarWidget(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Popular Monuments Section (Dynamic with Bloc)
                  DiscoverSectionHeaderWidget(
                    title: 'Popular Monuments',
                    onSeeAllTap: () {
                      print('See all monuments tapped');
                    },
                  ),
                  const SizedBox(height: 12),
                  PopularMonumentsSectionBodyBlocBuilder(),

                  const SizedBox(height: 24),

                  // Public Itineraries Section (Static for now)
                  DiscoverSectionHeaderWidget(
                    title: 'Public Itineraries',
                    onSeeAllTap: () {
                      print('See all itineraries tapped');
                    },
                  ),
                  const SizedBox(height: 12),
                  GenericGridSection<ItineraryEntity>(
                    items: _getDummyItineraries(),
                    itemWidth: 60.w,
                    itemHeight: 100.h,
                    itemBuilder: (item) =>
                        GenericGridItemWidget<ItineraryEntity>(
                      item: item,
                      getTitle: (itinerary) => itinerary.title,
                      getImage: (itinerary) => itinerary.image,
                      onTapBuilder: (itinerary) => () {
                        print('${itinerary.title} tapped');
                        // TODO: Navigate to itinerary details
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Popular Communities Section (Static for now)
                  DiscoverSectionHeaderWidget(
                    title: 'Popular Communities',
                    onSeeAllTap: () {
                      print('See all communities tapped');
                    },
                  ),
                  const SizedBox(height: 12),
                  GenericGridSection<CommunityEntity>(
                    items: _getDummyCommunities(),
                    itemWidth: 60.w,
                    itemHeight: 100.h,
                    itemBuilder: (item) =>
                        GenericGridItemWidget<CommunityEntity>(
                      item: item,
                      getTitle: (community) => community.name,
                      getImage: (community) => community.image,
                      onTapBuilder: (community) => () {
                        print('${community.name} tapped');
                        // TODO: Navigate to community details
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Search Bar Widget
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search events, monuments, itineraries',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 24,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange[300]!),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// Entity Classes (Add these to your entities file)
class ItineraryEntity {
  final String id;
  final String title;
  final String image;
  final String description;

  ItineraryEntity({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
  });
}

class CommunityEntity {
  final String id;
  final String name;
  final String image;
  final int memberCount;

  CommunityEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.memberCount,
  });
}

class MonumentEntity {
  final String id;
  final String name;
  final String image;
  final String location;
  final double rating;

  MonumentEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.location,
    required this.rating,
  });
}

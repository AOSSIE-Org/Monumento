import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/notification/desktop/notification_view_desktop.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class DiscoverViewMobile extends StatelessWidget {
  const DiscoverViewMobile({Key? key}) : super(key: key);

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
                  // Popular Monuments Section
                  SectionHeader(
                    title: 'Popular Monuments',
                    onSeeAllTap: () {
                      print('See all monuments tapped');
                    },
                  ),
                  const SizedBox(height: 12),
                  GridSection(
                    items: [
                      DiscoverGridItemTile(
                        image: 'assets/monument_nicholas.jpg',
                        title: 'Monument to Nicholas I',
                        onTap: () => print('Monument to Nicholas I tapped'),
                      ),
                      DiscoverGridItemTile(
                        image: 'assets/stonehenge.jpg',
                        title: 'Stonehenge',
                        onTap: () => print('Stonehenge tapped'),
                      ),
                      DiscoverGridItemTile(
                        image: 'assets/colosseum.jpg',
                        title: 'Colosseum',
                        onTap: () => print('Colosseum tapped'),
                      ),
                      DiscoverGridItemTile(
                        image: 'assets/colosseum.jpg',
                        title: 'Colosseum',
                        onTap: () => print('Colosseum tapped'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Public Itineraries Section
                  SectionHeader(
                    title: 'Public Itineraries',
                    onSeeAllTap: () {
                      print('See all itineraries tapped');
                    },
                  ),
                  const SizedBox(height: 12),
                  GridSection(
                    items: [
                      DiscoverGridItemTile(
                        image: 'assets/egyptian_flag.jpg',
                        title: 'Egyptian Adventure',
                        onTap: () => print('Egyptian Adventure tapped'),
                      ),
                      DiscoverGridItemTile(
                        image: 'assets/indian_flag.jpg',
                        title: 'Indian Adventure',
                        onTap: () => print('Indian Adventure tapped'),
                      ),
                      DiscoverGridItemTile(
                        image: 'assets/india_gate.jpg',
                        title: 'Indian Adventure',
                        onTap: () => print('Indian Adventure 2 tapped'),
                      ),
                      DiscoverGridItemTile(
                        image: 'assets/australian_flag.jpg',
                        title: 'Australian Adventure',
                        onTap: () => print('Australian Adventure tapped'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Popular Communities Section
                  SectionHeader(
                    title: 'Popular Communities',
                    onSeeAllTap: () {
                      print('See all communities tapped');
                    },
                  ),
                  const SizedBox(height: 12),
                  GridSection(
                    items: [
                      DiscoverGridItemTile(
                        image: 'assets/adventure_canada.jpg',
                        title: 'Adventure Canada',
                        onTap: () => print('Adventure Canada tapped'),
                      ),
                      DiscoverGridItemTile(
                        image: 'assets/traveling_friends.jpg',
                        title: 'Traveling Friends',
                        onTap: () => print('Traveling Friends tapped'),
                      ),
                      DiscoverGridItemTile(
                        image: 'assets/westmeath.jpg',
                        title: 'WestMeath Community',
                        onTap: () => print('WestMeath Community tapped'),
                      ),
                      DiscoverGridItemTile(
                        image: 'assets/adventure_canada2.jpg',
                        title: 'Adventure Canada',
                        onTap: () => print('Adventure Canada 2 tapped'),
                      ),
                    ],
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

// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAllTap;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.onSeeAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: Text(
            'See all',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Grid Section Widget
class GridSection extends StatelessWidget {
  final List<DiscoverGridItemTile> items;

  const GridSection({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h, // Fixed height for the scrollable section
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: 60.w,
            margin: EdgeInsets.only(
              right: index == items.length - 1 ? 0 : 12,
            ),
            child: GridItemWidget(
              item: items[index],
            ),
          );
        },
      ),
    );
  }
}

// Grid Item Model
class DiscoverGridItemTile {
  final String image;
  final String title;
  final VoidCallback onTap;

  DiscoverGridItemTile({
    required this.image,
    required this.title,
    required this.onTap,
  });
}

// Grid Item Widget
class GridItemWidget extends StatelessWidget {
  final DiscoverGridItemTile item;

  const GridItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        children: [
          // Image Container
          Container(
            height: 60.h,
            width: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.orange[200]!, Colors.orange[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

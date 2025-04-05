import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/domain/entities/nearby_place_entity.dart';
import 'package:monumento/presentation/popular_monuments/mobile/nearby_places_page.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/enums.dart';

class NearbyPlacesWidget extends StatelessWidget {
  final List<NearbyPlaceEntity> nearbyPlaces;
  final double latitude;
  final double longitude;

  const NearbyPlacesWidget({
    Key? key,
    required this.nearbyPlaces,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<FeatureType, int> categoryCount = {};
    for (final place in nearbyPlaces) {
      categoryCount[place.featureType] =
          (categoryCount[place.featureType] ?? 0) + 1;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 350.w,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Places Nearby",
                  style: AppTextStyles.s18(
                    color: AppColor.appSecondary,
                    fontType: FontType.MEDIUM,
                  ),
                ),
                Text(
                  "${nearbyPlaces.length} places",
                  style: AppTextStyles.s14(
                    color: AppColor.appBlack,
                    fontType: FontType.REGULAR,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (categoryCount.isNotEmpty)
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: categoryCount.entries.map((entry) {
                  return Chip(
                    label: Text(
                      "${_getCategoryName(entry.key)}: ${entry.value}",
                      style: AppTextStyles.s12(
                        color: AppColor.appSecondary,
                        fontType: FontType.MEDIUM,
                      ),
                    ),
                    backgroundColor: AppColor.unselectedChip,
                  );
                }).toList(),
              ),
            if (categoryCount.isNotEmpty) SizedBox(height: 16.h),
            if (nearbyPlaces.isNotEmpty)
              ...nearbyPlaces.take(3).map((place) => _buildPlacePreview(place)),
            if (nearbyPlaces.isEmpty) _buildEmptyState(),
            if (nearbyPlaces.isNotEmpty) SizedBox(height: 16.h),
            if (nearbyPlaces.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NearbyPlacesPage(
                          nearbyPlaces: nearbyPlaces,
                          latitude: latitude,
                          longitude: longitude,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.appPrimary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "View All Nearby Places",
                    style: AppTextStyles.s14(
                      color: AppColor.appSecondary,
                      fontType: FontType.MEDIUM,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: AppColor.appLightGrey,
          ),
          SizedBox(height: 12.h),
          Text(
            "No nearby places found",
            style: AppTextStyles.s16(
              color: AppColor.appSecondary,
              fontType: FontType.MEDIUM,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            "There are no places of interest registered in this area",
            style: AppTextStyles.s14(
              color: AppColor.appBlack.withOpacity(0.6),
              fontType: FontType.REGULAR,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlacePreview(NearbyPlaceEntity place) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.appLightGrey,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(place.featureType),
            color: AppColor.appPrimary,
            size: 20,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: AppTextStyles.s14(
                    color: AppColor.appSecondary,
                    fontType: FontType.MEDIUM,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  place.address,
                  style: AppTextStyles.s12(
                    color: AppColor.appBlack,
                    fontType: FontType.REGULAR,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(FeatureType type) {
    switch (type) {
      case FeatureType.restaurant:
        return 'Restaurants';
      case FeatureType.toilet:
        return 'Toilets';
      case FeatureType.hotel:
        return 'Hotels';
      case FeatureType.atm:
        return 'ATMs';
      case FeatureType.supermarket:
        return 'Supermarkets';
      case FeatureType.pharmacy:
        return 'Pharmacies';
    }
  }

  IconData _getCategoryIcon(FeatureType type) {
    switch (type) {
      case FeatureType.restaurant:
        return Icons.restaurant;
      case FeatureType.toilet:
        return Icons.wc;
      case FeatureType.hotel:
        return Icons.hotel;
      case FeatureType.atm:
        return Icons.atm;
      case FeatureType.supermarket:
        return Icons.shopping_cart;
      case FeatureType.pharmacy:
        return Icons.local_pharmacy;
    }
  }
}

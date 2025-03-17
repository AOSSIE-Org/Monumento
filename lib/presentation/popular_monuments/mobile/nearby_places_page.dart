import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/domain/entities/nearby_place_entity.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/nearby_places_distance_calculator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/enums.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyPlacesPage extends StatefulWidget {
  final List<NearbyPlaceEntity> nearbyPlaces;
  final double latitude;
  final double longitude;

  const NearbyPlacesPage({
    Key? key,
    required this.nearbyPlaces,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<NearbyPlacesPage> createState() => _NearbyPlacesPageState();
}

class _NearbyPlacesPageState extends State<NearbyPlacesPage> {
  FeatureType _selectedCategory = FeatureType.restaurant;
  String _sortOption = 'Name (A-Z)';
  final List<String> _sortOptions = ['Name (A-Z)', 'Name (Z-A)', 'Distance'];
  final TextEditingController _searchController = TextEditingController();
  List<NearbyPlaceEntity> _filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredPlaces();
  }

  void _updateFilteredPlaces() {
    _filteredPlaces = widget.nearbyPlaces
        .where((place) =>
            place.featureType == _selectedCategory &&
            (place.name
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ||
                place.address
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase())))
        .toList();

    switch (_sortOption) {
      case 'Name (A-Z)':
        _filteredPlaces.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name (Z-A)':
        _filteredPlaces.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Distance':
        _filteredPlaces = NearbyPlacesDistanceCalculator.sortPlacesByDistance(
            _filteredPlaces, widget.latitude, widget.longitude);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Places Nearby",
          style: AppTextStyles.s18(
            color: AppColor.appSecondary,
            fontType: FontType.MEDIUM,
          ),
        ),
        backgroundColor: AppColor.appWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.appBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColor.appLightGrey),
                ),
                filled: true,
                fillColor: AppColor.appLightGrey.withOpacity(0.2),
              ),
              onChanged: (value) {
                setState(() {
                  _updateFilteredPlaces();
                });
              },
            ),
          ),
          Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: FeatureType.values.map((type) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(
                      _getCategoryName(type),
                      style: AppTextStyles.s14(
                        color: _selectedCategory == type
                            ? AppColor.appWhite
                            : AppColor.appSecondary,
                        fontType: FontType.MEDIUM,
                      ),
                    ),
                    selected: _selectedCategory == type,
                    selectedColor: AppColor.appPrimary,
                    backgroundColor: AppColor.appLightGrey,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = type;
                          _updateFilteredPlaces();
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Sort by:",
                  style: AppTextStyles.s14(
                    color: AppColor.appSecondary,
                    fontType: FontType.REGULAR,
                  ),
                ),
                SizedBox(width: 8.w), 
                DropdownButton<String>(
                  value: _sortOption,
                  icon:
                      Icon(Icons.arrow_drop_down, color: AppColor.appSecondary),
                  elevation: 16,
                  style: AppTextStyles.s14(
                    color: AppColor.appSecondary,
                    fontType: FontType.MEDIUM,
                  ),
                  underline: SizedBox(), 
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _sortOption = newValue;
                        _updateFilteredPlaces();
                      });
                    }
                  },
                  items: _sortOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredPlaces.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 64,
                          color: AppColor.appLightGrey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "No ${_getCategoryName(_selectedCategory).toLowerCase()} found nearby",
                          style: AppTextStyles.s16(
                            color: AppColor.appSecondary,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _filteredPlaces[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.w),
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColor.appPrimary.withOpacity(0.2),
                            child: Icon(
                              _getCategoryIcon(place.featureType),
                              color: AppColor.appPrimary,
                            ),
                          ),
                          title: Text(
                            place.name,
                            style: AppTextStyles.s16(
                              color: AppColor.appSecondary,
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.h),
                              Text(
                                place.address,
                                style: AppTextStyles.s14(
                                  color: AppColor.appBlack,
                                  fontType: FontType.REGULAR,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                NearbyPlacesDistanceCalculator
                                    .getFormattedDistance(
                                        place.latitude,
                                        place.longitude,
                                        widget.latitude,
                                        widget.longitude),
                                style: AppTextStyles.s12(
                                  color: AppColor.appPrimary,
                                  fontType: FontType.MEDIUM,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.directions,
                              color: AppColor.appPrimary,
                            ),
                            onPressed: () => _openDirections(place),
                          ),
                          onTap: () => _showDetailsDialog(place),
                        ),
                      );
                    },
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

  void _openDirections(NearbyPlaceEntity place) async {
    final Uri uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Directions to ${place.name}"),
            content: Text(
                "Unable to open map directions. The location is at ${place.address}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showDetailsDialog(NearbyPlaceEntity place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(place.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(_getCategoryIcon(place.featureType)),
              title: Text(_getCategoryName(place.featureType)),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(place.address),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.straight),
              title: Text(NearbyPlacesDistanceCalculator.getFormattedDistance(
                  place.latitude,
                  place.longitude,
                  widget.latitude,
                  widget.longitude)),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.location_searching),
              title: const Text("Tap for directions"),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                _openDirections(place);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

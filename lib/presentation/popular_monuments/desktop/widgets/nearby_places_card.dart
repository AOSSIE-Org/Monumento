import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/domain/entities/nearby_place_entity.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/enums.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyPlacesCard extends StatefulWidget {
  final List<NearbyPlaceEntity> nearbyPlaces;
  const NearbyPlacesCard({super.key, required this.nearbyPlaces});

  @override
  State<NearbyPlacesCard> createState() => _NearbyPlacesCardState();
}

class _NearbyPlacesCardState extends State<NearbyPlacesCard> {
  int _selectedPlace = 0;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width < 530 ? 380.w :1024.w,
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
                fontType: FontType.MEDIUM,
                isDesktop: true,
              ),
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
              choiceItems: [
                C2Choice(
                  value: 0,
                  label: 'Restaurants',
                  style: C2ChipStyle(
                    backgroundColor:
                        AppColor.appLightGrey, // Set color for Restaurants
                  ),
                ),
                C2Choice(
                  value: 1,
                  label: 'Toilets',
                  style: C2ChipStyle(
                    backgroundColor: AppColor
                        .appLightGrey, // Set background color for Toilets
                  ),
                ),
                C2Choice(
                  value: 2,
                  label: 'Hotels',
                  style: C2ChipStyle(
                    backgroundColor:
                        AppColor.appLightGrey, // Set color for Hotels
                  ),
                ),
                C2Choice(
                  value: 3,
                  label: 'ATMs',
                  style: C2ChipStyle(
                    backgroundColor:
                        AppColor.appLightGrey, // Set color for ATMs
                  ),
                ),
                C2Choice(
                  value: 4,
                  label: 'Supermarkets',
                  style: C2ChipStyle(
                    backgroundColor:
                        AppColor.appLightGrey, // Set color for Supermarkets
                  ),
                ),
                C2Choice(
                  value: 5,
                  label: 'Pharmacies',
                  style: C2ChipStyle(
                    backgroundColor:
                        AppColor.appLightGrey, // Set color for Pharmacies
                  ),
                ),
              ],
            ),
            widget.nearbyPlaces
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
                    children: widget.nearbyPlaces
                        .where((element) =>
                            element.featureType ==
                            FeatureType.values[_selectedPlace])
                        .map(
                          (e) => Card(
                            child: SizedBox(
                              width: 450,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(e.name),
                                  subtitle: Text(e.address),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.directions),
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
}

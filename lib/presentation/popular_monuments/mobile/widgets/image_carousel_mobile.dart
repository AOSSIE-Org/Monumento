import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';

class ImageCarousel extends StatefulWidget {
  final int index;
  final List<String> images;
  const ImageCarousel({super.key, required this.images, required this.index});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMobileAppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.appWhite,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: AppColor.appBlack,
      body: Center(
        child: CarouselSlider(
          items: widget.images.map((imageUrl) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.sp),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    imageUrl,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
              viewportFraction: 0.8,
              aspectRatio: 2,
              autoPlay: true,
              initialPage: widget.index,
              enableInfiniteScroll: false,
              enlargeCenterPage: true),
        ),
      ),
    );
  }
}

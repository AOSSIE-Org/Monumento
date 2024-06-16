import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/utils/app_colors.dart';

class ImageCarouselDesktop extends StatefulWidget {
  final int index;
  final List<String> images;
  const ImageCarouselDesktop(
      {super.key, required this.index, required this.images});

  @override
  State<ImageCarouselDesktop> createState() => _ImageCarouselDesktopState();
}

class _ImageCarouselDesktopState extends State<ImageCarouselDesktop> {
  final controller = CarouselController();
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
      ),
      backgroundColor: AppColor.appBlack,
      body: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: AppColor.appBlack,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                controller.previousPage();
              },
              child: const Icon(Icons.arrow_back_ios_rounded)),
          CarouselSlider(
            carouselController: controller,
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
              viewportFraction: 1,
              aspectRatio: 1.5,
              autoPlay: false,
              initialPage: widget.index,
              enableInfiniteScroll: false,
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: AppColor.appBlack,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                controller.nextPage();
              },
              child: const Icon(Icons.arrow_forward_ios_rounded)),
        ],
      )),
    );
  }
}

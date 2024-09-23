import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/presentation/popular_monuments/mobile/widgets/image_carousel_mobile.dart';

class ImageTile extends StatelessWidget {
  final int index;
  final List<String> images;
  final double? width;
  final double? height;
  const ImageTile(
      {super.key,
      required this.index,
      required this.images,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageCarousel(
              images: images,
              index: index,
            ),
          ),
        );
      },
      child: Container(
        width: width ?? 64.0,
        height: height ?? 64.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.sp),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              images[index],
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

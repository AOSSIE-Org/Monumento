import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/presentation/popular_monuments/desktop/widgets/image_carousel_desktop.dart';

class ImageTileDesktop extends StatelessWidget {
  final int index;
  final List<String> images;
  final Color? color;
  final double? width;
  final double? height;
  const ImageTileDesktop(
      {super.key,
      required this.index,
      required this.images,
      this.width,
      this.height,
      this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageCarouselDesktop(
              images: images,
              index: index,
            ),
          ),
        );
      },
      child: Container(
        width: width ?? 185.w,
        height: height ?? 185.w,
        decoration: BoxDecoration(
          color: color,
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

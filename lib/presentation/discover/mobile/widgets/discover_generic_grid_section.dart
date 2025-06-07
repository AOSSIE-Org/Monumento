// Generic Grid Item Widget
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Generic Grid Section Widget (for non-monument sections)
class GenericGridSection<T> extends StatelessWidget {
  final List<T> items;
  final double itemWidth;
  final double itemHeight;
  final Widget Function(T) itemBuilder;

  const GenericGridSection({
    Key? key,
    required this.items,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          return Container(
            width: itemWidth,
            margin: const EdgeInsets.only(right: 12),
            child: itemBuilder(items[index]),
          );
        },
      ),
    );
  }
}

class GenericGridItemWidget<T> extends StatelessWidget {
  final T item;
  final String Function(T) getTitle;
  final String Function(T) getImage;
  final VoidCallback Function(T) onTapBuilder;

  const GenericGridItemWidget({
    Key? key,
    required this.item,
    required this.getTitle,
    required this.getImage,
    required this.onTapBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapBuilder(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image Container
          Container(
            height: 60.h,
            width: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                getImage(item),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            getTitle(item),
            style: TextStyle(
              fontSize: 12.sp,
              fontStyle: FontStyle.normal,
              color: Color(0xff4B5669),
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

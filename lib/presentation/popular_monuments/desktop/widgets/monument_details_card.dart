import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class MonumentDetailsCard extends StatelessWidget {
  final MonumentEntity monument;
  final VoidCallback onTap;
  const MonumentDetailsCard(
      {super.key, required this.monument, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: CachedNetworkImage(
          imageUrl: monument.imageUrl,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.sp),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.srcOver,
                ),
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 14.w,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320.w,
                          child: Text(
                            monument.name,
                            style: AppTextStyles.responsive(
                              sizeDesktop: 18,
                              sizeTablet: 22,
                              color: AppColor.appWhite,
                              fontType: FontType.MEDIUM,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          "${monument.city}, ${monument.country}",
                          style: AppTextStyles.responsive(
                            sizeDesktop: 14,
                            sizeTablet: 16,
                            color: AppColor.appWhite,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                      ],
                    ),
                    // TODO: Uncomment while working on the check-in feature
                    // const Spacer(),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     Text(
                    //       "Visited on",
                    //       style: AppTextStyles.responsive(
                    //         sizeDesktop: 14,
                    //         sizeTablet: 16,
                    //         color: AppColor.appWhite,
                    //         fontType: FontType.MEDIUM,
                    //       ),
                    //     ),
                    //     SizedBox(
                    //       height: 4.h,
                    //     ),
                    //     Text(
                    //       "30 March, 2024",
                    //       style: AppTextStyles.responsive(
                    //         sizeDesktop: 14,
                    //         sizeTablet: 16,
                    //         color: AppColor.appWhite,
                    //         fontType: FontType.MEDIUM,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   width: 14.w,
                    // ),
                  ],
                ),
                SizedBox(
                  height: 14.h,
                ),
              ],
            ),
          ),
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              color: AppColor.appPrimary,
            ),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}

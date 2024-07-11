import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class CustomButtomBar extends StatelessWidget {
  final String image;
  final String text;
  final Function() onTap;
  const CustomButtomBar(
      {super.key, required this.image, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ButtonBar(
        alignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(image),
          const SizedBox(width: 10),
          Text(text,
              style: AppTextStyles.s16(
                  color: AppColor.appGrey, fontType: FontType.REGULAR))
        ],
      ),
    );
  }
}

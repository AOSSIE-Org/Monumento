import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/custom_mobile_appBar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMobileAppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.appBlack,
          ),
        ),
        actions: [
          Text(
            "About",
            style: AppTextStyles.s16(
              color: AppColor.appSecondary,
              fontType: FontType.MEDIUM,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 180,
                  width: 130,
                  decoration: const BoxDecoration(
                      color: AppColor.appPrimary,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: const BoxDecoration(
                            color: AppColor.appBlack,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: SvgPicture.asset(
                          Assets.monumentoLogo.path,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "MONUMENTO",
                        style: AppTextStyles.s16(
                          color: AppColor.appBlack,
                          fontType: FontType.MEDIUM,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 180,
                  width: 120,
                  decoration: const BoxDecoration(
                      color: AppColor.appPrimary,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                            color: AppColor.appBlack,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Assets.aossie.image(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "AOSSIE",
                        style: AppTextStyles.s16(
                          color: AppColor.appBlack,
                          fontType: FontType.MEDIUM,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Description:",
              style: AppTextStyles.s16(
                color: AppColor.appBlack,
                fontType: FontType.BOLD,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "An AR integrated social app for sharing landmarks, visited places and visualizing their 3D models right from a mobile device",
              textAlign: TextAlign.center,
              style: AppTextStyles.s14(
                color: AppColor.appSecondaryBlack,
                fontType: FontType.MEDIUM,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      launchUrl(
                          Uri.parse("https://github.com/AOSSIE-Org/Monumento"));
                    },
                    style: const ButtonStyle(
                        maximumSize: WidgetStatePropertyAll(Size(120, 110)),
                        backgroundColor:
                            WidgetStatePropertyAll(AppColor.appPrimary)),
                    child: Row(
                      children: [
                        Assets.icons.icGithubPng.image(
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "GitHub",
                          style: AppTextStyles.s14(
                            color: AppColor.appSecondaryBlack,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                      ],
                    )),
                ElevatedButton(
                    onPressed: () {
                      launchUrl(Uri.parse("https://aossie.org/"));
                    },
                    style: const ButtonStyle(
                        maximumSize: WidgetStatePropertyAll(Size(120, 110)),
                        backgroundColor:
                            WidgetStatePropertyAll(AppColor.appPrimary)),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link_rounded,
                          color: AppColor.appBlack,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "AOSSIE",
                          style: AppTextStyles.s14(
                            color: AppColor.appSecondaryBlack,
                            fontType: FontType.MEDIUM,
                          ),
                        ),
                      ],
                    ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Eager to enhance this project? Visit our GitHub repository",
              textAlign: TextAlign.center,
              style: AppTextStyles.s14(
                color: AppColor.appSecondaryBlack,
                fontType: FontType.MEDIUM,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

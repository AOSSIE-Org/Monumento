import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/presentation/settings/mobile/about_screen.dart';
import 'package:monumento/presentation/settings/mobile/widgets/button_bar.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsViewMobile extends StatefulWidget {
  const SettingsViewMobile({super.key});

  @override
  State<SettingsViewMobile> createState() => _SettingsViewMobileState();
}

class _SettingsViewMobileState extends State<SettingsViewMobile> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginRegisterBloc, LoginRegisterState>(
        bloc: locator<LoginRegisterBloc>(),
        listener: (context, state) {
          if (state is LogOutSuccess) {
            context.push('/login');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 260,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Settings",
                style: AppTextStyles.s18(
                  color: AppColor.appSecondary,
                  fontType: FontType.MEDIUM,
                ),
              ),
              const Divider(
                thickness: BorderSide.strokeAlignOutside,
                endIndent: 0,
              ),
              CustomButtonBar(
                image: Assets.icons.icUpdateProfile.path,
                text: "Update Profile Details",
                onTap: () {
                  context.push('/update_profile');
                },
              ),
              CustomButtonBar(
                image: Assets.icons.icPrivacyPolicy.path,
                text: "Privacy Policy",
                onTap: () {
                  launchUrl(Uri.parse(
                      "https://www.termsfeed.com/live/a33e0b4f-b0de-4174-bbf7-33d48dbf540d"));
                },
              ),
              CustomButtonBar(
                image: Assets.icons.icGithubSvg.path,
                text: "GitHub",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()),
                  );
                },
              ),
              CustomButtonBar(
                image: Assets.icons.icLogout.path,
                text: "Log Out",
                onTap: () {
                  locator<LoginRegisterBloc>().add(LogOutEvent());
                },
              ),
            ],
          ),
        ));
  }
}

class SettingsBottomSheet {
  settingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.sp),
                topLeft: Radius.circular(20.sp))),
        context: context,
        builder: (_) {
          return const SettingsViewMobile();
        });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/presentation/profile_screen/mobile/widgets/buttom_bar.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class SettingsBottomSheet {
  settingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.sp),
                topLeft: Radius.circular(20.sp))),
        context: context,
        builder: (_) {
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
                    CustomButtomBar(
                      image: "assets/icons/ic_update_profile.svg",
                      text: "Update Profile Details",
                      onTap: () {},
                    ),
                    CustomButtomBar(
                      image: "assets/icons/ic_privacy_policy.svg",
                      text: "Privacy Policy",
                      onTap: () {},
                    ),
                    CustomButtomBar(
                      image: "assets/icons/ic_github.svg",
                      text: "GitHub",
                      onTap: () {},
                    ),
                    CustomButtomBar(
                      image: "assets/icons/ic_logout.svg",
                      text: "Log Out",
                      onTap: () {
                        locator<LoginRegisterBloc>().add(LogOutEvent());
                      },
                    ),
                  ],
                ),
              ));
        });
  }
}

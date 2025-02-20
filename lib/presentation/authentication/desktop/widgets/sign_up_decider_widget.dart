import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';
import 'package:monumento/utils/constants.dart';

class SignUpDeciderWidget extends StatefulWidget {
  final VoidCallback onSignUpWithEmailPressed;
  final VoidCallback onSignUpWithGooglePressed;
  const SignUpDeciderWidget({
    super.key,
    required this.onSignUpWithEmailPressed,
    required this.onSignUpWithGooglePressed,
  });

  @override
  State<SignUpDeciderWidget> createState() => _SignUpDeciderWidgetState();
}

class _SignUpDeciderWidgetState extends State<SignUpDeciderWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              isDesktop: true,
              onPressed: widget.onSignUpWithGooglePressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColor.appBlack,
                backgroundColor: AppColor.appWhite, // Text and icon color
                elevation: 2, // Shadow
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12), // Padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Border radius
                ),
              ),
              leading: SizedBox(height: 28.h, child: Assets.googleLogo.image()),
              text: 'Sign up with Google',
            ),
          ),
        ),
        const SizedBox(
          height: 22,
        ),
        const Text(
          'Or',
          style: TextStyle(
            color: AppColor.appSecondaryBlack,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 22,
        ),
        SizedBox(
          width: double.infinity,
          child: CustomElevatedButton(
            isDesktop: true,
            onPressed: widget.onSignUpWithEmailPressed,
            text: 'Sign up with Email',
          ),
        ),
        const SizedBox(
          height: 22,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Have an account?',
              style: AppTextStyles.s14(
                color: AppColor.appSecondaryBlack,
                fontType: FontType.REGULAR,
                isDesktop: true,
              ),
            ),
            TextButton(
              onPressed: () {
                context.pop();
              },
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Colors.transparent,
                ),
              ),
              child: Text(
                'Login',
                style: AppTextStyles.s14(
                  color: AppColor.appPrimary,
                  fontType: FontType.MEDIUM,
                  isDesktop: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

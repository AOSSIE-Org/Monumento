import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

const defaultProfilePicture =
    "https://firebasestorage.googleapis.com/v0/b/monumento-277103.appspot.com/o/profilePictures%2Faccount_avatar_profile_user_icon%20.png?alt=media&token=672ef7b9-7f53-415f-8040-0c93c61e01b8";

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final bool? isSeen;
  final Widget? suffixIcon;
  final String? Function(String?)? validateFunction;
  final AutovalidateMode? autoValid;
  final bool isDesktop;
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.text,
      this.suffixIcon,
      this.validateFunction,
      this.autoValid,
      this.isSeen,
      this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isSeen ?? false,
      validator: validateFunction,
      autovalidateMode: autoValid,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        labelText: text,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColor.appSecondary,
          ),
        ),
        floatingLabelStyle: AppTextStyles.s14(
          color: AppColor.appSecondary,
          fontType: FontType.MEDIUM,
          isDesktop: isDesktop,
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColor.appSecondaryBlack,
          ),
        ),
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final ButtonStyle? style;
  final bool isDesktop;
  final Widget? leading;
  const CustomElevatedButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.style,
      this.isDesktop = false,
      this.leading});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style ??
          ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            backgroundColor: AppColor.appPrimary,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
      onPressed: onPressed,
      child: leading == null
          ? Text(
              text,
              style: AppTextStyles.s14(
                color: AppColor.appSecondary,
                fontType: FontType.MEDIUM,
                isDesktop: isDesktop,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading!,
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  text,
                  style: AppTextStyles.s14(
                    color: AppColor.appSecondary,
                    fontType: FontType.MEDIUM,
                    isDesktop: isDesktop,
                  ),
                ),
              ],
            ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final VoidCallback onClick;
  final Widget leadingIcon;
  final String title;
  final String? subtitle;
  const CustomListTile(
      {super.key,
      required this.onClick,
      required this.leadingIcon,
      required this.title,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onClick,
      dense: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      tileColor: AppColor.appPrimary,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      leading: leadingIcon,
      title: Text(
        title,
        style: AppTextStyles.s16(
            color: AppColor.appBlack, fontType: FontType.MEDIUM),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.s14(
                  color: AppColor.appGrey, fontType: FontType.REGULAR),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColor.appSecondaryBlack,
      ),
    );
  }
}

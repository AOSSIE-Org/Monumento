import 'package:flutter/material.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

const defaultProfilePicture =
    "https://firebasestorage.googleapis.com/v0/b/monumento-fd184.appspot.com/o/profilePictures%2F6415362_account_avatar_profile_user_icon%20(1).png?alt=media&token=3d1a3d55-b631-466a-b12b-f0cc3f3b376d";

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final bool? isSeen;
  final Widget? suffixIcon;
  final String? Function(String?)? validateFunction;
  final AutovalidateMode? autoValid;
  const CustomTextField({super.key, required this.controller, required this.text, this.suffixIcon, this.validateFunction, this.autoValid, this.isSeen});

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      controller: controller,
      obscureText: isSeen??false,
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
  const CustomElevatedButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        backgroundColor: AppColor.appPrimary,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.s14(
          color: AppColor.appSecondary,
          fontType: FontType.MEDIUM,
        ),
      ),
    );
  }
}
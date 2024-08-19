import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

// ignore: constant_identifier_names
enum FontType { BOLD, SEMI_BOLD, MEDIUM, REGULAR, LIGHT }

class AppTextStyles {
  static FontWeight fontType(FontType fontType) {
    switch (fontType) {
      case FontType.BOLD:
        return FontWeight.w700;
      case FontType.SEMI_BOLD:
        return FontWeight.w600;
      case FontType.MEDIUM:
        return FontWeight.w500;
      case FontType.REGULAR:
        return FontWeight.w400;
      case FontType.LIGHT:
        return FontWeight.w300;
    }
  }

  static TextStyle textStyle({
    required FontType fontType,
    Color? color,
    required double size,
    required bool isBody,
    bool isLineThrough = false,
    double lineThickness = 0,
    Color? lineColor,
  }) {
    return GoogleFonts.inter(
      decoration:
          isLineThrough ? TextDecoration.lineThrough : TextDecoration.none,
      decorationThickness: isLineThrough ? lineThickness : null,
      decorationColor: isLineThrough ? lineColor : null,
      fontSize: size,
      color: color ?? AppColor.appBlack,
      fontWeight: AppTextStyles.fontType(fontType),
    );
  }

  static TextStyle s8(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 8 : 8.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle s10(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 10 : 10.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle s12(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 12 : 12.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle s14(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 14 : 14.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle s16(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 16 : 16.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle s18(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 18 : 18.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle s20(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 20 : 20.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle s24(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 24 : 24.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);
  static TextStyle s26(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 26 : 26.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle s28(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 28 : 28.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle s30(
          {required Color color,
          required FontType fontType,
          bool isDesktop = false,
          bool isBody = false}) =>
      AppTextStyles.textStyle(
          size: isDesktop ? 30 : 30.sp,
          color: color,
          fontType: fontType,
          isBody: isBody);

  static TextStyle responsive(
      {required Color color,
      required FontType fontType,
      required double sizeDesktop,
      required double sizeTablet,
      bool isBody = false}) {
    if (ScreenUtil().screenWidth > 1200) {
      return AppTextStyles.textStyle(
          size: sizeDesktop, color: color, fontType: fontType, isBody: isBody);
    } else {
      return AppTextStyles.textStyle(
          size: sizeTablet, color: color, fontType: fontType, isBody: isBody);
    }
  }

  static TextStyle withLineThrough({
    required Color color,
    required FontType fontType,
    bool isBody = false,
    required double lineThickness,
    required Color lineColor,
    required double size,
  }) =>
      AppTextStyles.textStyle(
        size: size,
        color: color,
        fontType: fontType,
        isBody: isBody,
        lineColor: lineColor,
        lineThickness: lineThickness,
        isLineThrough: true,
      );
}

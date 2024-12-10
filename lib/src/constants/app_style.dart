import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_app/src/constants/app_colors.dart';

class AppStyles {
  static TextStyle customTextStyle({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14,
    Color color = AppColors.black,
  }) {
    return GoogleFonts.poppins(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
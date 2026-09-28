import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Styles de texte réutilisables, construits sur Google Fonts (Inter),
/// proche de la typographie sans-serif des maquettes.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter(color: AppColors.textPrimary);

  static TextStyle get h1 =>
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get h2 =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.25);

  static TextStyle get h3 =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3);

  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle get bodyRegular =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get buttonLabel => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      );

  static TextStyle get price => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
}

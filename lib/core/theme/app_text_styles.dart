import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';


/// proche de la typographie sans-serif des maquettes.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter(color: AppColors.textPrimary);

  // Titres
  static TextStyle get h1 =>
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get h2 =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.25);

  static TextStyle get h3 =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3);

  // Alias de titre moyen (utilisé par les écrans)
  static TextStyle get headingMedium =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.25);

  // Corps de texte
  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle get bodyRegular =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400);

  // Petit corps de texte
  static TextStyle get bodySmall =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  static TextStyle get caption => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Labels / menus (grid, chips, onglets)
  static TextStyle get labelMedium =>
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600);

  static TextStyle get labelSmall => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // En-têtes de section ("Departments", "Top Hospital")
  static TextStyle get sectionTitle =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  static TextStyle get sectionLink => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // AppBar / greetings
  static TextStyle get greeting => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnPrimary.withValues(alpha: 0.85),
  );

  static TextStyle get userName => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
  );

  // Boutons / prix
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

  // Badges (notification, compteurs)
  static TextStyle get badge => _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
  );
}
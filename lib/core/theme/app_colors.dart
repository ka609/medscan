import 'package:flutter/material.dart';

/// Palette centrale de l'application patient MedScan.
/// Basée sur la charte bleue/blanche des maquettes de référence.
class AppColors {
  AppColors._();

  // Bleus principaux
  static const Color primary = Color(0xFF1B5FE0);
  static const Color primaryDark = Color(0xFF12459E);
  static const Color primaryGradientStart = Color(0xFF1B5FE0);
  static const Color primaryGradientEnd = Color(0xFF3E7BFF);

  // Fonds
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Colors.white;
  static const Color chipBackground = Color(0xFFEAF1FF);

  // Textes
  static const Color textPrimary = Color(0xFF12203D);
  static const Color textSecondary = Color(0xFF7A8699);
  static const Color textOnPrimary = Colors.white;

  // États
  static const Color success = Color(0xFF2BBE7B);
  static const Color error = Color(0xFFE0473F);
  static const Color warning = Color(0xFFF5A524);

  // Bordures / divers
  static const Color border = Color(0xFFE7ECF3);
  static const Color star = Color(0xFFF5A524);
}

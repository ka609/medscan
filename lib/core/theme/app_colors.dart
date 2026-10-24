import 'package:flutter/material.dart';

/// Palette centrale de l'application patient MedScan.
/// Basée sur la charte bleue/blanche des maquettes de référence.
class AppColors {
  AppColors._();

  // Bleus principaux du template
  static const Color primary = Color(0xFF1B5FE0);
  static const Color primaryDark = Color(0xFF1048B3);
  static const Color primaryLight = Color(0xFF4A84F8);
  static const Color primaryGradientStart = Color(0xFF1B5FE0);
  static const Color primaryGradientEnd = Color(0xFF387BFA);

  // Surfaces & Containers
  static const Color primaryContainer = Color(0xFFEEF5FF);
  static const Color onPrimaryContainer = Color(0xFF1B5FE0);
  static const Color outlineVariant = Color(0xFFE8EEF5);

  // Fonds épurés
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color chipBackground = Color(0xFFEEF5FF);

  // Textes
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Colors.white;

  // Pastels modernes pour les départements et icônes
  static const Color softBlue = Color(0xFFEEF5FF);
  static const Color softRed = Color(0xFFFEE2E2);
  static const Color softPink = Color(0xFFFCE7F3);
  static const Color softPurple = Color(0xFFF3E8FF);
  static const Color softGreen = Color(0xFFE6F9F0);
  static const Color softOrange = Color(0xFFFFF3E0);

  // Couleurs d'accent de département
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF97316);

  // États
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color star = Color(0xFFF59E0B);

  // Badges
  static const Color badgeRatingBg = Color(0xFFFEF3C7);
  static const Color badgeRatingText = Color(0xFFB45309);

  // Bordures
  static const Color border = Color(0xFFE6EDF5);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Ombres douces
  static const Color shadow = Color(0x0C0F172A);
  static const Color shadowLight = Color(0x060F172A);
}

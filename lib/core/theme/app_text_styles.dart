import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get _baseStyle => GoogleFonts.poppins();

  // Display
  static TextStyle displayLarge = _baseStyle.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  static TextStyle displayMedium = _baseStyle.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w700,
  );

  static TextStyle displaySmall = _baseStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w600,
  );

  // Headline
  static TextStyle headlineLarge = _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headlineMedium = _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headlineSmall = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // Title
  static TextStyle titleLarge = _baseStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleMedium = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static TextStyle titleSmall = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // Body
  static TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // Label
  static TextStyle labelLarge = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Helpers
  static TextStyle price = _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static TextStyle credit = _baseStyle.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
  );

  static TextStyle button = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}

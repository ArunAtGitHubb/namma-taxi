import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary palette
  static const Color primary = Color(0xFFFFC107);
  static const Color primaryDark = Color(0xFFFFA000);
  static const Color primaryLight = Color(0xFFFFECB3);

  // Secondary
  static const Color secondary = Color(0xFF1A1A2E);
  static const Color secondaryLight = Color(0xFF16213E);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Surface (Dark theme)
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkCard = Color(0xFF2A2A3C);
  static const Color darkBackground = Color(0xFF0F0F1A);

  // Surface (Light theme)
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8F9FA);
  static const Color lightBackground = Color(0xFFF5F5F5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2A2A3C), Color(0xFF1E1E2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

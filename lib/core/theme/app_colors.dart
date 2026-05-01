import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Aura Noir - Dark Luxury Design System
  static const background = Color(0xFF0C141B);
  static const surface = Color(0xFF0C141B);
  static const surfaceDim = Color(0xFF0C141B);
  static const surfaceBright = Color(0xFF313A41);

  static const surfaceContainerLowest = Color(0xFF070F15);
  static const surfaceContainerLow = Color(0xFF141D23);
  static const surfaceContainer = Color(0xFF182127);
  static const surfaceContainerHigh = Color(0xFF222B32);
  static const surfaceContainerHighest = Color(0xFF2D363D);

  static const onSurface = Color(0xFFDBE4ED);
  static const onSurfaceVariant = Color(0xFFD0C5AF);
  static const inverseSurface = Color(0xFFDBE4ED);
  static const inverseOnSurface = Color(0xFF293138);

  static const outline = Color(0xFF99907C);
  static const outlineVariant = Color(0xFF4D4635);

  static const surfaceTint = Color(0xFFE9C349);

  // Primary - Gold accent
  static const primary = Color(0xFFF2CA50);
  static const onPrimary = Color(0xFF3C2F00);
  static const primaryContainer = Color(0xFFD4AF37);
  static const onPrimaryContainer = Color(0xFF554300);
  static const inversePrimary = Color(0xFF735C00);

  static const primaryFixed = Color(0xFFFFE088);
  static const primaryFixedDim = Color(0xFFE9C349);
  static const onPrimaryFixed = Color(0xFF241A00);
  static const onPrimaryFixedVariant = Color(0xFF574500);

  // Secondary - Neutral gray
  static const secondary = Color(0xFFC8C6C5);
  static const onSecondary = Color(0xFF313030);
  static const secondaryContainer = Color(0xFF4A4949);
  static const onSecondaryContainer = Color(0xFFBAB8B7);

  static const secondaryFixed = Color(0xFFE5E2E1);
  static const secondaryFixedDim = Color(0xFFC8C6C5);
  static const onSecondaryFixed = Color(0xFF1C1B1B);
  static const onSecondaryFixedVariant = Color(0xFF474646);

  // Tertiary - Light gray
  static const tertiary = Color(0xFFCDCECF);
  static const onTertiary = Color(0xFF2E3132);
  static const tertiaryContainer = Color(0xFFB1B3B4);
  static const onTertiaryContainer = Color(0xFF434546);

  static const tertiaryFixed = Color(0xFFE1E3E4);
  static const tertiaryFixedDim = Color(0xFFC5C7C8);
  static const onTertiaryFixed = Color(0xFF191C1D);
  static const onTertiaryFixedVariant = Color(0xFF454748);

  // Error
  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  // Success
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFFC8E6C9);

  // Warning
  static const warning = Color(0xFFFFC107);
  static const warningLight = Color(0xFFFFE0B2);

  // Legacy - keeping for compatibility if needed
  static const white = Color(0xFFFFFFFF);
  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;
  static const textDisabled = outlineVariant;
  static const divider = outlineVariant;

  // Additional shades for backward compatibility
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey400 = Color(0xFF9CA3AF);
  static const primaryLight = Color(0xFFEDE9FF);
  static const errorLight = Color(0xFFFEE2E2);
}

import 'package:flutter/material.dart';
import 'package:multy_app/core/constants/app_colors.dart';

abstract final class LandingTheme {
  static const maxWidth = 1200.0;
  static const desktop = 960.0;
  static const gap = 32.0;
  static const radius = 32.0;
  static const body = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );
  static const bodyLarge = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
  );
  static const label = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.56,
  );
  static const badge = TextStyle(
    fontFamily: 'Rubik',
    fontSize: 13,
    height: 16 / 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.65,
  );
  static const cardTitle = TextStyle(
    fontFamily: 'Rubik',
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static TextStyle display(bool compact) => TextStyle(
    fontFamily: 'Rubik',
    fontSize: compact ? 38 : 56,
    height: compact ? 44 / 38 : 64 / 56,
    letterSpacing: compact ? -0.76 : -1.12,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
  );
  static TextStyle heading(bool compact) => TextStyle(
    fontFamily: 'Rubik',
    fontSize: compact ? 26 : 32,
    height: compact ? 32 / 26 : 40 / 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );
  static ThemeData get data => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    fontFamily: 'Plus Jakarta Sans',
    textTheme: const TextTheme(bodyMedium: body, bodyLarge: bodyLarge),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: label,
        minimumSize: const Size(44, 48),
      ),
    ),
  );
}

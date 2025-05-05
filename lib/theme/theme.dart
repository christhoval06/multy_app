import 'package:flutter/material.dart';

import 'package:multiplication_app/theme/color_scheme.dart';
import 'package:multiplication_app/theme/text_theme.dart';

final ThemeData customTheme = ThemeData(
  colorScheme: customColorScheme,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
  ),
  textTheme: customTextTheme,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    filled: true,
    fillColor: Colors.grey[100],
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orangeAccent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
);

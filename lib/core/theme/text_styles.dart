import 'package:flutter/material.dart';

class AppTextStyles {
  static TextTheme textTheme(TextTheme base, ColorScheme colorScheme) {
    return base.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
      fontFamily: 'Outfit',
    );
  }

  // Custom styles can be added here
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: 'Outfit',
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
}

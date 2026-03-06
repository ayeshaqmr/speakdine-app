import 'package:flutter/material.dart';

class AppButtonStyles {
  static FilledButtonThemeData filledButtonTheme(ColorScheme colorScheme) => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(64, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  );

  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colorScheme) => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(64, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 2,
    ),
  );

  static OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colorScheme) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(64, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  );

  static TextButtonThemeData textButtonTheme(ColorScheme colorScheme) => TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: const Size(64, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  static SegmentedButtonThemeData segmentedButtonTheme(ColorScheme colorScheme) => SegmentedButtonThemeData(
    style: SegmentedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    ),
  );
}

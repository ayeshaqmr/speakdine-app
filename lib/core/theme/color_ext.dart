import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';


class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

// Reconstructing the global colorExt getter used throughout the app
ColorScheme get colorExt => ThemeService().themeData.colorScheme;

// Helper extensions to match the original app's custom color names
extension ColorSchemeExtension on ColorScheme {
  Color get primaryText => onSurface;
  Color get secondaryText => onSurfaceVariant;
  Color get placeholder => outlineVariant;
  Color get textField => surfaceContainerHighest;
  Color get incorrect => error;
  Color get white => Colors.white;
  
  // High contrast support (matching existing logic if any)
  Color get surfaceColor => surface;
}

// Helper extension for BuildContext
extension ColorContextExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
}

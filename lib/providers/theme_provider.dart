import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakdine_app/core/theme/app_theme.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  bool _isHighContrast = false;
  double _fontScale = 1.0;
  bool _isDarkMode = false;

  bool get isHighContrast => _isHighContrast;
  double get fontScale => _fontScale;
  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isHighContrast = prefs.getBool('isHighContrast') ?? false;
    _fontScale = prefs.getDouble('fontScale') ?? 1.0;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void toggleHighContrast() async {
    _isHighContrast = !_isHighContrast;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHighContrast', _isHighContrast);
    notifyListeners();
  }

  void setFontScale(double scale) async {
    _fontScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontScale', _fontScale);
    notifyListeners();
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData {
    // Create base text theme with font scaling
    final baseTextTheme = ThemeData.light().textTheme;
    final scaledTextTheme = baseTextTheme.apply(
      fontSizeFactor: _fontScale,
      fontFamily: 'Metropolis',
    );

    // Create MaterialTheme instance
    final materialTheme = MaterialTheme(scaledTextTheme);

    // Get appropriate theme based on mode and contrast
    ThemeData theme;
    if (_isDarkMode) {
      if (_isHighContrast) {
        theme = materialTheme.darkHighContrast();
      } else {
        theme = materialTheme.dark();
      }
    } else {
      if (_isHighContrast) {
        theme = materialTheme.lightHighContrast();
      } else {
        theme = materialTheme.light();
      }
    }

    return theme;
  }
}

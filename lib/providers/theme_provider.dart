import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.liquidBlue;
  
  AppThemeMode get themeMode => _themeMode;
  
  ThemeData get theme {
    switch (_themeMode) {
      case AppThemeMode.liquidBlue:
        return AppTheme.getLiquidBlueTheme();
      case AppThemeMode.liquidDark:
        return AppTheme.getLiquidDarkTheme();
    }
  }

  bool get isDarkMode => _themeMode == AppThemeMode.liquidDark;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode');
    
    if (savedTheme != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => AppThemeMode.liquidBlue,
      );
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }

  Future<void> toggleTheme() async {
    if (_themeMode == AppThemeMode.liquidBlue) {
      await setTheme(AppThemeMode.liquidDark);
    } else {
      await setTheme(AppThemeMode.liquidBlue);
    }
  }

  Color getGradientColor(int index) {
    if (_themeMode == AppThemeMode.liquidBlue) {
      switch (index % 3) {
        case 0:
          return AppTheme.liquidBlueGradientStart;
        case 1:
          return AppTheme.liquidBlueGradientMiddle;
        default:
          return AppTheme.liquidBlueGradientEnd;
      }
    } else {
      return AppTheme.liquidDarkSurface;
    }
  }

  LinearGradient getMainGradient() {
    return _themeMode == AppThemeMode.liquidBlue
        ? AppTheme.getLiquidBlueGradient()
        : AppTheme.getLiquidDarkGradient();
  }
}

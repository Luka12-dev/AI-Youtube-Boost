import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  liquidBlue,
  liquidDark,
}

class AppTheme {
  static const Color liquidBlueGradientStart = Color(0xFF00B4DB);
  static const Color liquidBlueGradientMiddle = Color(0xFF0083B0);
  static const Color liquidBlueGradientEnd = Color(0xFF00A8CC);
  static const Color liquidBluePrimary = Color(0xFF0099CC);
  static const Color liquidBlueAccent = Color(0xFF00D4FF);
  static const Color liquidBlueBackground = Color(0xFFF5F9FC);
  static const Color liquidBlueSurface = Color(0xFFFFFFFF);
  static const Color liquidBlueText = Color(0xFF1A1A1A);
  static const Color liquidBlueTextSecondary = Color(0xFF666666);

  static const Color liquidDarkBackground = Color(0xFF000000);
  static const Color liquidDarkSurface = Color(0xFF0A0A0A);
  static const Color liquidDarkSurfaceVariant = Color(0xFF1A1A1A);
  static const Color liquidDarkPrimary = Color(0xFF2A2A2A);
  static const Color liquidDarkAccent = Color(0xFF404040);
  static const Color liquidDarkText = Color(0xFFFFFFFF);
  static const Color liquidDarkTextSecondary = Color(0xFFB0B0B0);

  static ThemeData getLiquidBlueTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: liquidBluePrimary,
      scaffoldBackgroundColor: liquidBlueBackground,
      colorScheme: const ColorScheme.light(
        primary: liquidBluePrimary,
        secondary: liquidBlueAccent,
        surface: liquidBlueSurface,
        background: liquidBlueBackground,
        error: Color(0xFFFF5252),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: liquidBlueText,
        onBackground: liquidBlueText,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: liquidBlueText,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: liquidBlueText,
            letterSpacing: -0.5,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: liquidBlueText,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: liquidBlueText,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: liquidBlueText,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: liquidBlueText,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: liquidBlueText,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: liquidBlueTextSecondary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: liquidBlueText,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: liquidBlueText,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: liquidBlueTextSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: liquidBlueText,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: liquidBlueText,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: liquidBlueText,
        ),
        iconTheme: const IconThemeData(color: liquidBlueText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: liquidBlueSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: liquidBluePrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: liquidBluePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: liquidBlueSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: liquidBluePrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: liquidBlueTextSecondary),
      ),
      iconTheme: const IconThemeData(color: liquidBluePrimary),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: liquidBlueAccent.withOpacity(0.1),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: liquidBluePrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ThemeData getLiquidDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: liquidDarkPrimary,
      scaffoldBackgroundColor: liquidDarkBackground,
      colorScheme: const ColorScheme.dark(
        primary: liquidDarkPrimary,
        secondary: liquidDarkAccent,
        surface: liquidDarkSurface,
        background: liquidDarkBackground,
        error: Color(0xFFFF5252),
        onPrimary: liquidDarkText,
        onSecondary: liquidDarkText,
        onSurface: liquidDarkText,
        onBackground: liquidDarkText,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: liquidDarkText,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: liquidDarkText,
            letterSpacing: -0.5,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: liquidDarkText,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: liquidDarkText,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: liquidDarkText,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: liquidDarkText,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: liquidDarkText,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: liquidDarkTextSecondary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: liquidDarkText,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: liquidDarkText,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: liquidDarkTextSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: liquidDarkText,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: liquidDarkText,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: liquidDarkText,
        ),
        iconTheme: const IconThemeData(color: liquidDarkText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: liquidDarkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: liquidDarkPrimary,
          foregroundColor: liquidDarkText,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: liquidDarkText,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: liquidDarkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: liquidDarkSurfaceVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: liquidDarkSurfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: liquidDarkAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: liquidDarkTextSecondary),
      ),
      iconTheme: const IconThemeData(color: liquidDarkText),
      dividerTheme: const DividerThemeData(
        color: liquidDarkSurfaceVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: liquidDarkSurfaceVariant,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: liquidDarkText,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static LinearGradient getLiquidBlueGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        liquidBlueGradientStart,
        liquidBlueGradientMiddle,
        liquidBlueGradientEnd,
      ],
    );
  }

  static LinearGradient getLiquidDarkGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        liquidDarkSurface,
        liquidDarkBackground,
        liquidDarkSurface,
      ],
    );
  }
}

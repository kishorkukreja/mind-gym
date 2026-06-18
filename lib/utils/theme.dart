import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Clean cognition palette: quiet reading surfaces with restrained accents.
  static const Color primary = Color(0xFF00897B); // Deep teal
  static const Color primaryLight = Color(0xFF4DB6AC); // Light teal
  static const Color accent = Color(0xFF00695C); // Dark teal
  static const Color background = Color(0xFFF5F7F7); // Off-white
  static const Color surface = Color(0xFFFFFFFF); // White cards
  static const Color surfaceVariant = Color(0xFFE8F5F5); // Teal-tinted surface
  static const Color readingSurface = Color(0xFFFFFCF7);
  static const Color border = Color(0xFFE0ECEB); // Soft teal border
  static const Color textPrimary = Color(0xFF1A2E2D); // Dark text
  static const Color textSecondary = Color(0xFF6B8F8D); // Muted teal-gray
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFE65100);
  static const Color philosophyColor = Color(0xFF5C6BC0); // Indigo for philosophy
  static const Color biasColor = Color(0xFF00897B); // Teal for cognitive bias

  static const double radius = 8;
  static const double pillRadius = 999;
  static const double screenPadding = 20;
  static const double cardPadding = 18;

  static TextStyle get brandTextStyle => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 3.2,
        color: primary,
      );

  static TextStyle get sectionLabelStyle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: textSecondary,
      );

  static TextStyle get metricStyle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      );

  static TextStyle get ctaTextStyle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      );

  static TextStyle get readingTextStyle => GoogleFonts.lora(
        fontSize: 15,
        height: 1.65,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  static TextStyle get challengePromptTextStyle => GoogleFonts.lora(
        fontSize: 16,
        height: 1.7,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  static TextStyle get messageTextStyle => GoogleFonts.lora(
        fontSize: 14.5,
        height: 1.6,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: primaryLight,
        surface: surface,
        error: errorColor,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.15,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.25,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.3,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: border,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: ctaTextStyle,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Quiet Luxury / Elegant Palette)
  static const Color creamBg = Color(
    0xFFFDFBF7,
  ); // Softer cream for modern look
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color navyText = Color(
    0xFF1E293B,
  ); // Slate/Navy blend for softer ultra-dark
  static const Color primaryNavy = Color(
    0xFF31487A,
  ); // Using user's original Navy
  static const Color primaryNavyVariant = Color(0xFF1D2D4F); // Darker variant
  static const Color accentPink = Color(0xFFE79AA8); // User's original Pink

  static const Color secondaryText = Color(0xFF64748B);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // Legacy colors for backwards compatibility
  static const Color cream = Color(0xFFFFF7E5);
  static const Color navy = Color(0xFF31487A);
  static const Color pink = Color(0xFFE79AA8);
  static const Color pinkFill = Color(0xFFF3C1CA);

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();

    // Arabic Font Configuration
    final textTheme = GoogleFonts.cairoTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.cairo(
        color: navyText,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.cairo(
        color: navyText,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.cairo(
        color: navyText,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.cairo(
        color: navyText,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.cairo(
        color: navyText,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.cairo(
        color: navyText,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.cairo(
        color: secondaryText,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.cairo(
        color: surfaceColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamBg,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        onPrimary: surfaceColor,
        secondary: accentPink,
        onSecondary: surfaceColor,
        surface: surfaceColor,
        error: Colors.redAccent,
      ),
      textTheme: textTheme,

      // Navigation Bar (Material 3 Bottom Nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: accentPink.withValues(alpha: 0.2), // Subtle indicator
        surfaceTintColor:
            Colors.transparent, // Disable the Material 3 tinting overlay
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryNavy,
            );
          }
          return GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: secondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryNavy, size: 26);
          }
          return const IconThemeData(color: secondaryText, size: 24);
        }),
      ),

      // App Bar Style
      appBarTheme: AppBarTheme(
        backgroundColor: creamBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: primaryNavy),
        titleTextStyle: GoogleFonts.cairo(
          color: primaryNavy,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Style
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: borderSubtle,
            width: 1,
          ), // Quiet luxury outline instead of heavy shadow
        ),
      ),

      // Button Style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: surfaceColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Subtle Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryNavy,
        foregroundColor: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}

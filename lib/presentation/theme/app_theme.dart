import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeVariant { defaultTheme, pinkTheme }

class AppPalette {
  final Color creamBg;
  final Color surfaceColor;
  final Color navyText;
  final Color primaryNavy;
  final Color primaryNavyVariant;
  final Color accentPink;
  final Color secondaryText;
  final Color borderSubtle;

  const AppPalette({
    required this.creamBg,
    required this.surfaceColor,
    required this.navyText,
    required this.primaryNavy,
    required this.primaryNavyVariant,
    required this.accentPink,
    required this.secondaryText,
    required this.borderSubtle,
  });
}

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

  static const AppPalette _defaultPalette = AppPalette(
    creamBg: creamBg,
    surfaceColor: surfaceColor,
    navyText: navyText,
    primaryNavy: primaryNavy,
    primaryNavyVariant: primaryNavyVariant,
    accentPink: accentPink,
    secondaryText: secondaryText,
    borderSubtle: borderSubtle,
  );

  static const AppPalette _pinkPalette = AppPalette(
    creamBg: Color(0xFFFFF4E8),
    surfaceColor: Color(0xFFFFF7E8),
    navyText: Color(0xFF2A2A2A),
    primaryNavy: Color(0xFF31487A),
    primaryNavyVariant: Color(0xFF1D2D4F),
    accentPink: Color(0xFFE18299),
    secondaryText: Color(0xFF5B5B5B),
    borderSubtle: Color(0xFFE8B2C1),
  );

  static ThemeData get lightTheme {
    return _buildTheme(1.0, _defaultPalette);
  }

  static ThemeData lightThemeWithScale(double scale) {
    return _buildTheme(scale, _defaultPalette);
  }

  static ThemeData themeFor(AppThemeVariant variant, double scale) {
    final palette =
        variant == AppThemeVariant.pinkTheme ? _pinkPalette : _defaultPalette;
    return _buildTheme(scale, palette);
  }

  static ThemeData _buildTheme(double scale, AppPalette palette) {
    final baseTheme = ThemeData.light();

    // Arabic Font Configuration
    final baseCairo = GoogleFonts.cairoTextTheme(baseTheme.textTheme);
    final textTheme = baseCairo.copyWith(
      displayLarge: GoogleFonts.cairo(
        color: palette.navyText,
        fontWeight: FontWeight.bold,
        fontSize: baseCairo.displayLarge?.fontSize,
      ),
      displayMedium: GoogleFonts.cairo(
        color: palette.navyText,
        fontWeight: FontWeight.bold,
        fontSize: baseCairo.displayMedium?.fontSize,
      ),
      displaySmall: GoogleFonts.cairo(
        color: palette.navyText,
        fontWeight: FontWeight.bold,
        fontSize: baseCairo.displaySmall?.fontSize,
      ),
      headlineMedium: GoogleFonts.cairo(
        color: palette.navyText,
        fontWeight: FontWeight.w700,
        fontSize: baseCairo.headlineMedium?.fontSize,
      ),
      titleLarge: GoogleFonts.cairo(
        color: palette.navyText,
        fontWeight: FontWeight.w600,
        fontSize: baseCairo.titleLarge?.fontSize,
      ),
      bodyLarge: GoogleFonts.cairo(
        color: palette.navyText,
        fontWeight: FontWeight.normal,
        fontSize: baseCairo.bodyLarge?.fontSize,
      ),
      bodyMedium: GoogleFonts.cairo(
        color: palette.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: baseCairo.bodyMedium?.fontSize,
      ),
      labelLarge: GoogleFonts.cairo(
        color: palette.surfaceColor,
        fontWeight: FontWeight.w600,
        fontSize: baseCairo.labelLarge?.fontSize ?? 16,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.creamBg,
      colorScheme: ColorScheme.light(
        primary: palette.primaryNavy,
        onPrimary: palette.surfaceColor,
        secondary: palette.accentPink,
        onSecondary: palette.surfaceColor,
        surface: palette.surfaceColor,
        error: Colors.redAccent,
      ),
      textTheme: textTheme,

      // Navigation Bar (Material 3 Bottom Nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surfaceColor,
        indicatorColor: palette.accentPink.withValues(alpha: 0.2),
        surfaceTintColor:
            Colors.transparent, // Disable the Material 3 tinting overlay
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: palette.primaryNavy,
            );
          }
          return GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: palette.secondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.primaryNavy, size: 26 * scale);
          }
          return IconThemeData(color: palette.secondaryText, size: 24 * scale);
        }),
      ),

      // App Bar Style
      appBarTheme: AppBarTheme(
        backgroundColor: palette.creamBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: palette.primaryNavy),
        titleTextStyle: GoogleFonts.cairo(
          color: palette.primaryNavy,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Style
      cardTheme: CardThemeData(
        color: palette.surfaceColor,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: palette.borderSubtle,
            width: 1,
          ), // Quiet luxury outline instead of heavy shadow
        ),
      ),

      // Button Style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primaryNavy,
          foregroundColor: palette.surfaceColor,
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

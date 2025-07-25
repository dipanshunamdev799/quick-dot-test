import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A class to hold all the theme-related configurations.
class AppTheme {
  // Private constructor to prevent instantiation.
  AppTheme._();

  // --- COLORS ---
  // Define the core colors for the application.
  // Using a tool like coolors.co can help generate beautiful palettes.
  static const Color _primaryColor = Color(0xFF6200EE);
  static const Color _primaryVariantColor = Color(0xFF3700B3);
  static const Color _secondaryColor = Color(0xFF03DAC6);
  static const Color _secondaryVariantColor = Color(0xFF018786);

  // Light Theme Colors
  static const Color _lightBackgroundColor = Color(0xFFF5F5F7);
  static const Color _lightSurfaceColor = Colors.white;
  static const Color _lightErrorColor = Color(0xFFB00020);
  static const Color _lightOnPrimaryColor = Colors.white;
  static const Color _lightOnSecondaryColor = Colors.black;
  static const Color _lightOnBackgroundColor = Color(0xFF212121);
  static const Color _lightOnSurfaceColor = Color(0xFF212121);
  static const Color _lightOnErrorColor = Colors.white;

  // Dark Theme Colors
  static const Color _darkBackgroundColor = Color(0xFF121212);
  static const Color _darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color _darkErrorColor = Color(0xFFCF6679);
  static const Color _darkOnPrimaryColor = Colors.black;
  static const Color _darkOnSecondaryColor = Colors.black;
  static const Color _darkOnBackgroundColor = Colors.white;
  static const Color _darkOnSurfaceColor = Colors.white;
  static const Color _darkOnErrorColor = Colors.black;


  // --- TEXT THEME ---
  // Define the text styles using Google Fonts for a modern look.
  static final TextTheme _lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 96, fontWeight: FontWeight.w300, letterSpacing: -1.5, color: _lightOnSurfaceColor),
    displayMedium: GoogleFonts.poppins(fontSize: 60, fontWeight: FontWeight.w300, letterSpacing: -0.5, color: _lightOnSurfaceColor),
    displaySmall: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w400, color: _lightOnSurfaceColor),
    headlineMedium: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: _lightOnSurfaceColor),
    headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w400, color: _lightOnSurfaceColor),
    titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: _lightOnSurfaceColor),
    titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15, color: _lightOnSurfaceColor),
    titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: _lightOnSurfaceColor),
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: _lightOnSurfaceColor),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: _lightOnSurfaceColor),
    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25, color: _lightOnPrimaryColor), // For buttons
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: _lightOnSurfaceColor),
    labelSmall: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5, color: _lightOnSurfaceColor),
  );

  static final TextTheme _darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 96, fontWeight: FontWeight.w300, letterSpacing: -1.5, color: _darkOnSurfaceColor),
    displayMedium: GoogleFonts.poppins(fontSize: 60, fontWeight: FontWeight.w300, letterSpacing: -0.5, color: _darkOnSurfaceColor),
    displaySmall: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w400, color: _darkOnSurfaceColor),
    headlineMedium: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: _darkOnSurfaceColor),
    headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w400, color: _darkOnSurfaceColor),
    titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: _darkOnSurfaceColor),
    titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15, color: _darkOnSurfaceColor),
    titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: _darkOnSurfaceColor),
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: _darkOnSurfaceColor),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: _darkOnSurfaceColor),
    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25, color: _darkOnPrimaryColor), // For buttons
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: _darkOnSurfaceColor),
    labelSmall: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5, color: _darkOnSurfaceColor),
  );


  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightBackgroundColor,
    primaryColor: _primaryColor,
    textTheme: _lightTextTheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      primaryContainer: _primaryVariantColor,
      secondary: _secondaryColor,
      secondaryContainer: _secondaryVariantColor,
      background: _lightBackgroundColor,
      surface: _lightSurfaceColor,
      error: _lightErrorColor,
      onPrimary: _lightOnPrimaryColor,
      onSecondary: _lightOnSecondaryColor,
      onBackground: _lightOnBackgroundColor,
      onSurface: _lightOnSurfaceColor,
      onError: _lightOnErrorColor,
    ),

    // Component Themes
    appBarTheme: AppBarTheme(
      backgroundColor: _lightBackgroundColor,
      foregroundColor: _lightOnBackgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: _lightOnBackgroundColor),
      titleTextStyle: _lightTextTheme.titleLarge,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _lightOnPrimaryColor,
        backgroundColor: _primaryColor,
        textStyle: _lightTextTheme.labelLarge,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: _lightOnPrimaryColor,
    ),

    cardTheme: CardThemeData(
      color: _lightSurfaceColor,
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shadowColor: _primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: _primaryColor, width: 2.0),
      ),
      labelStyle: _lightTextTheme.bodyMedium,
    ),
  );


  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackgroundColor,
    primaryColor: _primaryColor,
    textTheme: _darkTextTheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      primaryContainer: _primaryVariantColor,
      secondary: _secondaryColor,
      background: _darkBackgroundColor,
      surface: _darkSurfaceColor,
      error: _darkErrorColor,
      onPrimary: _darkOnPrimaryColor,
      onSecondary: _darkOnSecondaryColor,
      onBackground: _darkOnBackgroundColor,
      onSurface: _darkOnSurfaceColor,
      onError: _darkOnErrorColor,
    ),

    // Component Themes
    appBarTheme: AppBarTheme(
      backgroundColor: _darkSurfaceColor,
      foregroundColor: _darkOnSurfaceColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: _darkOnSurfaceColor),
      titleTextStyle: _darkTextTheme.titleLarge?.copyWith(color: _darkOnSurfaceColor),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _darkOnPrimaryColor,
        backgroundColor: _secondaryColor, // Use secondary color for more pop in dark mode
        textStyle: _darkTextTheme.labelLarge?.copyWith(color: _darkOnPrimaryColor),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _secondaryColor,
      foregroundColor: _darkOnSecondaryColor,
    ),

    cardTheme: CardThemeData(
      color: _darkSurfaceColor,
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shadowColor: _secondaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: _secondaryColor, width: 2.0),
      ),
      labelStyle: _darkTextTheme.bodyMedium,
    ),
  );
}

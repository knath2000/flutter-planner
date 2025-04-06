import 'package:flutter/material.dart';

class AppTheme {
  // Define core colors - choose vibrant, distinct colors
  static const Color primaryColor = Color(0xFF00FFFF); // Cyan / Aqua
  static const Color secondaryColor = Color(0xFFF02E65); // Bright Pink/Magenta
  static const Color accentColor = Color(0xFF7FFF00); // Chartreuse Green
  static const Color backgroundColor = Color(
    0xFF121212,
  ); // Very dark grey/black
  static const Color surfaceColor = Color(
    0xFF1E1E1E,
  ); // Slightly lighter dark grey
  static const Color errorColor = Color(0xFFFF4D4D); // Bright red

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor:
          Colors.transparent, // Allow AnimatedBackground to show
      primaryColor: primaryColor,

      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.black, // Text/icons on primary color
        onSecondary: Colors.black, // Text/icons on secondary color
        onSurface: Colors.white, // Text/icons on background color
        onError: Colors.black, // Text/icons on error color
        brightness: Brightness.dark,
      ),

      // Define custom text theme (example using a placeholder font)
      // TODO: Integrate custom fonts later via pubspec.yaml
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white60),
        labelLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ), // For buttons
      ).apply(
        // Apply base color to all text styles if needed
        bodyColor: Colors.white.withOpacity(0.8),
        displayColor: Colors.white,
      ),

      // Define custom button theme (example)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, // Text color
          backgroundColor: primaryColor, // Button background
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ), // Pill shape
        ),
      ),

      // Define custom AppBar theme (transparent by default in our views)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // Back button etc.
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Define custom card theme (though we use custom Containers mostly)
      cardTheme: CardTheme(
        color: surfaceColor.withOpacity(0.8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
      ),

      // Define custom icon theme
      iconTheme: const IconThemeData(
        color: primaryColor, // Default icon color
        size: 24.0,
      ),

      // Use Material 3 features
      useMaterial3: true,
    );
  }
}

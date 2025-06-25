import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized Material 3 themes for the entire Back2U app.
///
/// Call [AppTheme.lightTheme] or [AppTheme.darkTheme] from your
/// `MaterialApp` to get a fully-configured ThemeData that is
/// consistent across the project.
class AppTheme {
  // --- Brand Colors ---
  // Primary: Deep Royal Blue for document recovery (Hex #0097B2)
  // Secondary accent: Fresh Green (Hex #00BF63)
  static const Color _primarySeed = Color(0xFF0097B2);
  // static const Color _secondarySeed = Color.fromARGB(255, 110, 170, 238);
  static const Color _secondarySeed = Color(0xFF00BF63);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  /// Returns a ThemeData for the given brightness using M3 defaults.
  static ThemeData _buildTheme(Brightness brightness) {
    final ColorScheme primaryScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: brightness,
    );

    // Derive harmonious secondary colors
    final ColorScheme secondaryScheme = ColorScheme.fromSeed(
      seedColor: _secondarySeed,
      brightness: brightness,
    );

    final ColorScheme colorScheme = primaryScheme.copyWith(
      secondary: secondaryScheme.primary,
      onSecondary: secondaryScheme.onPrimary,
      secondaryContainer: secondaryScheme.primaryContainer,
      onSecondaryContainer: secondaryScheme.onPrimaryContainer,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Poppins',
      // scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        titleTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          fontFamily: 'Poppins',
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardTheme(
        // color: colorScheme.surfaceDim.withOpacity(0.2),
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceDim.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      // Performance optimizations
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins'),
        displayMedium: TextStyle(fontFamily: 'Poppins'),
        displaySmall: TextStyle(fontFamily: 'Poppins'),
        headlineLarge: TextStyle(fontFamily: 'Poppins'),
        headlineMedium: TextStyle(fontFamily: 'Poppins'),
        headlineSmall: TextStyle(fontFamily: 'Poppins'),
        titleLarge: TextStyle(fontFamily: 'Poppins'),
        titleMedium: TextStyle(fontFamily: 'Poppins'),
        titleSmall: TextStyle(fontFamily: 'Poppins'),
        bodyLarge: TextStyle(fontFamily: 'Poppins'),
        bodyMedium: TextStyle(fontFamily: 'Poppins'),
        bodySmall: TextStyle(fontFamily: 'Poppins'),
        labelLarge: TextStyle(fontFamily: 'Poppins'),
        labelMedium: TextStyle(fontFamily: 'Poppins'),
        labelSmall: TextStyle(fontFamily: 'Poppins'),
      ),
    );
  }
}

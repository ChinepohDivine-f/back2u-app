import 'package:flutter/material.dart';

/// Centralized Material 3 themes for the entire Back2U app.
///
/// Call [AppTheme.lightTheme] or [AppTheme.darkTheme] from your
/// `MaterialApp` to get a fully-configured ThemeData that is
/// consistent across the project.
class AppTheme {
  // Seed color that drives the generated M3 color palettes.
  // Change this in one place to re-brand the whole application.
  static const Color _seedColor = Color(0xFF0066FF);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  /// Returns a ThemeData for the given brightness using M3 defaults.
  static ThemeData _buildTheme(Brightness brightness) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      // You can add more component-specific theming here as needed.
    );
  }
}

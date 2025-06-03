import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier

/// A simple provider to manage the application's theme mode.
/// It extends ChangeNotifier to allow widgets to listen for theme changes.
class ThemeProvider with ChangeNotifier {
  // Private variable to hold the current theme mode.
  // Defaults to ThemeMode.system, meaning it follows the device's system setting.
  ThemeMode _themeMode = ThemeMode.system;

  /// Public getter to access the current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Sets the new theme mode for the application.
  ///
  /// [mode]: The new ThemeMode (light, dark, or system) to apply.
  void setThemeMode(ThemeMode mode) {
    // Only update and notify listeners if the theme mode has actually changed
    if (_themeMode != mode) {
      _themeMode = mode;
      // Call notifyListeners() to inform all widgets that are listening
      // to this provider that the theme has changed, triggering a rebuild.
      notifyListeners();
    }
  }

  // --- Optional: Methods for persisting theme preference (e.g., using shared_preferences) ---
  // You would typically integrate a package like 'shared_preferences' here
  // to save the user's selected theme so it persists across app launches.

  // import 'package:shared_preferences/shared_preferences.dart';

  // Future<void> loadThemeFromPrefs() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final themeString = prefs.getString('themeMode') ?? 'system'; // Default to 'system'
  //   _themeMode = ThemeMode.values.firstWhere(
  //     (e) => e.toString() == 'ThemeMode.$themeString',
  //     orElse: () => ThemeMode.system, // Fallback if string is invalid
  //   );
  //   notifyListeners();
  // }

  // Future<void> saveThemeToPrefs(ThemeMode mode) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('themeMode', mode.name); // Save using the enum's name
  // }
}
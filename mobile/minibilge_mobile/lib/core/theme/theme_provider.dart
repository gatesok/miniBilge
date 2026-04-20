import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode state notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(_loadThemeMode(_prefs));

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final String? themeModeString = prefs.getString(_key);
    if (themeModeString == null) {
      return ThemeMode.system; // Default to system theme
    }
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == themeModeString,
      orElse: () => ThemeMode.system,
    );
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }

  /// Set specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.toString());
  }

  /// Set to system theme
  Future<void> setSystemTheme() async {
    await setTheme(ThemeMode.system);
  }

  /// Check if current theme is dark
  bool get isDark => state == ThemeMode.dark;

  /// Check if current theme is light
  bool get isLight => state == ThemeMode.light;

  /// Check if current theme is system
  bool get isSystem => state == ThemeMode.system;
}

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Provider for theme mode
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences that apply to the whole app, persisted locally.
class AppSettings extends ChangeNotifier {
  AppSettings();

  static const _themeKey = 'settings_theme_mode';
  static const _localeKey = 'settings_locale';

  /// Languages the app is translated into.
  static const supportedLanguageCodes = ['en', 'it'];

  ThemeMode _themeMode = ThemeMode.system;

  Locale? _locale; // null follows the system language

  ThemeMode get themeMode => _themeMode;

  /// The chosen language, or null to follow the system.
  Locale? get locale => _locale;

  /// Reads the saved preferences. Safe to call more than once.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    final code = prefs.getString(_localeKey);
    _locale = supportedLanguageCodes.contains(code) ? Locale(code!) : null;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  /// Pass null to follow the system language.
  Future<void> setLocale(Locale? locale) async {
    if (locale?.languageCode == _locale?.languageCode) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
  }
}

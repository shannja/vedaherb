import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language';
  static const _notificationsKey = 'notifications';
  static const _anonymousUsageKey = 'anonymous_usage';

  ThemeMode loadThemeMode() {
    final index = _prefs.getInt(_themeKey) ?? ThemeMode.light.index;
    return ThemeMode.values[index];
  }

  Future<void> saveThemeMode(ThemeMode mode) => _prefs.setInt(_themeKey, mode.index);

  String loadLanguage() => _prefs.getString(_languageKey) ?? 'English';

  Future<void> saveLanguage(String language) => _prefs.setString(_languageKey, language);

  bool loadNotificationsEnabled() => _prefs.getBool(_notificationsKey) ?? true;

  Future<void> saveNotificationsEnabled(bool value) => _prefs.setBool(_notificationsKey, value);

  bool loadAnonymousUsageEnabled() => _prefs.getBool(_anonymousUsageKey) ?? false;

  Future<void> saveAnonymousUsageEnabled(bool value) => _prefs.setBool(_anonymousUsageKey, value);
}


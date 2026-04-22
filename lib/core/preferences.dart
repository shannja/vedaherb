import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class PreferencesService {
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language';
  static const _notificationsKey = 'notifications';
  static const _anonymousUsageKey = 'anonymous_usage';

  static Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  static Future<ThemeMode> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeKey) ?? ThemeMode.light.index;
    return ThemeMode.values[index];
  }

  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'English';
  }

  static Future<void> saveAnonymousUsage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_anonymousUsageKey, value);
  }

  static Future<bool> loadAnonymousUsage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_anonymousUsageKey) ?? false;
  }

  static Future<void> saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  static Future<bool> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }
}
import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool anonymousUsageEnabled;

  const SettingsState({
    required this.themeMode,
    required this.language,
    required this.notificationsEnabled,
    required this.anonymousUsageEnabled,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? anonymousUsageEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      anonymousUsageEnabled: anonymousUsageEnabled ?? this.anonymousUsageEnabled,
    );
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// App-wide, user-facing preferences.
///
/// These will be consolidated into a controller in a later refactor step.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void setMode(ThemeMode next) => state = next;
}

class LanguageNotifier extends Notifier<String> {
  @override
  String build() => 'English';

  void setLanguage(String next) => state = next;
}

class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setEnabled(bool next) => state = next;
}

class AnonymousUsageNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled(bool next) => state = next;
}

final themeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
final languageProvider = NotifierProvider<LanguageNotifier, String>(
  LanguageNotifier.new,
);
final notificationsProvider = NotifierProvider<NotificationsNotifier, bool>(
  NotificationsNotifier.new,
);
final anonymousUsageProvider = NotifierProvider<AnonymousUsageNotifier, bool>(
  AnonymousUsageNotifier.new,
);


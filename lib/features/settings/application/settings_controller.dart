import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vedaherb/core/persistence/shared_prefs.dart';
import 'package:vedaherb/features/settings/data/settings_repository.dart';
import 'package:vedaherb/features/settings/domain/settings_state.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);

class SettingsController extends AsyncNotifier<SettingsState> {
  SettingsRepository? _repo;

  @override
  Future<SettingsState> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    _repo = SettingsRepository(prefs);

    // Synchronous reads from SharedPreferences; keep signature Future for
    // composability and potential future async data sources.
    return SettingsState(
      themeMode: _repo!.loadThemeMode(),
      language: _repo!.loadLanguage(),
      notificationsEnabled: _repo!.loadNotificationsEnabled(),
      anonymousUsageEnabled: _repo!.loadAnonymousUsageEnabled(),
    );
  }

  Future<void> setThemeMode(ThemeMode next) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(themeMode: next));
    await _repo?.saveThemeMode(next);
  }

  Future<void> setLanguage(String next) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(language: next));
    await _repo?.saveLanguage(next);
  }

  Future<void> setNotificationsEnabled(bool next) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(notificationsEnabled: next));
    await _repo?.saveNotificationsEnabled(next);
  }

  Future<void> setAnonymousUsageEnabled(bool next) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(anonymousUsageEnabled: next));
    await _repo?.saveAnonymousUsageEnabled(next);
  }
}


import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  OnboardingRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

  bool getHasSeenOnboarding() =>
      _prefs.getBool(_hasSeenOnboardingKey) ?? false;

  Future<void> setHasSeenOnboarding(bool value) =>
      _prefs.setBool(_hasSeenOnboardingKey, value);
}


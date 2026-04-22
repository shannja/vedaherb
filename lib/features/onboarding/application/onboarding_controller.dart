import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vedaherb/core/persistence/shared_prefs.dart';
import 'package:vedaherb/features/onboarding/data/onboarding_repository.dart';

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

class OnboardingController extends AsyncNotifier<bool> {
  OnboardingRepository? _repo;

  @override
  Future<bool> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    _repo = OnboardingRepository(prefs);
    return _repo!.getHasSeenOnboarding();
  }

  Future<void> setHasSeenOnboarding() async {
    state = const AsyncData(true);
    await _repo?.setHasSeenOnboarding(true);
  }
}


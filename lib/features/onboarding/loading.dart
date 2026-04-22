import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vedaherb/features/onboarding/application/onboarding_controller.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatusAndNavigate();
  }

  /// Determines the initial destination based on user persistence.
  Future<void> _checkStatusAndNavigate() async {
    // Artificial delay to ensure the branding/logo is visible.
    await Future.delayed(const Duration(seconds: 2));
    final bool hasSeenOnboarding =
        await ref.read(onboardingControllerProvider.future);

    // Ensure context is still valid before triggering GoRouter navigation.
    if (mounted) {
      hasSeenOnboarding ? context.go('/home') : context.go('/tutorial');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Image.asset('assets/images/logo/logo.png', width: 285),
      ),
    );
  }
}
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:vedaherb/features/onboarding/loading.dart';
import 'package:vedaherb/features/onboarding/tutorial.dart';
import 'package:vedaherb/features/dashboard/dashboard.dart';
import 'package:vedaherb/features/session/session.dart';
import 'package:vedaherb/features/settings/settings.dart';

/// Helper to wrap screens in a consistent transition.
CustomTransitionPage _popPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, anim, secondaryAnim, child) {
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: anim.drive(
            Tween<double>(
              begin: 0.90, // Start slightly smaller
              end: 1.0,    // Pop to full size
            ).chain(CurveTween(curve: Curves.easeOutCubic)), // Adds the "pop" bounce
          ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 600),
  );
}

CustomTransitionPage _fadePage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  int durationMs = 800,
}) {
  return CustomTransitionPage(
    key: state.pageKey, 
    child: child,
    transitionsBuilder: (context, anim, secondaryAnim, child) {
      return FadeTransition(
        opacity: CurvedAnimation( 
          parent: anim,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: durationMs),
  );
}

CustomTransitionPage _slideRightPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, anim, secondaryAnim, child) {
      return SlideTransition(
        position: anim.drive(
          Tween<Offset>(
            begin: const Offset(1, 0), // Start off-screen right
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

/// Global provider for application routing logic.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/loading',
    routes: [
      GoRoute(
        path: '/loading',
        pageBuilder: (context, state) => _fadePage(
          context: context,
          state: state,
          child: const LoadingScreen(),
        ),
      ),
      GoRoute(
        path: '/tutorial',
        pageBuilder: (context, state) => _fadePage(
          context: context,
          state: state,
          child: const TutorialScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _popPage(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/session/:sessionId',
        name: 'session',
        pageBuilder: (context, state)  => _popPage(
          context: context,
          state: state,
          child: SessionScreen(
            entryPoint: state.extra as SessionEntryPoint? ?? SessionEntryPoint.camera,
            sessionId: state.pathParameters['sessionId'],
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _slideRightPage(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),
    ],
  );
});
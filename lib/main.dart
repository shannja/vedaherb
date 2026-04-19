import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vedaherb/core/router.dart';

import 'package:vedaherb/core/theme.dart';

/// Manages app-wide brightness (Light/Dark/System)
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  /// DEBUG ONLY
  // Set to true to clear onboarding status on every app launch for testing purposes.
  final clearPreferences = true; 
  if (clearPreferences) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  // END DEBUG
  
  runApp(const ProviderScope(child: VedaHerb()));
}

class VedaHerb extends ConsumerWidget {
  const VedaHerb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state changes for theme and navigation
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Veda',
      debugShowCheckedModeBanner: false,
      theme: VedaTheme.lightTheme,
      darkTheme: VedaTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}
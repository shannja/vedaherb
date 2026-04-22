import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vedaherb/core/router.dart';
import 'package:vedaherb/core/theme.dart';
import 'package:vedaherb/features/settings/application/settings_controller.dart';

class VedaHerbApp extends ConsumerWidget {
  const VedaHerbApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).asData?.value;
    final themeMode = settings?.themeMode ?? ThemeMode.light;
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


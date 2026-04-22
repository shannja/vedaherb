import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vedaherb/app/app.dart';

/// DEBUG ONLY: set true to clear prefs on every launch.
const bool clearPreferencesOnLaunch = false;

Future<void> bootstrapMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (clearPreferencesOnLaunch) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  runApp(const ProviderScope(child: VedaHerbApp()));
}


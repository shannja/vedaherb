import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton `SharedPreferences` instance for the app.
///
/// Keeping this behind a provider makes persistence testable and keeps
/// `SharedPreferences.getInstance()` from being scattered across features.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);


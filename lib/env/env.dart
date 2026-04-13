import 'package:envied/envied.dart';
part 'env.g.dart';

/// This class obfuscates API keys from the '.env' file.
///
/// It encrypts keys into unreadable bytes so that even if the 
/// app is reverse engineered, the API keys remain safe.
///
/// **Usage:**
/// ```dart
/// import 'package:lib/env/env.dart';
/// String geminiKey = Env.geminiKey; // Make sure you have this in your env.dart file from .env.
/// ```
@Envied(path: '.env')
abstract class Env {
  // When the .env file is edited with a new key, this must be edited also.
  // If we will add another key, just add a new setup like this:
  //
  // @EnviedField(varName: 'NEW_API_KEY', obfuscate: true)
  // static final String newNameKey = _Env.newNameKey;
  //
  // Once you edited the .env, and the env.dart file, run this command:
  // dart run build_runner build --delete-conflicting-outputs

  @EnviedField(varName: 'GEMINI_API_KEY', obfuscate: true)
  static final String geminiKey = _Env.geminiKey;
}
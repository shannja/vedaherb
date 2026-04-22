import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vedaherb/features/session/domain/models.dart';
import 'package:vedaherb/features/session/persistence.dart';

class SessionRepository {
  SessionRepository(this._prefs);
  final SharedPreferences _prefs;

  static const String _sessionsKey = 'saved_sessions';

  Future<void> saveSessions(Map<String, SessionData> sessions) async {
    final sessionsMap = <String, String>{};

    for (final entry in sessions.entries) {
      sessionsMap[entry.key] = jsonEncode(entry.value.toJson());
    }

    await _prefs.setString(_sessionsKey, jsonEncode(sessionsMap));
  }

  Map<String, SessionData> loadSessions() {
    final sessionsJson = _prefs.getString(_sessionsKey);
    if (sessionsJson == null) return {};

    final sessionsMap = jsonDecode(sessionsJson) as Map<String, dynamic>;
    final result = <String, SessionData>{};

    for (final entry in sessionsMap.entries) {
      result[entry.key] = SessionDataJson.fromJson(jsonDecode(entry.value));
    }

    return result;
  }

  Future<void> clearSessions() => _prefs.remove(_sessionsKey);
}


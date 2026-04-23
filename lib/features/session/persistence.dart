import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vedaherb/features/session/domain/models.dart';

class SessionPersistence {
  static const String _sessionsKey = 'saved_sessions';
  
  // Save all sessions to SharedPreferences
  static Future<void> saveSessions(Map<String, SessionData> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsMap = <String, String>{};
    
    for (var entry in sessions.entries) {
      sessionsMap[entry.key] = jsonEncode(entry.value.toJson());
    }
    
    await prefs.setString(_sessionsKey, jsonEncode(sessionsMap));
  }
  
  // Load all sessions from SharedPreferences
  static Future<Map<String, SessionData>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString(_sessionsKey);
    
    if (sessionsJson == null) return {};
    
    final sessionsMap = jsonDecode(sessionsJson) as Map<String, dynamic>;
    final result = <String, SessionData>{};
    
    for (var entry in sessionsMap.entries) {
      result[entry.key] = SessionDataJson.fromJson(jsonDecode(entry.value));
    }
    
    return result;
  }
  
  // Clear all sessions (for debugging)
  static Future<void> clearSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
  }
}

// Add toJson/fromJson to SessionData
extension SessionDataJson on SessionData {
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'title': title,
      'entryPoint': entryPoint.index,
      'messages': messages.map((m) => m.toJson()).toList(),
      'identifiedPlant': identifiedPlant,
      'currentState': currentState.index,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  static SessionData fromJson(Map<String, dynamic> json) {
    return SessionData(
      sessionId: json['sessionId'],
      title: json['title'],
      entryPoint: SessionEntryPoint.values[json['entryPoint']],
      messages: (json['messages'] as List)
          .map((m) => ChatMessageJson.fromJson(m))
          .toList(),
      identifiedPlant: json['identifiedPlant'],
      currentState: SessionState.values[json['currentState']],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

// Add toJson/fromJson to SessionChatMessage
extension ChatMessageJson on SessionChatMessage {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      if (localImagePath != null) 'localImagePath': localImagePath,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.index,
    };
  }
  
  static SessionChatMessage fromJson(Map<String, dynamic> json) {
    return SessionChatMessage(
      id: json['id'],
      text: json['text'] as String? ?? '',
      localImagePath: json['localImagePath'] as String?,
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values[json['type']],
    );
  }
}
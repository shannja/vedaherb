import 'package:flutter/foundation.dart';

enum SessionEntryPoint { camera, chat }

enum SessionState {
  cameraFullscreen,
  transitioning,
  chatting,
  suggesting,
  monitoring,
  escalating,
  resolved,
}

enum MessageType { text, plantResult, suggestion, monitoring }

@immutable
class SessionChatMessage {
  final String id;
  final String text;
  /// Absolute path to a locally persisted image (app documents), if any.
  final String? localImagePath;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;

  const SessionChatMessage({
    required this.id,
    this.text = '',
    this.localImagePath,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
  });

  SessionChatMessage copyWith({
    String? id,
    String? text,
    String? localImagePath,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return SessionChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      localImagePath: localImagePath ?? this.localImagePath,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}

@immutable
class SessionData {
  final String sessionId;
  final String title;
  final SessionEntryPoint entryPoint;
  final List<SessionChatMessage> messages;
  final String? identifiedPlant;
  final SessionState currentState;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const SessionData({
    required this.sessionId,
    required this.title,
    required this.entryPoint,
    required this.messages,
    required this.identifiedPlant,
    required this.currentState,
    required this.createdAt,
    required this.lastUpdated,
  });

  SessionData copyWith({
    String? sessionId,
    String? title,
    SessionEntryPoint? entryPoint,
    List<SessionChatMessage>? messages,
    String? identifiedPlant,
    SessionState? currentState,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return SessionData(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      entryPoint: entryPoint ?? this.entryPoint,
      messages: messages ?? this.messages,
      identifiedPlant: identifiedPlant ?? this.identifiedPlant,
      currentState: currentState ?? this.currentState,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vedaherb/features/session/domain/models.dart';

class SessionMessagesNotifier extends Notifier<List<SessionChatMessage>> {
  SessionMessagesNotifier(this.sessionId);
  final String sessionId;

  @override
  List<SessionChatMessage> build() => const [];

  void setAll(List<SessionChatMessage> next) => state = next;
  void add(SessionChatMessage message) => state = [...state, message];
}

class SessionIdentifiedPlantNotifier extends Notifier<String?> {
  SessionIdentifiedPlantNotifier(this.sessionId);
  final String sessionId;

  @override
  String? build() => null;

  void setPlant(String? next) => state = next;
}

class SessionStateNotifier extends Notifier<SessionState> {
  SessionStateNotifier(this.sessionId);
  final String sessionId;

  @override
  SessionState build() => SessionState.cameraFullscreen;

  void setStateValue(SessionState next) => state = next;
}

final sessionMessagesProvider = NotifierProvider.family<SessionMessagesNotifier, List<SessionChatMessage>, String>(SessionMessagesNotifier.new);

final sessionIdentifiedPlantProvider = NotifierProvider.family<SessionIdentifiedPlantNotifier, String?, String>(SessionIdentifiedPlantNotifier.new);

final sessionStateProviderFamily = NotifierProvider.family<SessionStateNotifier, SessionState, String>(SessionStateNotifier.new);
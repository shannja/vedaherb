import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vedaherb/core/persistence/shared_prefs.dart';
import 'package:vedaherb/features/session/data/session_repository.dart';
import 'package:vedaherb/features/session/domain/models.dart';

final allSessionsControllerProvider =
    AsyncNotifierProvider<AllSessionsController, Map<String, SessionData>>(
  AllSessionsController.new,
);

class AllSessionsController extends AsyncNotifier<Map<String, SessionData>> {
  SessionRepository? _repo;

  @override
  Future<Map<String, SessionData>> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    _repo = SessionRepository(prefs);
    return _repo!.loadSessions();
  }

  Future<void> saveSession(SessionData session) async {
    final current = state.asData?.value ?? {};
    final next = {...current, session.sessionId: session};
    state = AsyncData(next);
    await _repo?.saveSessions(next);
  }

  Future<void> removeSession(String sessionId) async {
    final current = state.asData?.value ?? {};
    final next = {...current}..remove(sessionId);
    state = AsyncData(next);
    await _repo?.saveSessions(next);
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_models.dart';
import '../services/challenge_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';

// ── State ────────────────────────────────────────────────────────────────

class ChallengeState {
  final List<ChallengeDto> incoming;
  final List<ChallengeDto> outgoing;
  final List<ChallengeDto> history;
  final bool isLoading;
  final String? error;

  const ChallengeState({
    this.incoming = const [],
    this.outgoing = const [],
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  ChallengeState copyWith({
    List<ChallengeDto>? incoming,
    List<ChallengeDto>? outgoing,
    List<ChallengeDto>? history,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => ChallengeState(
    incoming: incoming ?? this.incoming,
    outgoing: outgoing ?? this.outgoing,
    history: history ?? this.history,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

// ── Notifier ─────────────────────────────────────────────────────────────

class ChallengeNotifier extends StateNotifier<ChallengeState> {
  final ChallengeService _service;
  final Ref _ref;

  ChallengeNotifier(this._service, this._ref) : super(const ChallengeState());

  String? get _childId => _ref.read(selectedChildProvider)?.id;

  /// Tüm listeleri yenile (Gelen + Gönderilen + Geçmiş).
  Future<void> loadAll() async {
    final childId = _childId;
    if (childId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.getIncoming(childId),
        _service.getOutgoing(childId),
        _service.getHistory(childId),
      ]);
      state = state.copyWith(
        incoming: results[0],
        outgoing: results[1],
        history: results[2],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Arkadaşa meydan okuma gönderir; başarıda outgoing'e ekler.
  Future<ChallengeDto?> sendChallenge({
    required String challengeeId,
    String? levelId,
    int? competitionType,
    String? competitionTopicKey,
    String competitionDifficulty = 'Orta',
  }) async {
    final challengerId = _childId;
    if (challengerId == null) return null;

    try {
      final dto = await _service.sendChallenge(
        challengerId: challengerId,
        challengeeId: challengeeId,
        levelId: levelId,
        competitionType: competitionType,
        competitionTopicKey: competitionTopicKey,
        competitionDifficulty: competitionDifficulty,
      );
      state = state.copyWith(outgoing: [dto, ...state.outgoing]);
      return dto;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> acceptChallenge(String challengeId) async {
    final childId = _childId;
    if (childId == null) return;
    try {
      final updated = await _service.acceptChallenge(challengeId, childId);
      _replaceIncoming(updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> declineChallenge(String challengeId) async {
    final childId = _childId;
    if (childId == null) return;
    try {
      final updated = await _service.declineChallenge(challengeId, childId);
      _replaceIncoming(updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<ChallengeDto?> submitScore(String challengeId, int score) async {
    final childId = _childId;
    if (childId == null) return null;
    try {
      final updated = await _service.submitScore(challengeId, childId, score);
      // Tamamlandıysa geçmişe taşı, aksi hâlde outgoing/incoming'de güncelle.
      if (updated.status.isFinished) {
        state = state.copyWith(
          incoming: state.incoming.where((c) => c.id != challengeId).toList(),
          outgoing: state.outgoing.where((c) => c.id != challengeId).toList(),
          history: [updated, ...state.history],
        );
      } else {
        _replaceInLists(updated);
      }
      return updated;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  void _replaceIncoming(ChallengeDto updated) {
    state = state.copyWith(
      incoming: state.incoming
          .map((c) => c.id == updated.id ? updated : c)
          .toList(),
    );
  }

  void _replaceInLists(ChallengeDto updated) {
    state = state.copyWith(
      incoming: state.incoming
          .map((c) => c.id == updated.id ? updated : c)
          .toList(),
      outgoing: state.outgoing
          .map((c) => c.id == updated.id ? updated : c)
          .toList(),
    );
  }

  void clearError() => state = state.copyWith(clearError: true);

  /// Challengee'ye hatırlatma push bildirimi gönderir (4 saat cooldown).
  Future<ChallengeDto?> remindChallenge(String challengeId) async {
    final challengerId = _childId;
    if (challengerId == null) return null;
    try {
      final updated = await _service.remindChallenge(challengeId, challengerId);
      _replaceInLists(updated);
      return updated;
    } catch (e) {
      rethrow;
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────

final challengeNotifierProvider =
    StateNotifierProvider<ChallengeNotifier, ChallengeState>(
      (ref) => ChallengeNotifier(ref.watch(challengeServiceProvider), ref),
    );

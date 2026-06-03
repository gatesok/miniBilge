import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_models.dart';
import '../services/match_service.dart';
import '../services/match_hub_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';

// Import service providers
import '../services/match_service.dart' show matchServiceProvider;
import '../services/match_hub_service.dart' show matchHubServiceProvider;

/// Match state
class MatchState {
  final MatchStatus status;
  final MatchSession? currentMatch;
  final String? error;
  final int currentQuestionIndex;
  final List<MatchHistoryItem> history;
  final MatchStats? stats;
  final bool hasAnsweredCurrentQuestion;
  final String? myChildProfileId;
  final int timePerQuestion;

  const MatchState({
    this.status = MatchStatus.idle,
    this.currentMatch,
    this.error,
    this.currentQuestionIndex = 0,
    this.history = const [],
    this.stats,
    this.hasAnsweredCurrentQuestion = false,
    this.myChildProfileId,
    this.timePerQuestion = 45,
  });

  MatchState copyWith({
    MatchStatus? status,
    MatchSession? currentMatch,
    String? error,
    int? currentQuestionIndex,
    List<MatchHistoryItem>? history,
    MatchStats? stats,
    bool? hasAnsweredCurrentQuestion,
    String? myChildProfileId,
    int? timePerQuestion,
  }) {
    return MatchState(
      status: status ?? this.status,
      currentMatch: currentMatch ?? this.currentMatch,
      error: error ?? this.error,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      history: history ?? this.history,
      stats: stats ?? this.stats,
      hasAnsweredCurrentQuestion: hasAnsweredCurrentQuestion ?? this.hasAnsweredCurrentQuestion,
      myChildProfileId: myChildProfileId ?? this.myChildProfileId,
      timePerQuestion: timePerQuestion ?? this.timePerQuestion,
    );
  }

  /// Get current participant (the player) - matched by selected child profile
  MatchParticipant? get myParticipant {
    if (currentMatch == null || currentMatch!.participants.isEmpty) return null;
    if (myChildProfileId != null) {
      final found = currentMatch!.participants
          .where((p) => p.childProfileId == myChildProfileId)
          .toList();
      if (found.isNotEmpty) return found.first;
    }
    return currentMatch!.participants.first;
  }

  /// Get opponent participant
  MatchParticipant? get opponent {
    if (currentMatch == null || currentMatch!.participants.length < 2) return null;
    if (myChildProfileId != null) {
      final found = currentMatch!.participants
          .where((p) => p.childProfileId != myChildProfileId)
          .toList();
      if (found.isNotEmpty) return found.first;
    }
    return currentMatch!.participants.last;
  }

  /// Get current question
  MatchQuestion? get currentQuestion {
    if (currentMatch == null ||
        currentQuestionIndex >= currentMatch!.questions.length) {
      return null;
    }
    return currentMatch!.questions[currentQuestionIndex];
  }
}

/// Match status enum
enum MatchStatus {
  idle,
  searchingOpponent,
  matchFound,
  inMatch,
  completed,
  error,
}

/// Match provider
class MatchNotifier extends StateNotifier<MatchState> {
  final MatchService _matchService;
  final MatchHubService _hubService;
  final Ref _ref;

  MatchNotifier(this._matchService, this._hubService, this._ref)
      : super(const MatchState()) {
    _initializeHubListeners();
  }

  /// Initialize SignalR hub listeners
  void _initializeHubListeners() {
    _hubService.matchFound.listen((match) {
      state = state.copyWith(
        status: MatchStatus.matchFound,
        currentMatch: match,
        currentQuestionIndex: 0,
      );
    });

    _hubService.opponentAnswered.listen((event) {
      // Update the score of whoever answered (identified by answeredByChildId)
      if (state.currentMatch != null && event.answeredByChildId != null) {
        final updatedParticipants = state.currentMatch!.participants.map((p) {
          if (p.childProfileId == event.answeredByChildId) {
            return p.copyWith(score: event.newScore);
          }
          return p;
        }).toList();
        state = state.copyWith(
          currentMatch: state.currentMatch!.copyWith(participants: updatedParticipants),
        );
      }
    });

    _hubService.opponentLeft.listen((_) async {
      // Set completed immediately so UI navigates without waiting for API
      final matchId = state.currentMatch?.id;
      state = state.copyWith(status: MatchStatus.completed);
      // Refresh match data in background so result screen shows correct winner/score
      if (matchId != null) {
        try {
          final (fresh, _) = await _matchService.getMatch(matchId);
          state = state.copyWith(currentMatch: fresh);
        } catch (_) {
          // result screen calls refreshMatch on load
        }
      }
    });

    _hubService.matchCompleted.listen((matchId) {
      state = state.copyWith(
        status: MatchStatus.completed,
      );
    });

    _hubService.answerSubmitted.listen((event) {
      // Update myParticipant's score after answer submission
      if (state.currentMatch != null && state.myChildProfileId != null) {
        final updatedParticipants = state.currentMatch!.participants.map((p) {
          if (p.childProfileId == state.myChildProfileId) {
            return p.copyWith(score: event.newScore);
          }
          return p;
        }).toList();
        state = state.copyWith(
          currentMatch: state.currentMatch!.copyWith(participants: updatedParticipants),
        );
      }
    });

    _hubService.error.listen((message) {
      state = state.copyWith(
        status: MatchStatus.error,
        error: message,
      );
    });

    _hubService.questionAdvance.listen((questionOrder) {
      // Both players answered - advance to next question
      final nextIndex = state.currentQuestionIndex + 1;
      if (state.currentMatch != null &&
          nextIndex < state.currentMatch!.questions.length) {
        state = state.copyWith(
          currentQuestionIndex: nextIndex,
          hasAnsweredCurrentQuestion: false,
        );
      }
    });
  }

  /// Request a match opponent
  Future<void> requestMatch() async {
    try {
      final selectedChild = _ref.read(selectedChildProvider);
      if (selectedChild == null) {
        state = state.copyWith(
          status: MatchStatus.error,
          error: 'No child profile selected',
        );
        return;
      }

      state = state.copyWith(
        status: MatchStatus.searchingOpponent,
        myChildProfileId: selectedChild.id,  // store at request time
      );
      
      // Connect to hub if not already connected
      await _hubService.connect();
      
      await _matchService.requestMatch(selectedChild.id);
      // Wait for MatchFound event from SignalR
    } catch (e) {
      state = state.copyWith(
        status: MatchStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Cancel match request
  Future<void> cancelMatchRequest() async {
    try {
      final selectedChild = _ref.read(selectedChildProvider);
      if (selectedChild == null) return;

      await _matchService.cancelMatchRequest(selectedChild.id);
      state = state.copyWith(status: MatchStatus.idle);
    } catch (e) {
      state = state.copyWith(
        status: MatchStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Join a match session
  Future<void> joinMatch(String matchId) async {
    try {
      final (fullMatch, tpq) = await _matchService.getMatch(matchId);
      final selectedChild = _ref.read(selectedChildProvider);
      state = state.copyWith(
        status: MatchStatus.inMatch,
        currentMatch: fullMatch,
        currentQuestionIndex: 0,
        hasAnsweredCurrentQuestion: false,
        timePerQuestion: tpq,
        // Prefer already-stored ID (from requestMatch), fall back to selectedChild
        myChildProfileId: state.myChildProfileId ?? selectedChild?.id,
      );
      final childId = state.myChildProfileId ?? selectedChild?.id ?? '';
      await _hubService.joinMatch(matchId, childId);
    } catch (e, st) {
      state = state.copyWith(
        status: MatchStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Submit an answer
  Future<void> submitAnswer(String answer) async {
    if (state.currentMatch == null || state.currentQuestion == null) return;

    try {
      final questionIndexBefore = state.currentQuestionIndex;
      await _hubService.submitAnswer(
        state.currentMatch!.id,
        state.currentQuestion!.questionId,
        answer,
        state.myParticipant!.childProfileId,
      );
      // Only lock if QuestionAdvance hasn't already advanced us to next question
      if (state.currentQuestionIndex == questionIndexBefore) {
        state = state.copyWith(hasAnsweredCurrentQuestion: true);
      }
    } catch (e) {
      state = state.copyWith(
        status: MatchStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Leave the current match
  Future<void> leaveMatch() async {
    if (state.currentMatch == null) return;

    try {
      await _hubService.leaveMatch(state.currentMatch!.id);
      state = state.copyWith(
        status: MatchStatus.idle,
        currentMatch: null,
        currentQuestionIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(
        status: MatchStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Refresh match data from backend (used on result screen to get winnerId)
  Future<void> refreshMatch(String matchId) async {
    try {
      final (freshMatch, _) = await _matchService.getMatch(matchId);
      state = state.copyWith(currentMatch: freshMatch);
    } catch (_) {
      // Silently ignore - result screen still shows with existing state
    }
  }

  /// Load match history
  Future<void> loadHistory(String childId) async {
    if (childId.isEmpty) return;
    try {
      final history = await _matchService.getMatchHistory(childId);
      state = state.copyWith(history: history);
      final stats = await _matchService.getMatchStats(childId);
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(
        status: MatchStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Load match statistics
  Future<void> loadStats(String childId) async {
    try {
      final stats = await _matchService.getMatchStats(childId);
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(
        status: MatchStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Reset state
  void reset() {
    state = const MatchState();
  }
}

/// Match provider instance
final matchProvider = StateNotifierProvider<MatchNotifier, MatchState>((ref) {
  final matchService = ref.read(matchServiceProvider);
  final hubService = ref.read(matchHubServiceProvider);
  
  return MatchNotifier(matchService, hubService, ref);
});

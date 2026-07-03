import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/match_models.dart';

/// Match API service for REST endpoints
class MatchService {
  final Dio _dio;

  MatchService(this._dio);

  /// Request a match opponent
  Future<void> requestMatch(String childId, {String? subjectId}) async {
    await _dio.post('/match/request', data: {
      'childId': childId,
      if (subjectId != null) 'subjectId': subjectId,
    });
  }

  /// Cancel match request
  Future<void> cancelMatchRequest(String childId) async {
    await _dio.delete('/match/request?childId=$childId');
  }

  /// Get match details by ID
  /// Returns a record of (MatchSession, timePerQuestion)
  Future<(MatchSession, int)> getMatch(String matchId) async {
    final response = await _dio.get('/match/$matchId');
    final data = response.data as Map<String, dynamic>;

    // Backend returns MatchSessionDto with PascalCase keys (Player1, Player2, Questions)
    final player1 = data['Player1'] as Map<String, dynamic>?;
    final player2 = data['Player2'] as Map<String, dynamic>?;
    final matchSessionId = data['Id']?.toString() ?? matchId;
    final timePerQuestion = (data['TimePerQuestion'] as num?)?.toInt() ?? 45;

    final participants = <MatchParticipant>[];
    if (player1 != null) {
      participants.add(MatchParticipant(
        id: (player1['ChildId'] ?? '').toString(),
        matchSessionId: matchSessionId,
        childProfileId: (player1['ChildId'] ?? '').toString(),
        childName: (player1['Name'] ?? '').toString(),
        score: (player1['Score'] as num?)?.toInt() ?? 0,
        joinedAt: DateTime.now(),
        isReady: true,
        avatarImageUrl: player1['AvatarImageUrl'] as String?,
        avatarId: null,
      ));
    }
    if (player2 != null) {
      participants.add(MatchParticipant(
        id: (player2['ChildId'] ?? '').toString(),
        matchSessionId: matchSessionId,
        childProfileId: (player2['ChildId'] ?? '').toString(),
        childName: (player2['Name'] ?? '').toString(),
        score: (player2['Score'] as num?)?.toInt() ?? 0,
        joinedAt: DateTime.now(),
        isReady: true,
        avatarImageUrl: player2['AvatarImageUrl'] as String?,
        avatarId: null,
      ));
    }

    final rawQuestions = data['Questions'] as List<dynamic>? ?? [];
    final questions = rawQuestions.asMap().entries.map((entry) {
      final qMap = entry.value as Map<String, dynamic>;
      final options = (qMap['Options'] as List<dynamic>? ?? [])
          .map((o) {
            final oMap = o as Map<String, dynamic>;
            return (oMap['OptionText'] ?? '').toString();
          })
          .toList();
      return MatchQuestion(
        id: qMap['Id']?.toString() ?? '',
        matchSessionId: matchSessionId,
        questionId: qMap['Id']?.toString() ?? '',
        questionOrder: entry.key,
        questionText: qMap['QuestionText']?.toString() ?? '',
        correctAnswer: '',
        options: options,
      );
    }).toList();

    final statusStr = data['Status']?.toString() ?? 'Created';
    final status = MatchSessionStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == statusStr.toLowerCase(),
      orElse: () => MatchSessionStatus.created,
    );

    return (MatchSession(
      id: matchSessionId,
      status: status,
      startedAt: data['StartedAt'] != null
          ? DateTime.parse(data['StartedAt'])
          : DateTime.now(),
      endedAt: data['EndedAt'] != null
          ? DateTime.parse(data['EndedAt'])
          : null,
      winnerId: data['Winner'] != null
          ? (data['Winner'] as Map<String, dynamic>)['ChildId']?.toString()
          : null,
      participants: participants,
      questions: questions,
    ), timePerQuestion);
  }

  /// Get match history for current child
  Future<List<MatchHistoryItem>> getMatchHistory(String childId) async {
    final response = await _dio.get('/match/history?childId=$childId');
    final myChildId = childId.toLowerCase();
    return (response.data as List).map((item) {
      final map = item as Map<String, dynamic>;
      final player1 = map['Player1'] as Map<String, dynamic>?;
      final player2 = map['Player2'] as Map<String, dynamic>?;
      final winner = map['Winner'] as Map<String, dynamic>?;

      final p1Id = player1?['ChildId']?.toString().toLowerCase() ?? '';
      final isMe1 = p1Id == myChildId;
      final me = isMe1 ? player1! : (player2 ?? player1!);
      final opp = isMe1 ? (player2 ?? player1!) : player1!;

      final winnerId = winner?['ChildId']?.toString().toLowerCase();
      final isDraw = winnerId == null;
      final isWinner = !isDraw && winnerId == myChildId;

      return MatchHistoryItem(
        matchSessionId: map['Id']?.toString() ?? '',
        playedAt: map['EndedAt'] != null
            ? DateTime.parse(map['EndedAt'])
            : (map['StartedAt'] != null
                ? DateTime.parse(map['StartedAt'])
                : DateTime.now()),
        opponentName: opp['Name']?.toString() ?? '',
        opponentAvatarId: null,
        opponentAvatarUrl: opp['AvatarImageUrl'] as String?,
        myScore: (me['Score'] as num?)?.toInt() ?? 0,
        opponentScore: (opp['Score'] as num?)?.toInt() ?? 0,
        isWinner: isWinner,
        isDraw: isDraw,
      );
    }).toList();
  }

  /// Get match statistics for a child
  Future<MatchStats> getMatchStats(String childId) async {
    final response = await _dio.get('/match/stats/$childId');
    return MatchStats.fromJson(response.data);
  }
}

/// Match service provider
final matchServiceProvider = Provider<MatchService>((ref) {
  final dio = ref.read(dioProvider);
  return MatchService(dio);
});

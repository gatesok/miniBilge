import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_models.freezed.dart';
part 'match_models.g.dart';

/// Match request status enum
enum MatchRequestStatus {
  @JsonValue('Waiting')
  waiting,
  @JsonValue('Matched')
  matched,
  @JsonValue('Expired')
  expired,
  @JsonValue('Cancelled')
  cancelled,
}

/// Match session status enum
enum MatchSessionStatus {
  @JsonValue('Created')
  created,
  @JsonValue('InProgress')
  inProgress,
  @JsonValue('Completed')
  completed,
  @JsonValue('Abandoned')
  abandoned,
}

/// Match request model
@freezed
class MatchRequest with _$MatchRequest {
  const factory MatchRequest({
    required String id,
    required String childProfileId,
    required MatchRequestStatus status,
    required DateTime requestedAt,
    DateTime? matchedAt,
    String? matchSessionId,
  }) = _MatchRequest;

  factory MatchRequest.fromJson(Map<String, dynamic> json) =>
      _$MatchRequestFromJson(json);
}

/// Match session model
@freezed
class MatchSession with _$MatchSession {
  const factory MatchSession({
    required String id,
    required DateTime startedAt,
    DateTime? endedAt,
    required MatchSessionStatus status,
    String? winnerId,
    required List<MatchParticipant> participants,
    required List<MatchQuestion> questions,
  }) = _MatchSession;

  factory MatchSession.fromJson(Map<String, dynamic> json) =>
      _$MatchSessionFromJson(json);
}

/// Match participant model
@freezed
class MatchParticipant with _$MatchParticipant {
  const factory MatchParticipant({
    required String id,
    required String matchSessionId,
    required String childProfileId,
    required String childName,
    required int score,
    required DateTime joinedAt,
    required bool isReady,
    String? avatarImageUrl,
    int? avatarId,
  }) = _MatchParticipant;

  factory MatchParticipant.fromJson(Map<String, dynamic> json) =>
      _$MatchParticipantFromJson(json);
}

/// Match question model
@freezed
class MatchQuestion with _$MatchQuestion {
  const factory MatchQuestion({
    required String id,
    required String matchSessionId,
    required String questionId,
    required int questionOrder,
    required String questionText,
    required String correctAnswer,
    required List<String> options,
  }) = _MatchQuestion;

  factory MatchQuestion.fromJson(Map<String, dynamic> json) =>
      _$MatchQuestionFromJson(json);
}

/// Match answer model
@freezed
class MatchAnswer with _$MatchAnswer {
  const factory MatchAnswer({
    required String id,
    required String matchSessionId,
    required String participantId,
    required String questionId,
    required String answer,
    required bool isCorrect,
    required DateTime answeredAt,
    required int pointsEarned,
  }) = _MatchAnswer;

  factory MatchAnswer.fromJson(Map<String, dynamic> json) =>
      _$MatchAnswerFromJson(json);
}

/// Match statistics model
@freezed
class MatchStats with _$MatchStats {
  const factory MatchStats({
    required String childId,
    required int gamesPlayed,
    required int gamesWon,
    required int gamesLost,
    required int totalScore,
    required double averageScore,
    required double winRate,
  }) = _MatchStats;

  factory MatchStats.fromJson(Map<String, dynamic> json) =>
      _$MatchStatsFromJson(json);
}

/// Match history item model (for list view)
@freezed
class MatchHistoryItem with _$MatchHistoryItem {
  const factory MatchHistoryItem({
    required String matchSessionId,
    required DateTime playedAt,
    required String opponentName,
    int? opponentAvatarId,
    required int myScore,
    required int opponentScore,
    required bool isWinner,
    @Default(false) bool isDraw,
  }) = _MatchHistoryItem;

  factory MatchHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$MatchHistoryItemFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'roleplay_models.freezed.dart';
part 'roleplay_models.g.dart';

// ─── Senaryo ─────────────────────────────────────────────────────────────────

@freezed
class ScenarioDto with _$ScenarioDto {
  const factory ScenarioDto({
    @JsonKey(name: 'Key') required String key,
    @JsonKey(name: 'Title') required String title,
    @JsonKey(name: 'Description') required String description,
    @JsonKey(name: 'Level') required String level,
    @JsonKey(name: 'CharacterName') required String characterName,
    @JsonKey(name: 'CharacterRole') required String characterRole,
    @JsonKey(name: 'Emoji') required String emoji,
  }) = _ScenarioDto;

  factory ScenarioDto.fromJson(Map<String, dynamic> json) =>
      _$ScenarioDtoFromJson(json);
}

// ─── Oturum Başlatma ─────────────────────────────────────────────────────────

@freezed
class StartRolePlayResponse with _$StartRolePlayResponse {
  const factory StartRolePlayResponse({
    @JsonKey(name: 'SessionId') required String sessionId,
    @JsonKey(name: 'AssistantMessage') required String assistantMessage,
    @JsonKey(name: 'CharacterName') required String characterName,
    @JsonKey(name: 'CharacterRole') required String characterRole,
    @JsonKey(name: 'ScenarioTitle') required String scenarioTitle,
    @JsonKey(name: 'Emoji') required String emoji,
  }) = _StartRolePlayResponse;

  factory StartRolePlayResponse.fromJson(Map<String, dynamic> json) =>
      _$StartRolePlayResponseFromJson(json);
}

// ─── Tur Yanıtı ──────────────────────────────────────────────────────────────

@freezed
class SendTurnResponse with _$SendTurnResponse {
  const factory SendTurnResponse({
    @JsonKey(name: 'AssistantMessage') required String assistantMessage,
    @JsonKey(name: 'GrammarNote') String? grammarNote,
    @JsonKey(name: 'TurnCount') required int turnCount,
    @JsonKey(name: 'MaxTurnsReached') @Default(false) bool maxTurnsReached,
  }) = _SendTurnResponse;

  factory SendTurnResponse.fromJson(Map<String, dynamic> json) =>
      _$SendTurnResponseFromJson(json);
}

// ─── İyileştirme İpucu ───────────────────────────────────────────────────────

@freezed
class ImprovementHint with _$ImprovementHint {
  const factory ImprovementHint({
    @JsonKey(name: 'Area') required String area,
    @JsonKey(name: 'Issue') required String issue,
    @JsonKey(name: 'IssueTr') @Default('') String issueTr,
    @JsonKey(name: 'Suggestion') required String suggestion,
    @JsonKey(name: 'SuggestionTr') @Default('') String suggestionTr,
  }) = _ImprovementHint;

  factory ImprovementHint.fromJson(Map<String, dynamic> json) =>
      _$ImprovementHintFromJson(json);
}

// ─── Oturum Sonu ─────────────────────────────────────────────────────────────

@freezed
class EndSessionResponse with _$EndSessionResponse {
  const factory EndSessionResponse({
    @JsonKey(name: 'Score') required int score,
    @JsonKey(name: 'Feedback') required String feedback,
    @JsonKey(name: 'FeedbackTr') @Default('') String feedbackTr,
    @JsonKey(name: 'Improvements') @Default([]) List<ImprovementHint> improvements,
    @JsonKey(name: 'TurnCount') required int turnCount,
    @JsonKey(name: 'CoinsEarned') @Default(0) int coinsEarned,
    @JsonKey(name: 'StarsEarned') @Default(0) int starsEarned,
  }) = _EndSessionResponse;

  factory EndSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$EndSessionResponseFromJson(json);
}

// ─── Chat Mesajı (Yerel model — API'ye gönderilmez) ──────────────────────────

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String role,       // 'user' | 'assistant'
    required String content,
    String? grammarNote,
    required DateTime createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

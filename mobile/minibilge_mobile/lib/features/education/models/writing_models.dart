import 'package:freezed_annotation/freezed_annotation.dart';

part 'writing_models.freezed.dart';
part 'writing_models.g.dart';

// ─── Prompt ──────────────────────────────────────────────────────────────────

@freezed
class WritingPrompt with _$WritingPrompt {
  const factory WritingPrompt({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'PromptText') required String promptText,
    @JsonKey(name: 'Context') String? context,
  }) = _WritingPrompt;

  factory WritingPrompt.fromJson(Map<String, dynamic> json) =>
      _$WritingPromptFromJson(json);
}

// ─── Correction ──────────────────────────────────────────────────────────────

@freezed
class WritingCorrection with _$WritingCorrection {
  const factory WritingCorrection({
    @JsonKey(name: 'Original') required String original,
    @JsonKey(name: 'Suggestion') required String suggestion,
    @JsonKey(name: 'Explanation') required String explanation,
    @JsonKey(name: 'ExplanationTr') @Default('') String explanationTr,
  }) = _WritingCorrection;

  factory WritingCorrection.fromJson(Map<String, dynamic> json) =>
      _$WritingCorrectionFromJson(json);
}

// ─── Evaluation Result ───────────────────────────────────────────────────────

@freezed
class WritingEvaluationResult with _$WritingEvaluationResult {
  const factory WritingEvaluationResult({
    @JsonKey(name: 'Score') required int score,
    @JsonKey(name: 'Corrections') required List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') required String feedback,
    @JsonKey(name: 'FeedbackTr') @Default('') String feedbackTr,
    @JsonKey(name: 'CoinsEarned') required int coinsEarned,
    @JsonKey(name: 'StarsEarned') required int starsEarned,
  }) = _WritingEvaluationResult;

  factory WritingEvaluationResult.fromJson(Map<String, dynamic> json) =>
      _$WritingEvaluationResultFromJson(json);
}

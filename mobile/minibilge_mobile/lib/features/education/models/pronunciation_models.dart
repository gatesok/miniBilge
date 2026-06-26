import 'package:freezed_annotation/freezed_annotation.dart';

part 'pronunciation_models.freezed.dart';
part 'pronunciation_models.g.dart';

// ─── Word Result ─────────────────────────────────────────────────────────────

@freezed
class WordResult with _$WordResult {
  const factory WordResult({
    @JsonKey(name: 'Word') required String word,
    @JsonKey(name: 'IsCorrect') required bool isCorrect,
    @JsonKey(name: 'Hint') String? hint,
  }) = _WordResult;

  factory WordResult.fromJson(Map<String, dynamic> json) =>
      _$WordResultFromJson(json);
}

// ─── Pronunciation Result ────────────────────────────────────────────────────

@freezed
class PronunciationResult with _$PronunciationResult {
  const factory PronunciationResult({
    @JsonKey(name: 'Words') required List<WordResult> words,
    @JsonKey(name: 'OverallScore') required int overallScore,
  }) = _PronunciationResult;

  factory PronunciationResult.fromJson(Map<String, dynamic> json) =>
      _$PronunciationResultFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'writing_models.dart';

part 'vocab_challenge_models.freezed.dart';
part 'vocab_challenge_models.g.dart';

// ─── Görev ───────────────────────────────────────────────────────────────────

@freezed
class VocabChallengeTask with _$VocabChallengeTask {
  const factory VocabChallengeTask({
    @JsonKey(name: 'Task') required String task,
    @JsonKey(name: 'TargetWords') required List<String> targetWords,
  }) = _VocabChallengeTask;

  factory VocabChallengeTask.fromJson(Map<String, dynamic> json) =>
      _$VocabChallengeTaskFromJson(json);
}

// ─── Değerlendirme Sonucu ─────────────────────────────────────────────────────

@freezed
class VocabChallengeResult with _$VocabChallengeResult {
  const factory VocabChallengeResult({
    @JsonKey(name: 'Score') required int score,
    /// Her hedef kelimenin doğru kullanılıp kullanılmadığı: {"explore": true, "happy": false}
    @JsonKey(name: 'TargetWordUsage') required Map<String, bool> targetWordUsage,
    @JsonKey(name: 'Corrections') required List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') required String feedback,
    @JsonKey(name: 'CoinsEarned') @Default(0) int coinsEarned,
    @JsonKey(name: 'StarsEarned') @Default(0) int starsEarned,
  }) = _VocabChallengeResult;

  factory VocabChallengeResult.fromJson(Map<String, dynamic> json) =>
      _$VocabChallengeResultFromJson(json);
}

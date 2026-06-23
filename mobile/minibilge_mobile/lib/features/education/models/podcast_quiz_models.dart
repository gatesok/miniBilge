import 'package:freezed_annotation/freezed_annotation.dart';

part 'podcast_quiz_models.freezed.dart';
part 'podcast_quiz_models.g.dart';

enum PodcastQuestionType {
  multipleChoice(1),
  trueFalse(2),
  vocabularyMeaning(3);

  const PodcastQuestionType(this.value);
  final int value;

  static PodcastQuestionType fromValue(int v) =>
      PodcastQuestionType.values.firstWhere(
        (e) => e.value == v,
        orElse: () => PodcastQuestionType.multipleChoice,
      );
}

@freezed
class PodcastQuizOption with _$PodcastQuizOption {
  const factory PodcastQuizOption({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'OptionText') required String optionText,
    @JsonKey(name: 'DisplayOrder') required int displayOrder,
  }) = _PodcastQuizOption;

  factory PodcastQuizOption.fromJson(Map<String, dynamic> json) =>
      _$PodcastQuizOptionFromJson(json);
}

@freezed
class PodcastQuizQuestion with _$PodcastQuizQuestion {
  const factory PodcastQuizQuestion({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'QuestionText') required String questionText,
    @JsonKey(name: 'QuestionType') required int questionType,
    @JsonKey(name: 'DisplayOrder') required int displayOrder,
    @JsonKey(name: 'Options') required List<PodcastQuizOption> options,
  }) = _PodcastQuizQuestion;

  factory PodcastQuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$PodcastQuizQuestionFromJson(json);
}

@freezed
class PodcastQuizAnswerResult with _$PodcastQuizAnswerResult {
  const factory PodcastQuizAnswerResult({
    @JsonKey(name: 'QuestionId') required String questionId,
    @JsonKey(name: 'IsCorrect') required bool isCorrect,
    @JsonKey(name: 'CorrectAnswer') required String correctAnswer,
    @JsonKey(name: 'Explanation') String? explanation,
  }) = _PodcastQuizAnswerResult;

  factory PodcastQuizAnswerResult.fromJson(Map<String, dynamic> json) =>
      _$PodcastQuizAnswerResultFromJson(json);
}

@freezed
class PodcastQuizResult with _$PodcastQuizResult {
  const factory PodcastQuizResult({
    @JsonKey(name: 'CorrectCount') required int correctCount,
    @JsonKey(name: 'TotalQuestions') required int totalQuestions,
    @JsonKey(name: 'StarsEarned') required int starsEarned,
    @JsonKey(name: 'CoinsEarned') required int coinsEarned,
    @JsonKey(name: 'IsFirstCompletion') required bool isFirstCompletion,
    @JsonKey(name: 'AnswerResults') required List<PodcastQuizAnswerResult> answerResults,
  }) = _PodcastQuizResult;

  factory PodcastQuizResult.fromJson(Map<String, dynamic> json) =>
      _$PodcastQuizResultFromJson(json);
}

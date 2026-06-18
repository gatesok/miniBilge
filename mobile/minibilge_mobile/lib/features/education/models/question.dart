import 'package:freezed_annotation/freezed_annotation.dart';
import 'question_option.dart';

part 'question.freezed.dart';
part 'question.g.dart';

enum QuestionType {
  @JsonValue(0)
  multipleChoice,
  @JsonValue(1)
  trueFalse,
  @JsonValue(2)
  numericInput,
}

@freezed
class Question with _$Question {
  const factory Question({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'LevelId') required String levelId,
    @JsonKey(name: 'QuestionText') required String questionText,
    @JsonKey(name: 'QuestionType') required QuestionType questionType,
    @JsonKey(name: 'Explanation') String? explanation,
    @JsonKey(name: 'Options') @Default([]) List<QuestionOption> options,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

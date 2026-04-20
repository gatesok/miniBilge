import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_option.freezed.dart';
part 'question_option.g.dart';

@freezed
class QuestionOption with _$QuestionOption {
  const factory QuestionOption({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'OptionText') required String optionText,
    @JsonKey(name: 'DisplayOrder') required int displayOrder,
  }) = _QuestionOption;

  factory QuestionOption.fromJson(Map<String, dynamic> json) =>
      _$QuestionOptionFromJson(json);
}

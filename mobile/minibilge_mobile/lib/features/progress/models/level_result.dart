import 'package:freezed_annotation/freezed_annotation.dart';

part 'level_result.freezed.dart';
part 'level_result.g.dart';

@freezed
class LevelResult with _$LevelResult {
  const factory LevelResult({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'LevelId') required String levelId,
    @JsonKey(name: 'Score') required int score,
    @JsonKey(name: 'Stars') required int stars,
    @JsonKey(name: 'CorrectCount') required int correctCount,
    @JsonKey(name: 'TotalQuestions') required int totalQuestions,
    @JsonKey(name: 'SuccessPercentage') required double successPercentage,
    @JsonKey(name: 'IsUnlocked') required bool isUnlocked,
    @JsonKey(name: 'CompletedAt') String? completedAt,
  }) = _LevelResult;

  factory LevelResult.fromJson(Map<String, dynamic> json) =>
      _$LevelResultFromJson(json);
}

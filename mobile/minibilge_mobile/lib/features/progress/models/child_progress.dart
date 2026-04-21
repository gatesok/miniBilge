import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_progress.freezed.dart';
part 'child_progress.g.dart';

@freezed
class ChildProgress with _$ChildProgress {
  const factory ChildProgress({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'TotalScore') required int totalScore,
    @JsonKey(name: 'TotalStars') required int totalStars,
    @JsonKey(name: 'CompletedLevelsCount') required int completedLevelsCount,
  }) = _ChildProgress;

  factory ChildProgress.fromJson(Map<String, dynamic> json) =>
      _$ChildProgressFromJson(json);
}

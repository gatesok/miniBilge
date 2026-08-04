import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_goal.freezed.dart';
part 'weekly_goal.g.dart';

/// P6-B04: Ebeveyn haftalık hedefi + mevcut hafta ilerlemesi.
@freezed
class WeeklyGoal with _$WeeklyGoal {
  const factory WeeklyGoal({
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'WeeklyStudyMinutesGoal') int? weeklyStudyMinutesGoal,
    @JsonKey(name: 'FocusTopicId') String? focusTopicId,
    @JsonKey(name: 'FocusTopicName') String? focusTopicName,
    @JsonKey(name: 'FocusCategoryKey') String? focusCategoryKey,
    @JsonKey(name: 'WeekStart') required DateTime weekStart,
    @JsonKey(name: 'WeekEnd') required DateTime weekEnd,
    @JsonKey(name: 'StudyMinutesThisWeek') required int studyMinutesThisWeek,
    @JsonKey(name: 'QuestionsThisWeek') required int questionsThisWeek,
    @JsonKey(name: 'FocusTopicSuccessRate') double? focusTopicSuccessRate,
  }) = _WeeklyGoal;

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) =>
      _$WeeklyGoalFromJson(json);
}

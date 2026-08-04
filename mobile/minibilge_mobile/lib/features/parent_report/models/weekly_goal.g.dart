// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyGoalImpl _$$WeeklyGoalImplFromJson(Map<String, dynamic> json) =>
    _$WeeklyGoalImpl(
      childId: json['ChildId'] as String,
      weeklyStudyMinutesGoal: (json['WeeklyStudyMinutesGoal'] as num?)?.toInt(),
      focusTopicId: json['FocusTopicId'] as String?,
      focusTopicName: json['FocusTopicName'] as String?,
      focusCategoryKey: json['FocusCategoryKey'] as String?,
      weekStart: DateTime.parse(json['WeekStart'] as String),
      weekEnd: DateTime.parse(json['WeekEnd'] as String),
      studyMinutesThisWeek: (json['StudyMinutesThisWeek'] as num).toInt(),
      questionsThisWeek: (json['QuestionsThisWeek'] as num).toInt(),
      focusTopicSuccessRate: (json['FocusTopicSuccessRate'] as num?)
          ?.toDouble(),
    );

Map<String, dynamic> _$$WeeklyGoalImplToJson(_$WeeklyGoalImpl instance) =>
    <String, dynamic>{
      'ChildId': instance.childId,
      'WeeklyStudyMinutesGoal': instance.weeklyStudyMinutesGoal,
      'FocusTopicId': instance.focusTopicId,
      'FocusTopicName': instance.focusTopicName,
      'FocusCategoryKey': instance.focusCategoryKey,
      'WeekStart': instance.weekStart.toIso8601String(),
      'WeekEnd': instance.weekEnd.toIso8601String(),
      'StudyMinutesThisWeek': instance.studyMinutesThisWeek,
      'QuestionsThisWeek': instance.questionsThisWeek,
      'FocusTopicSuccessRate': instance.focusTopicSuccessRate,
    };

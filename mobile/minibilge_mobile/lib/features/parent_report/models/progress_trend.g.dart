// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_trend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressTrendImpl _$$ProgressTrendImplFromJson(Map<String, dynamic> json) =>
    _$ProgressTrendImpl(
      childId: json['ChildId'] as String,
      days: (json['Days'] as num).toInt(),
      periodStart: DateTime.parse(json['PeriodStart'] as String),
      periodEnd: DateTime.parse(json['PeriodEnd'] as String),
      totalQuestionsAnswered: (json['TotalQuestionsAnswered'] as num).toInt(),
      correctAnswers: (json['CorrectAnswers'] as num).toInt(),
      correctAnswerRate: (json['CorrectAnswerRate'] as num).toDouble(),
      activeDays: (json['ActiveDays'] as num).toInt(),
      levelsCompleted: (json['LevelsCompleted'] as num).toInt(),
      totalPointsEarned: (json['TotalPointsEarned'] as num).toInt(),
      totalStarsEarned: (json['TotalStarsEarned'] as num).toInt(),
      weeklyTrend:
          (json['WeeklyTrend'] as List<dynamic>?)
              ?.map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ProgressTrendImplToJson(_$ProgressTrendImpl instance) =>
    <String, dynamic>{
      'ChildId': instance.childId,
      'Days': instance.days,
      'PeriodStart': instance.periodStart.toIso8601String(),
      'PeriodEnd': instance.periodEnd.toIso8601String(),
      'TotalQuestionsAnswered': instance.totalQuestionsAnswered,
      'CorrectAnswers': instance.correctAnswers,
      'CorrectAnswerRate': instance.correctAnswerRate,
      'ActiveDays': instance.activeDays,
      'LevelsCompleted': instance.levelsCompleted,
      'TotalPointsEarned': instance.totalPointsEarned,
      'TotalStarsEarned': instance.totalStarsEarned,
      'WeeklyTrend': instance.weeklyTrend,
    };

_$TrendPointImpl _$$TrendPointImplFromJson(Map<String, dynamic> json) =>
    _$TrendPointImpl(
      weekStart: DateTime.parse(json['WeekStart'] as String),
      weekEnd: DateTime.parse(json['WeekEnd'] as String),
      totalQuestionsAnswered: (json['TotalQuestionsAnswered'] as num).toInt(),
      correctAnswers: (json['CorrectAnswers'] as num).toInt(),
      correctAnswerRate: (json['CorrectAnswerRate'] as num).toDouble(),
      activeDays: (json['ActiveDays'] as num).toInt(),
    );

Map<String, dynamic> _$$TrendPointImplToJson(_$TrendPointImpl instance) =>
    <String, dynamic>{
      'WeekStart': instance.weekStart.toIso8601String(),
      'WeekEnd': instance.weekEnd.toIso8601String(),
      'TotalQuestionsAnswered': instance.totalQuestionsAnswered,
      'CorrectAnswers': instance.correctAnswers,
      'CorrectAnswerRate': instance.correctAnswerRate,
      'ActiveDays': instance.activeDays,
    };

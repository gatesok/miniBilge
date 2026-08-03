// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_performance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicPerformanceImpl _$$TopicPerformanceImplFromJson(
  Map<String, dynamic> json,
) => _$TopicPerformanceImpl(
  topicId: json['TopicId'] as String,
  topicName: json['TopicName'] as String,
  subjectName: json['SubjectName'] as String,
  totalAttempts: (json['TotalAttempts'] as num).toInt(),
  correctAttempts: (json['CorrectAttempts'] as num).toInt(),
  successRate: (json['SuccessRate'] as num).toDouble(),
  averageTimeSeconds: (json['AverageTimeSeconds'] as num?)?.toDouble(),
  distinctDaysPracticed: (json['DistinctDaysPracticed'] as num).toInt(),
  lastPracticedAt: DateTime.parse(json['LastPracticedAt'] as String),
);

Map<String, dynamic> _$$TopicPerformanceImplToJson(
  _$TopicPerformanceImpl instance,
) => <String, dynamic>{
  'TopicId': instance.topicId,
  'TopicName': instance.topicName,
  'SubjectName': instance.subjectName,
  'TotalAttempts': instance.totalAttempts,
  'CorrectAttempts': instance.correctAttempts,
  'SuccessRate': instance.successRate,
  'AverageTimeSeconds': instance.averageTimeSeconds,
  'DistinctDaysPracticed': instance.distinctDaysPracticed,
  'LastPracticedAt': instance.lastPracticedAt.toIso8601String(),
};

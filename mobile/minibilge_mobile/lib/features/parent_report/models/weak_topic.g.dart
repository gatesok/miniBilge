// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weak_topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeakTopicImpl _$$WeakTopicImplFromJson(Map<String, dynamic> json) =>
    _$WeakTopicImpl(
      topicId: json['TopicId'] as String,
      topicName: json['TopicName'] as String,
      subjectName: json['SubjectName'] as String,
      totalAttempts: (json['TotalAttempts'] as num).toInt(),
      correctAttempts: (json['CorrectAttempts'] as num).toInt(),
      successRate: (json['SuccessRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$WeakTopicImplToJson(_$WeakTopicImpl instance) =>
    <String, dynamic>{
      'TopicId': instance.topicId,
      'TopicName': instance.topicName,
      'SubjectName': instance.subjectName,
      'TotalAttempts': instance.totalAttempts,
      'CorrectAttempts': instance.correctAttempts,
      'SuccessRate': instance.successRate,
    };

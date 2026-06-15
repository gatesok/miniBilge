// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionImpl _$$QuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuestionImpl(
      id: json['Id'] as String,
      levelId: json['LevelId'] as String,
      questionText: json['QuestionText'] as String,
      questionType: $enumDecode(_$QuestionTypeEnumMap, json['QuestionType']),
      explanation: json['Explanation'] as String?,
      options:
          (json['Options'] as List<dynamic>?)
              ?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$QuestionImplToJson(_$QuestionImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'LevelId': instance.levelId,
      'QuestionText': instance.questionText,
      'QuestionType': _$QuestionTypeEnumMap[instance.questionType]!,
      'Explanation': instance.explanation,
      'Options': instance.options,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.multipleChoice: 1,
  QuestionType.trueFalse: 2,
  QuestionType.numericInput: 3,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionOptionImpl _$$QuestionOptionImplFromJson(Map<String, dynamic> json) =>
    _$QuestionOptionImpl(
      id: json['Id'] as String,
      optionText: json['OptionText'] as String,
      displayOrder: (json['DisplayOrder'] as num).toInt(),
    );

Map<String, dynamic> _$$QuestionOptionImplToJson(
  _$QuestionOptionImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'OptionText': instance.optionText,
  'DisplayOrder': instance.displayOrder,
};

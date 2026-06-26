// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pronunciation_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WordResultImpl _$$WordResultImplFromJson(Map<String, dynamic> json) =>
    _$WordResultImpl(
      word: json['Word'] as String,
      isCorrect: json['IsCorrect'] as bool,
      hint: json['Hint'] as String?,
    );

Map<String, dynamic> _$$WordResultImplToJson(_$WordResultImpl instance) =>
    <String, dynamic>{
      'Word': instance.word,
      'IsCorrect': instance.isCorrect,
      'Hint': instance.hint,
    };

_$PronunciationResultImpl _$$PronunciationResultImplFromJson(
  Map<String, dynamic> json,
) => _$PronunciationResultImpl(
  words: (json['Words'] as List<dynamic>)
      .map((e) => WordResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  overallScore: (json['OverallScore'] as num).toInt(),
);

Map<String, dynamic> _$$PronunciationResultImplToJson(
  _$PronunciationResultImpl instance,
) => <String, dynamic>{
  'Words': instance.words,
  'OverallScore': instance.overallScore,
};

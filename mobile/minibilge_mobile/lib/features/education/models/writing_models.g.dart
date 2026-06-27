// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WritingPromptImpl _$$WritingPromptImplFromJson(Map<String, dynamic> json) =>
    _$WritingPromptImpl(
      id: json['Id'] as String,
      promptText: json['PromptText'] as String,
      context: json['Context'] as String?,
    );

Map<String, dynamic> _$$WritingPromptImplToJson(_$WritingPromptImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'PromptText': instance.promptText,
      'Context': instance.context,
    };

_$WritingCorrectionImpl _$$WritingCorrectionImplFromJson(
  Map<String, dynamic> json,
) => _$WritingCorrectionImpl(
  original: json['Original'] as String,
  suggestion: json['Suggestion'] as String,
  explanation: json['Explanation'] as String,
  explanationTr: json['ExplanationTr'] as String? ?? '',
);

Map<String, dynamic> _$$WritingCorrectionImplToJson(
  _$WritingCorrectionImpl instance,
) => <String, dynamic>{
  'Original': instance.original,
  'Suggestion': instance.suggestion,
  'Explanation': instance.explanation,
  'ExplanationTr': instance.explanationTr,
};

_$WritingEvaluationResultImpl _$$WritingEvaluationResultImplFromJson(
  Map<String, dynamic> json,
) => _$WritingEvaluationResultImpl(
  score: (json['Score'] as num).toInt(),
  corrections: (json['Corrections'] as List<dynamic>)
      .map((e) => WritingCorrection.fromJson(e as Map<String, dynamic>))
      .toList(),
  feedback: json['Feedback'] as String,
  feedbackTr: json['FeedbackTr'] as String? ?? '',
  coinsEarned: (json['CoinsEarned'] as num).toInt(),
  starsEarned: (json['StarsEarned'] as num).toInt(),
);

Map<String, dynamic> _$$WritingEvaluationResultImplToJson(
  _$WritingEvaluationResultImpl instance,
) => <String, dynamic>{
  'Score': instance.score,
  'Corrections': instance.corrections,
  'Feedback': instance.feedback,
  'FeedbackTr': instance.feedbackTr,
  'CoinsEarned': instance.coinsEarned,
  'StarsEarned': instance.starsEarned,
};

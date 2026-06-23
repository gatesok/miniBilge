// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_quiz_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastQuizOptionImpl _$$PodcastQuizOptionImplFromJson(
  Map<String, dynamic> json,
) => _$PodcastQuizOptionImpl(
  id: json['Id'] as String,
  optionText: json['OptionText'] as String,
  displayOrder: (json['DisplayOrder'] as num).toInt(),
);

Map<String, dynamic> _$$PodcastQuizOptionImplToJson(
  _$PodcastQuizOptionImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'OptionText': instance.optionText,
  'DisplayOrder': instance.displayOrder,
};

_$PodcastQuizQuestionImpl _$$PodcastQuizQuestionImplFromJson(
  Map<String, dynamic> json,
) => _$PodcastQuizQuestionImpl(
  id: json['Id'] as String,
  questionText: json['QuestionText'] as String,
  questionType: (json['QuestionType'] as num).toInt(),
  displayOrder: (json['DisplayOrder'] as num).toInt(),
  options: (json['Options'] as List<dynamic>)
      .map((e) => PodcastQuizOption.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$PodcastQuizQuestionImplToJson(
  _$PodcastQuizQuestionImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'QuestionText': instance.questionText,
  'QuestionType': instance.questionType,
  'DisplayOrder': instance.displayOrder,
  'Options': instance.options,
};

_$PodcastQuizAnswerResultImpl _$$PodcastQuizAnswerResultImplFromJson(
  Map<String, dynamic> json,
) => _$PodcastQuizAnswerResultImpl(
  questionId: json['QuestionId'] as String,
  isCorrect: json['IsCorrect'] as bool,
  correctAnswer: json['CorrectAnswer'] as String,
  explanation: json['Explanation'] as String?,
);

Map<String, dynamic> _$$PodcastQuizAnswerResultImplToJson(
  _$PodcastQuizAnswerResultImpl instance,
) => <String, dynamic>{
  'QuestionId': instance.questionId,
  'IsCorrect': instance.isCorrect,
  'CorrectAnswer': instance.correctAnswer,
  'Explanation': instance.explanation,
};

_$PodcastQuizResultImpl _$$PodcastQuizResultImplFromJson(
  Map<String, dynamic> json,
) => _$PodcastQuizResultImpl(
  correctCount: (json['CorrectCount'] as num).toInt(),
  totalQuestions: (json['TotalQuestions'] as num).toInt(),
  starsEarned: (json['StarsEarned'] as num).toInt(),
  coinsEarned: (json['CoinsEarned'] as num).toInt(),
  isFirstCompletion: json['IsFirstCompletion'] as bool,
  answerResults: (json['AnswerResults'] as List<dynamic>)
      .map((e) => PodcastQuizAnswerResult.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$PodcastQuizResultImplToJson(
  _$PodcastQuizResultImpl instance,
) => <String, dynamic>{
  'CorrectCount': instance.correctCount,
  'TotalQuestions': instance.totalQuestions,
  'StarsEarned': instance.starsEarned,
  'CoinsEarned': instance.coinsEarned,
  'IsFirstCompletion': instance.isFirstCompletion,
  'AnswerResults': instance.answerResults,
};

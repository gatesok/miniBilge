// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_challenge_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VocabChallengeTaskImpl _$$VocabChallengeTaskImplFromJson(
  Map<String, dynamic> json,
) => _$VocabChallengeTaskImpl(
  task: json['Task'] as String,
  targetWords: (json['TargetWords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$VocabChallengeTaskImplToJson(
  _$VocabChallengeTaskImpl instance,
) => <String, dynamic>{
  'Task': instance.task,
  'TargetWords': instance.targetWords,
};

_$VocabChallengeResultImpl _$$VocabChallengeResultImplFromJson(
  Map<String, dynamic> json,
) => _$VocabChallengeResultImpl(
  score: (json['Score'] as num).toInt(),
  targetWordUsage: Map<String, bool>.from(json['TargetWordUsage'] as Map),
  corrections: (json['Corrections'] as List<dynamic>)
      .map((e) => WritingCorrection.fromJson(e as Map<String, dynamic>))
      .toList(),
  feedback: json['Feedback'] as String,
  coinsEarned: (json['CoinsEarned'] as num?)?.toInt() ?? 0,
  starsEarned: (json['StarsEarned'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$VocabChallengeResultImplToJson(
  _$VocabChallengeResultImpl instance,
) => <String, dynamic>{
  'Score': instance.score,
  'TargetWordUsage': instance.targetWordUsage,
  'Corrections': instance.corrections,
  'Feedback': instance.feedback,
  'CoinsEarned': instance.coinsEarned,
  'StarsEarned': instance.starsEarned,
};

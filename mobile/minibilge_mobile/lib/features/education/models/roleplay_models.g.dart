// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roleplay_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScenarioDtoImpl _$$ScenarioDtoImplFromJson(Map<String, dynamic> json) =>
    _$ScenarioDtoImpl(
      key: json['Key'] as String,
      title: json['Title'] as String,
      description: json['Description'] as String,
      level: json['Level'] as String,
      characterName: json['CharacterName'] as String,
      characterRole: json['CharacterRole'] as String,
      emoji: json['Emoji'] as String,
    );

Map<String, dynamic> _$$ScenarioDtoImplToJson(_$ScenarioDtoImpl instance) =>
    <String, dynamic>{
      'Key': instance.key,
      'Title': instance.title,
      'Description': instance.description,
      'Level': instance.level,
      'CharacterName': instance.characterName,
      'CharacterRole': instance.characterRole,
      'Emoji': instance.emoji,
    };

_$StartRolePlayResponseImpl _$$StartRolePlayResponseImplFromJson(
  Map<String, dynamic> json,
) => _$StartRolePlayResponseImpl(
  sessionId: json['SessionId'] as String,
  assistantMessage: json['AssistantMessage'] as String,
  characterName: json['CharacterName'] as String,
  characterRole: json['CharacterRole'] as String,
  scenarioTitle: json['ScenarioTitle'] as String,
  emoji: json['Emoji'] as String,
);

Map<String, dynamic> _$$StartRolePlayResponseImplToJson(
  _$StartRolePlayResponseImpl instance,
) => <String, dynamic>{
  'SessionId': instance.sessionId,
  'AssistantMessage': instance.assistantMessage,
  'CharacterName': instance.characterName,
  'CharacterRole': instance.characterRole,
  'ScenarioTitle': instance.scenarioTitle,
  'Emoji': instance.emoji,
};

_$SendTurnResponseImpl _$$SendTurnResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SendTurnResponseImpl(
  assistantMessage: json['AssistantMessage'] as String,
  grammarNote: json['GrammarNote'] as String?,
  turnCount: (json['TurnCount'] as num).toInt(),
  maxTurnsReached: json['MaxTurnsReached'] as bool? ?? false,
);

Map<String, dynamic> _$$SendTurnResponseImplToJson(
  _$SendTurnResponseImpl instance,
) => <String, dynamic>{
  'AssistantMessage': instance.assistantMessage,
  'GrammarNote': instance.grammarNote,
  'TurnCount': instance.turnCount,
  'MaxTurnsReached': instance.maxTurnsReached,
};

_$EndSessionResponseImpl _$$EndSessionResponseImplFromJson(
  Map<String, dynamic> json,
) => _$EndSessionResponseImpl(
  score: (json['Score'] as num).toInt(),
  feedback: json['Feedback'] as String,
  turnCount: (json['TurnCount'] as num).toInt(),
  coinsEarned: (json['CoinsEarned'] as num?)?.toInt() ?? 0,
  starsEarned: (json['StarsEarned'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$EndSessionResponseImplToJson(
  _$EndSessionResponseImpl instance,
) => <String, dynamic>{
  'Score': instance.score,
  'Feedback': instance.feedback,
  'TurnCount': instance.turnCount,
  'CoinsEarned': instance.coinsEarned,
  'StarsEarned': instance.starsEarned,
};

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      role: json['role'] as String,
      content: json['content'] as String,
      grammarNote: json['grammarNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'grammarNote': instance.grammarNote,
      'createdAt': instance.createdAt.toIso8601String(),
    };

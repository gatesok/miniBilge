// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchRequestImpl _$$MatchRequestImplFromJson(Map<String, dynamic> json) =>
    _$MatchRequestImpl(
      id: json['id'] as String,
      childProfileId: json['childProfileId'] as String,
      status: $enumDecode(_$MatchRequestStatusEnumMap, json['status']),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      matchedAt: json['matchedAt'] == null
          ? null
          : DateTime.parse(json['matchedAt'] as String),
      matchSessionId: json['matchSessionId'] as String?,
    );

Map<String, dynamic> _$$MatchRequestImplToJson(_$MatchRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childProfileId': instance.childProfileId,
      'status': _$MatchRequestStatusEnumMap[instance.status]!,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'matchedAt': instance.matchedAt?.toIso8601String(),
      'matchSessionId': instance.matchSessionId,
    };

const _$MatchRequestStatusEnumMap = {
  MatchRequestStatus.waiting: 'Waiting',
  MatchRequestStatus.matched: 'Matched',
  MatchRequestStatus.expired: 'Expired',
  MatchRequestStatus.cancelled: 'Cancelled',
};

_$MatchSessionImpl _$$MatchSessionImplFromJson(Map<String, dynamic> json) =>
    _$MatchSessionImpl(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      status: $enumDecode(_$MatchSessionStatusEnumMap, json['status']),
      winnerId: json['winnerId'] as String?,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => MatchParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => MatchQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MatchSessionImplToJson(_$MatchSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'status': _$MatchSessionStatusEnumMap[instance.status]!,
      'winnerId': instance.winnerId,
      'participants': instance.participants,
      'questions': instance.questions,
    };

const _$MatchSessionStatusEnumMap = {
  MatchSessionStatus.created: 'Created',
  MatchSessionStatus.inProgress: 'InProgress',
  MatchSessionStatus.completed: 'Completed',
  MatchSessionStatus.abandoned: 'Abandoned',
};

_$MatchParticipantImpl _$$MatchParticipantImplFromJson(
  Map<String, dynamic> json,
) => _$MatchParticipantImpl(
  id: json['id'] as String,
  matchSessionId: json['matchSessionId'] as String,
  childProfileId: json['childProfileId'] as String,
  childName: json['childName'] as String,
  score: (json['score'] as num).toInt(),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  isReady: json['isReady'] as bool,
  avatarImageUrl: json['avatarImageUrl'] as String?,
  avatarId: (json['avatarId'] as num?)?.toInt(),
);

Map<String, dynamic> _$$MatchParticipantImplToJson(
  _$MatchParticipantImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'matchSessionId': instance.matchSessionId,
  'childProfileId': instance.childProfileId,
  'childName': instance.childName,
  'score': instance.score,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'isReady': instance.isReady,
  'avatarImageUrl': instance.avatarImageUrl,
  'avatarId': instance.avatarId,
};

_$MatchQuestionImpl _$$MatchQuestionImplFromJson(Map<String, dynamic> json) =>
    _$MatchQuestionImpl(
      id: json['id'] as String,
      matchSessionId: json['matchSessionId'] as String,
      questionId: json['questionId'] as String,
      questionOrder: (json['questionOrder'] as num).toInt(),
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$MatchQuestionImplToJson(_$MatchQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchSessionId': instance.matchSessionId,
      'questionId': instance.questionId,
      'questionOrder': instance.questionOrder,
      'questionText': instance.questionText,
      'correctAnswer': instance.correctAnswer,
      'options': instance.options,
    };

_$MatchAnswerImpl _$$MatchAnswerImplFromJson(Map<String, dynamic> json) =>
    _$MatchAnswerImpl(
      id: json['id'] as String,
      matchSessionId: json['matchSessionId'] as String,
      participantId: json['participantId'] as String,
      questionId: json['questionId'] as String,
      answer: json['answer'] as String,
      isCorrect: json['isCorrect'] as bool,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      pointsEarned: (json['pointsEarned'] as num).toInt(),
    );

Map<String, dynamic> _$$MatchAnswerImplToJson(_$MatchAnswerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchSessionId': instance.matchSessionId,
      'participantId': instance.participantId,
      'questionId': instance.questionId,
      'answer': instance.answer,
      'isCorrect': instance.isCorrect,
      'answeredAt': instance.answeredAt.toIso8601String(),
      'pointsEarned': instance.pointsEarned,
    };

_$MatchStatsImpl _$$MatchStatsImplFromJson(Map<String, dynamic> json) =>
    _$MatchStatsImpl(
      childId: json['childId'] as String,
      gamesPlayed: (json['gamesPlayed'] as num).toInt(),
      gamesWon: (json['gamesWon'] as num).toInt(),
      gamesLost: (json['gamesLost'] as num).toInt(),
      totalScore: (json['totalScore'] as num).toInt(),
      averageScore: (json['averageScore'] as num).toDouble(),
      winRate: (json['winRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$MatchStatsImplToJson(_$MatchStatsImpl instance) =>
    <String, dynamic>{
      'childId': instance.childId,
      'gamesPlayed': instance.gamesPlayed,
      'gamesWon': instance.gamesWon,
      'gamesLost': instance.gamesLost,
      'totalScore': instance.totalScore,
      'averageScore': instance.averageScore,
      'winRate': instance.winRate,
    };

_$MatchHistoryItemImpl _$$MatchHistoryItemImplFromJson(
  Map<String, dynamic> json,
) => _$MatchHistoryItemImpl(
  matchSessionId: json['matchSessionId'] as String,
  playedAt: DateTime.parse(json['playedAt'] as String),
  opponentName: json['opponentName'] as String,
  opponentAvatarId: (json['opponentAvatarId'] as num?)?.toInt(),
  opponentAvatarUrl: json['opponentAvatarUrl'] as String?,
  myScore: (json['myScore'] as num).toInt(),
  opponentScore: (json['opponentScore'] as num).toInt(),
  isWinner: json['isWinner'] as bool,
  isDraw: json['isDraw'] as bool? ?? false,
);

Map<String, dynamic> _$$MatchHistoryItemImplToJson(
  _$MatchHistoryItemImpl instance,
) => <String, dynamic>{
  'matchSessionId': instance.matchSessionId,
  'playedAt': instance.playedAt.toIso8601String(),
  'opponentName': instance.opponentName,
  'opponentAvatarId': instance.opponentAvatarId,
  'opponentAvatarUrl': instance.opponentAvatarUrl,
  'myScore': instance.myScore,
  'opponentScore': instance.opponentScore,
  'isWinner': instance.isWinner,
  'isDraw': instance.isDraw,
};

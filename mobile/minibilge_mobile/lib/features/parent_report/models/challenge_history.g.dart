// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeHistoryImpl _$$ChallengeHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$ChallengeHistoryImpl(
  childId: json['ChildId'] as String,
  totalCompleted: (json['TotalCompleted'] as num).toInt(),
  won: (json['Won'] as num).toInt(),
  lost: (json['Lost'] as num).toInt(),
  tie: (json['Tie'] as num).toInt(),
  items:
      (json['Items'] as List<dynamic>?)
          ?.map((e) => ChallengeHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ChallengeHistoryItem>[],
);

Map<String, dynamic> _$$ChallengeHistoryImplToJson(
  _$ChallengeHistoryImpl instance,
) => <String, dynamic>{
  'ChildId': instance.childId,
  'TotalCompleted': instance.totalCompleted,
  'Won': instance.won,
  'Lost': instance.lost,
  'Tie': instance.tie,
  'Items': instance.items,
};

_$ChallengeHistoryItemImpl _$$ChallengeHistoryItemImplFromJson(
  Map<String, dynamic> json,
) => _$ChallengeHistoryItemImpl(
  id: json['Id'] as String,
  opponentName: json['OpponentName'] as String,
  category: json['Category'] as String,
  result: json['Result'] as String,
  myScore: (json['MyScore'] as num).toInt(),
  opponentScore: (json['OpponentScore'] as num).toInt(),
  totalQuestions: (json['TotalQuestions'] as num).toInt(),
  playedAt: DateTime.parse(json['PlayedAt'] as String),
);

Map<String, dynamic> _$$ChallengeHistoryItemImplToJson(
  _$ChallengeHistoryItemImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'OpponentName': instance.opponentName,
  'Category': instance.category,
  'Result': instance.result,
  'MyScore': instance.myScore,
  'OpponentScore': instance.opponentScore,
  'TotalQuestions': instance.totalQuestions,
  'PlayedAt': instance.playedAt.toIso8601String(),
};

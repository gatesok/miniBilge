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
  categories:
      (json['Categories'] as List<dynamic>?)
          ?.map(
            (e) => ChallengeCategoryStat.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ChallengeCategoryStat>[],
);

Map<String, dynamic> _$$ChallengeHistoryImplToJson(
  _$ChallengeHistoryImpl instance,
) => <String, dynamic>{
  'ChildId': instance.childId,
  'TotalCompleted': instance.totalCompleted,
  'Won': instance.won,
  'Lost': instance.lost,
  'Tie': instance.tie,
  'Categories': instance.categories,
};

_$ChallengeCategoryStatImpl _$$ChallengeCategoryStatImplFromJson(
  Map<String, dynamic> json,
) => _$ChallengeCategoryStatImpl(
  category: json['Category'] as String,
  played: (json['Played'] as num).toInt(),
  won: (json['Won'] as num).toInt(),
  lost: (json['Lost'] as num).toInt(),
  tie: (json['Tie'] as num).toInt(),
  winRate: (json['WinRate'] as num).toDouble(),
);

Map<String, dynamic> _$$ChallengeCategoryStatImplToJson(
  _$ChallengeCategoryStatImpl instance,
) => <String, dynamic>{
  'Category': instance.category,
  'Played': instance.played,
  'Won': instance.won,
  'Lost': instance.lost,
  'Tie': instance.tie,
  'WinRate': instance.winRate,
};

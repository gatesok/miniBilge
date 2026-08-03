// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entertainment_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntertainmentStatsImpl _$$EntertainmentStatsImplFromJson(
  Map<String, dynamic> json,
) => _$EntertainmentStatsImpl(
  childId: json['ChildId'] as String,
  totalPlayed: (json['TotalPlayed'] as num).toInt(),
  totalWon: (json['TotalWon'] as num).toInt(),
  perfectWins: (json['PerfectWins'] as num).toInt(),
  averageSuccessRate: (json['AverageSuccessRate'] as num).toDouble(),
  categories:
      (json['Categories'] as List<dynamic>?)
          ?.map(
            (e) =>
                EntertainmentCategoryStat.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <EntertainmentCategoryStat>[],
);

Map<String, dynamic> _$$EntertainmentStatsImplToJson(
  _$EntertainmentStatsImpl instance,
) => <String, dynamic>{
  'ChildId': instance.childId,
  'TotalPlayed': instance.totalPlayed,
  'TotalWon': instance.totalWon,
  'PerfectWins': instance.perfectWins,
  'AverageSuccessRate': instance.averageSuccessRate,
  'Categories': instance.categories,
};

_$EntertainmentCategoryStatImpl _$$EntertainmentCategoryStatImplFromJson(
  Map<String, dynamic> json,
) => _$EntertainmentCategoryStatImpl(
  categoryKey: json['CategoryKey'] as String,
  categoryName: json['CategoryName'] as String,
  played: (json['Played'] as num).toInt(),
  won: (json['Won'] as num).toInt(),
  averageSuccessRate: (json['AverageSuccessRate'] as num).toDouble(),
);

Map<String, dynamic> _$$EntertainmentCategoryStatImplToJson(
  _$EntertainmentCategoryStatImpl instance,
) => <String, dynamic>{
  'CategoryKey': instance.categoryKey,
  'CategoryName': instance.categoryName,
  'Played': instance.played,
  'Won': instance.won,
  'AverageSuccessRate': instance.averageSuccessRate,
};

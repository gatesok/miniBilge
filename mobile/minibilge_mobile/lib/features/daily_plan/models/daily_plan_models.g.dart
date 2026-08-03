// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_plan_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyPlanDtoImpl _$$DailyPlanDtoImplFromJson(Map<String, dynamic> json) =>
    _$DailyPlanDtoImpl(
      id: json['Id'] as String,
      planDate: json['PlanDate'] as String,
      status: json['Status'] as String,
      source: json['Source'] as String,
      isPremiumPersonalized: json['IsPremiumPersonalized'] as bool? ?? false,
      totalItems: (json['TotalItems'] as num?)?.toInt() ?? 0,
      completedItems: (json['CompletedItems'] as num?)?.toInt() ?? 0,
      completedAt: json['CompletedAt'] == null
          ? null
          : DateTime.parse(json['CompletedAt'] as String),
      rewardStars: (json['RewardStars'] as num?)?.toInt() ?? 0,
      rewardPoints: (json['RewardPoints'] as num?)?.toInt() ?? 0,
      rewardGranted: json['RewardGranted'] as bool? ?? false,
      items:
          (json['Items'] as List<dynamic>?)
              ?.map((e) => DailyPlanItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DailyPlanItemDto>[],
    );

Map<String, dynamic> _$$DailyPlanDtoImplToJson(_$DailyPlanDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'PlanDate': instance.planDate,
      'Status': instance.status,
      'Source': instance.source,
      'IsPremiumPersonalized': instance.isPremiumPersonalized,
      'TotalItems': instance.totalItems,
      'CompletedItems': instance.completedItems,
      'CompletedAt': instance.completedAt?.toIso8601String(),
      'RewardStars': instance.rewardStars,
      'RewardPoints': instance.rewardPoints,
      'RewardGranted': instance.rewardGranted,
      'Items': instance.items,
    };

_$DailyPlanItemDtoImpl _$$DailyPlanItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$DailyPlanItemDtoImpl(
  id: json['Id'] as String,
  order: (json['Order'] as num).toInt(),
  activityType: json['ActivityType'] as String,
  title: json['Title'] as String,
  routeKey: json['RouteKey'] as String?,
  targetCount: (json['TargetCount'] as num?)?.toInt() ?? 0,
  isCompleted: json['IsCompleted'] as bool? ?? false,
  completedAt: json['CompletedAt'] == null
      ? null
      : DateTime.parse(json['CompletedAt'] as String),
);

Map<String, dynamic> _$$DailyPlanItemDtoImplToJson(
  _$DailyPlanItemDtoImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'Order': instance.order,
  'ActivityType': instance.activityType,
  'Title': instance.title,
  'RouteKey': instance.routeKey,
  'TargetCount': instance.targetCount,
  'IsCompleted': instance.isCompleted,
  'CompletedAt': instance.completedAt?.toIso8601String(),
};

import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_plan_models.freezed.dart';
part 'daily_plan_models.g.dart';

@freezed
class DailyPlanDto with _$DailyPlanDto {
  const factory DailyPlanDto({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'PlanDate') required String planDate,
    @JsonKey(name: 'Status') required String status,
    @JsonKey(name: 'Source') required String source,
    @JsonKey(name: 'IsPremiumPersonalized')
    @Default(false)
    bool isPremiumPersonalized,
    @JsonKey(name: 'TotalItems') @Default(0) int totalItems,
    @JsonKey(name: 'CompletedItems') @Default(0) int completedItems,
    @JsonKey(name: 'CompletedAt') DateTime? completedAt,
    @JsonKey(name: 'RewardStars') @Default(0) int rewardStars,
    @JsonKey(name: 'RewardPoints') @Default(0) int rewardPoints,
    @JsonKey(name: 'RewardGranted') @Default(false) bool rewardGranted,
    @JsonKey(name: 'Items') @Default(<DailyPlanItemDto>[])
    List<DailyPlanItemDto> items,
  }) = _DailyPlanDto;

  factory DailyPlanDto.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanDtoFromJson(json);
}

@freezed
class DailyPlanItemDto with _$DailyPlanItemDto {
  const factory DailyPlanItemDto({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Order') required int order,
    @JsonKey(name: 'ActivityType') required String activityType,
    @JsonKey(name: 'Title') required String title,
    @JsonKey(name: 'RouteKey') String? routeKey,
    @JsonKey(name: 'TargetCount') @Default(0) int targetCount,
    @JsonKey(name: 'Note') String? note,
    @JsonKey(name: 'IsCompleted') @Default(false) bool isCompleted,
    @JsonKey(name: 'CompletedAt') DateTime? completedAt,
  }) = _DailyPlanItemDto;

  factory DailyPlanItemDto.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanItemDtoFromJson(json);
}

extension DailyPlanX on DailyPlanDto {
  bool get isCompleted => status == 'completed';

  double get progress =>
      totalItems == 0 ? 0 : completedItems / totalItems;
}

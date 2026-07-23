class DailyUsageStatus {
  const DailyUsageStatus({
    required this.featureKey,
    required this.isPremium,
    required this.baseLimit,
    required this.usedCount,
    required this.rewardedBonusCount,
    required this.rewardedBonusLimit,
    required this.remaining,
    required this.allowed,
  });

  final String featureKey;
  final bool isPremium;
  final int baseLimit;
  final int usedCount;
  final int rewardedBonusCount;
  final int rewardedBonusLimit;
  final int remaining;
  final bool allowed;

  bool get canEarnRewardedBonus =>
      !isPremium && rewardedBonusCount < rewardedBonusLimit;

  factory DailyUsageStatus.fromJson(Map<String, dynamic> json) {
    return DailyUsageStatus(
      featureKey: json['FeatureKey'] as String? ?? '',
      isPremium: json['IsPremium'] as bool? ?? false,
      baseLimit: json['BaseLimit'] as int? ?? 0,
      usedCount: json['UsedCount'] as int? ?? 0,
      rewardedBonusCount: json['RewardedBonusCount'] as int? ?? 0,
      rewardedBonusLimit: json['RewardedBonusLimit'] as int? ?? 0,
      remaining: json['Remaining'] as int? ?? 0,
      allowed: json['Allowed'] as bool? ?? false,
    );
  }
}

class BadgeDto {
  final String id;
  final String key;
  final String name;
  final String description;
  final String emoji;
  final String category;
  final String rarity;
  final bool isEarned;
  final DateTime? earnedAt;
  final bool isApplicableToProfile;
  final BadgeProgressDto? progress;

  const BadgeDto({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.rarity,
    required this.isEarned,
    this.earnedAt,
    this.isApplicableToProfile = true,
    this.progress,
  });

  factory BadgeDto.fromJson(Map<String, dynamic> json) => BadgeDto(
        id: json['Id'] as String,
        key: json['Key'] as String,
        name: json['Name'] as String,
        description: json['Description'] as String,
        emoji: json['Emoji'] as String,
        category: json['Category'] as String,
        rarity: json['Rarity'] as String,
        isEarned: json['IsEarned'] as bool? ?? false,
        earnedAt: json['EarnedAt'] != null
            ? DateTime.tryParse(json['EarnedAt'] as String)
            : null,
        isApplicableToProfile: json['IsApplicableToProfile'] as bool? ?? true,
        progress: json['Progress'] != null
            ? BadgeProgressDto.fromJson(json['Progress'] as Map<String, dynamic>)
            : null,
      );
}

class BadgeProgressDto {
  final int current;
  final int target;
  final String unit; // "count" | "categories" | "streak" | "days" | "percent"

  const BadgeProgressDto({
    required this.current,
    required this.target,
    required this.unit,
  });

  double get ratio => target <= 0 ? 0 : (current / target).clamp(0, 1).toDouble();

  factory BadgeProgressDto.fromJson(Map<String, dynamic> json) => BadgeProgressDto(
        current: json['Current'] as int? ?? 0,
        target: json['Target'] as int? ?? 0,
        unit: json['Unit'] as String? ?? 'count',
      );
}

class BadgeCollectionDto {
  final int totalBadges;
  final int earnedCount;
  final List<BadgeDto> badges;

  const BadgeCollectionDto({
    required this.totalBadges,
    required this.earnedCount,
    required this.badges,
  });

  factory BadgeCollectionDto.fromJson(Map<String, dynamic> json) =>
      BadgeCollectionDto(
        totalBadges: json['TotalBadges'] as int,
        earnedCount: json['EarnedCount'] as int,
        badges: (json['Badges'] as List)
            .map((e) => BadgeDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

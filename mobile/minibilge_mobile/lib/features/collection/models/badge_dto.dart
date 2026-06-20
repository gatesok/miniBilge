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

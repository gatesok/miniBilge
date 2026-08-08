class CollectibleCardDto {
  final String id;
  final String name;
  final String description;
  final String series;
  final String rarity;
  final String imageAsset;
  final int cardNumber;
  final bool isOwned;
  final int ownedCount;
  final DateTime? firstEarnedAt;
  final bool isPremiumExclusive;
  final bool isPremiumLocked;

  const CollectibleCardDto({
    required this.id,
    required this.name,
    required this.description,
    required this.series,
    required this.rarity,
    required this.imageAsset,
    required this.cardNumber,
    required this.isOwned,
    required this.ownedCount,
    this.firstEarnedAt,
    this.isPremiumExclusive = false,
    this.isPremiumLocked = false,
  });

  factory CollectibleCardDto.fromJson(Map<String, dynamic> json) =>
      CollectibleCardDto(
        id: json['Id'] as String,
        name: json['Name'] as String,
        description: json['Description'] as String,
        series: json['Series'] as String,
        rarity: json['Rarity'] as String,
        imageAsset: json['ImageAsset'] as String,
        cardNumber: json['CardNumber'] as int,
        isOwned: json['IsOwned'] as bool? ?? false,
        ownedCount: json['OwnedCount'] as int? ?? 0,
        firstEarnedAt: json['FirstEarnedAt'] != null
            ? DateTime.tryParse(json['FirstEarnedAt'] as String)
            : null,
        isPremiumExclusive: json['IsPremiumExclusive'] as bool? ?? false,
        isPremiumLocked: json['IsPremiumLocked'] as bool? ?? false,
      );
}

class CardCollectionDto {
  final int totalCards;
  final int ownedCount;
  final List<CollectibleCardDto> cards;
  final int shardBalance;
  final int dailyRemaining;
  final int dailyLimit;
  final int pityRemaining;
  final String economyStage;

  const CardCollectionDto({
    required this.totalCards,
    required this.ownedCount,
    required this.cards,
    required this.shardBalance,
    required this.dailyRemaining,
    required this.dailyLimit,
    required this.pityRemaining,
    required this.economyStage,
  });

  factory CardCollectionDto.fromJson(Map<String, dynamic> json) =>
      CardCollectionDto(
        totalCards: json['TotalCards'] as int,
        ownedCount: json['OwnedCount'] as int,
        cards: (json['Cards'] as List)
            .map((e) => CollectibleCardDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        shardBalance: json['ShardBalance'] as int? ?? 0,
        dailyRemaining: json['DailyRemaining'] as int? ?? 0,
        dailyLimit: json['DailyLimit'] as int? ?? 5,
        pityRemaining: json['PityRemaining'] as int? ?? 0,
        economyStage: json['EconomyStage'] as String? ?? 'starter',
      );
}

class CardDropResult {
  final String cardId;
  final String cardName;
  final String rarity;
  final String imageAsset;
  final bool isNew;
  final int shardsAwarded;
  final int shardBalance;
  final int dailyRemaining;
  final int pityRemaining;
  final String stage;
  final bool wasGuaranteed;

  const CardDropResult({
    required this.cardId,
    required this.cardName,
    required this.rarity,
    required this.imageAsset,
    required this.isNew,
    this.shardsAwarded = 0,
    this.shardBalance = 0,
    this.dailyRemaining = 0,
    this.pityRemaining = 0,
    this.stage = 'starter',
    this.wasGuaranteed = false,
  });

  factory CardDropResult.fromJson(Map<String, dynamic> json) => CardDropResult(
    cardId: json['CardId'] as String,
    cardName: json['CardName'] as String,
    rarity: json['Rarity'] as String,
    imageAsset: json['ImageAsset'] as String,
    isNew: json['IsNew'] as bool? ?? false,
    shardsAwarded: json['ShardsAwarded'] as int? ?? 0,
    shardBalance: json['ShardBalance'] as int? ?? 0,
    dailyRemaining: json['DailyRemaining'] as int? ?? 0,
    pityRemaining: json['PityRemaining'] as int? ?? 0,
    stage: json['Stage'] as String? ?? 'starter',
    wasGuaranteed: json['WasGuaranteed'] as bool? ?? false,
  );
}

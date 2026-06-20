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
      );
}

class CardCollectionDto {
  final int totalCards;
  final int ownedCount;
  final List<CollectibleCardDto> cards;

  const CardCollectionDto({
    required this.totalCards,
    required this.ownedCount,
    required this.cards,
  });

  factory CardCollectionDto.fromJson(Map<String, dynamic> json) =>
      CardCollectionDto(
        totalCards: json['TotalCards'] as int,
        ownedCount: json['OwnedCount'] as int,
        cards: (json['Cards'] as List)
            .map((e) =>
                CollectibleCardDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CardDropResult {
  final String cardId;
  final String cardName;
  final String rarity;
  final String imageAsset;
  final bool isNew;

  const CardDropResult({
    required this.cardId,
    required this.cardName,
    required this.rarity,
    required this.imageAsset,
    required this.isNew,
  });

  factory CardDropResult.fromJson(Map<String, dynamic> json) => CardDropResult(
        cardId: json['CardId'] as String,
        cardName: json['CardName'] as String,
        rarity: json['Rarity'] as String,
        imageAsset: json['ImageAsset'] as String,
        isNew: json['IsNew'] as bool? ?? false,
      );
}

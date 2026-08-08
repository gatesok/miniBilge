import 'package:flutter_test/flutter_test.dart';
import 'package:minibilge_mobile/features/collection/models/card_dto.dart';

void main() {
  test('kart ekonomisi alanlarını API yanıtından okur', () {
    final collection = CardCollectionDto.fromJson({
      'TotalCards': 80,
      'OwnedCount': 16,
      'ShardBalance': 42,
      'DailyRemaining': 3,
      'DailyLimit': 5,
      'PityRemaining': 4,
      'EconomyStage': 'growth',
      'Cards': <Object>[],
    });

    expect(collection.shardBalance, 42);
    expect(collection.dailyRemaining, 3);
    expect(collection.pityRemaining, 4);
    expect(collection.economyStage, 'growth');
  });

  test('eski API yanıtlarında güvenli varsayılanları kullanır', () {
    final collection = CardCollectionDto.fromJson({
      'TotalCards': 40,
      'OwnedCount': 4,
      'Cards': <Object>[],
    });

    expect(collection.shardBalance, 0);
    expect(collection.dailyLimit, 5);
    expect(collection.economyStage, 'starter');
  });

  test('premium kart kilidini API yanıtından okur', () {
    final card = CollectibleCardDto.fromJson({
      'Id': 'premium-card',
      'Name': 'Efsane Kart',
      'Description': 'Premium koleksiyon kartı',
      'Series': 'legends',
      'Rarity': 'legendary',
      'ImageAsset': 'assets/cards/legendary.png',
      'CardNumber': 99,
      'IsOwned': false,
      'IsPremiumExclusive': true,
      'IsPremiumLocked': true,
    });

    expect(card.isPremiumExclusive, isTrue);
    expect(card.isPremiumLocked, isTrue);
    expect(card.isOwned, isFalse);
  });

  test('eski kart yanıtlarında premium alanları false varsayılır', () {
    final card = CollectibleCardDto.fromJson({
      'Id': 'basic-card',
      'Name': 'Temel Kart',
      'Description': 'Temel koleksiyon kartı',
      'Series': 'animals',
      'Rarity': 'common',
      'ImageAsset': 'assets/cards/basic.png',
      'CardNumber': 1,
    });

    expect(card.isPremiumExclusive, isFalse);
    expect(card.isPremiumLocked, isFalse);
  });
}

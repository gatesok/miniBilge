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
}

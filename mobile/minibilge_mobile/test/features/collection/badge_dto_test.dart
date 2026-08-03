import 'package:flutter_test/flutter_test.dart';
import 'package:minibilge_mobile/features/collection/models/badge_dto.dart';

void main() {
  group('BadgeDto.fromJson', () {
    test('parses progress and profile applicability', () {
      final dto = BadgeDto.fromJson({
        'Id': 'id-1',
        'Key': 'challenge_wins_10',
        'Name': 'Düello Meraklısı',
        'Description': '10 meydan okuma kazan',
        'Emoji': '⚔️',
        'Category': 'challenge',
        'Rarity': 'silver',
        'IsEarned': false,
        'IsApplicableToProfile': true,
        'Progress': {'Current': 4, 'Target': 10, 'Unit': 'count'},
      });

      expect(dto.isEarned, isFalse);
      expect(dto.isApplicableToProfile, isTrue);
      expect(dto.progress, isNotNull);
      expect(dto.progress!.current, 4);
      expect(dto.progress!.target, 10);
      expect(dto.progress!.ratio, closeTo(0.4, 0.0001));
    });

    test('defaults when progress and applicability are absent', () {
      final dto = BadgeDto.fromJson({
        'Id': 'id-2',
        'Key': 'first_quiz',
        'Name': 'İlk Quiz',
        'Description': 'İlk quizini tamamla',
        'Emoji': '📝',
        'Category': 'learning',
        'Rarity': 'bronze',
        'IsEarned': true,
      });

      expect(dto.progress, isNull);
      expect(dto.isApplicableToProfile, isTrue);
    });

    test('ratio is clamped to 1 when current exceeds target', () {
      const p = BadgeProgressDto(current: 15, target: 10, unit: 'count');
      expect(p.ratio, 1.0);
    });
  });
}

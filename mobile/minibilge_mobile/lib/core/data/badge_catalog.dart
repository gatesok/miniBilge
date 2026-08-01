/// Rozet meta verileri (ad, açıklama, emoji, nadirlik).
///
/// Backend seed'i ile (20260620000001_AddBadgeSystem) senkron tutulmalıdır.
/// Sonuç ekranları kazanılan rozet anahtarından zengin overlay göstermek için
/// bu katalogu kullanır.
library;

class BadgeMeta {
  final String emoji;
  final String name;
  final String description;
  final String rarity; // bronze | silver | gold | legendary

  const BadgeMeta({
    required this.emoji,
    required this.name,
    required this.description,
    required this.rarity,
  });
}

const Map<String, BadgeMeta> kBadgeCatalog = {
  // Learning
  'first_quiz': BadgeMeta(
    emoji: '📚',
    name: 'İlk Adım',
    description: 'İlk quiz\'ini tamamladın!',
    rarity: 'bronze',
  ),
  'topic_master': BadgeMeta(
    emoji: '🎓',
    name: 'Konu Ustası',
    description: 'Bir konunun tüm seviyelerini tamamladın',
    rarity: 'silver',
  ),
  'perfectionist': BadgeMeta(
    emoji: '💯',
    name: 'Mükemmeliyetçi',
    description: 'Bir seviyeyi %100 başarıyla bitirdin',
    rarity: 'silver',
  ),
  'busy_bee': BadgeMeta(
    emoji: '🐝',
    name: 'Çalışkan Arı',
    description: 'Tek günde 3 farklı konu çalıştın',
    rarity: 'gold',
  ),
  'math_master': BadgeMeta(
    emoji: '🧮',
    name: 'Sayıların Efendisi',
    description: 'Matematik\'te 10 konu tamamladın',
    rarity: 'gold',
  ),
  'english_a1': BadgeMeta(
    emoji: '🌍',
    name: 'Kelime Avcısı',
    description: 'İngilizce A1 tüm seviyelerini bitirdin',
    rarity: 'silver',
  ),
  'english_b1': BadgeMeta(
    emoji: '🌍',
    name: 'CEFR Yolcusu',
    description: 'İngilizce B1 seviyesine ulaştın',
    rarity: 'gold',
  ),
  // Speed
  'lightning': BadgeMeta(
    emoji: '⚡',
    name: 'Şimşek',
    description: 'Bir soruyu 5 saniyede doğru yanıtladın',
    rarity: 'silver',
  ),
  'speed_train': BadgeMeta(
    emoji: '🚄',
    name: 'Hız Treni',
    description: 'Bir quiz\'i 2 dakika altında bitirdin',
    rarity: 'gold',
  ),
  // Streak
  'streak_3': BadgeMeta(
    emoji: '🔥',
    name: 'Isınıyorum',
    description: '3 günlük seri yaptın',
    rarity: 'bronze',
  ),
  'streak_7': BadgeMeta(
    emoji: '🔥',
    name: 'Ateş Topu',
    description: '7 günlük seri yaptın',
    rarity: 'silver',
  ),
  'streak_30': BadgeMeta(
    emoji: '🌋',
    name: 'Alev Ustası',
    description: '30 günlük seri yaptın',
    rarity: 'legendary',
  ),
  // Match
  'first_win': BadgeMeta(
    emoji: '⚔️',
    name: 'İlk Zafer',
    description: 'İlk canlı yarış galibiyetini kazandın',
    rarity: 'bronze',
  ),
  'win_streak_5': BadgeMeta(
    emoji: '🏹',
    name: 'Zafer Serisi',
    description: 'Arka arkaya 5 yarış kazandın',
    rarity: 'gold',
  ),
  'champion_50': BadgeMeta(
    emoji: '🏆',
    name: 'Turnuva Şampiyonu',
    description: '50 yarış kazandın',
    rarity: 'legendary',
  ),
  // Special
  'early_bird': BadgeMeta(
    emoji: '🌟',
    name: 'Erken Kuş',
    description: 'İlk 100 kullanıcıdan birisin',
    rarity: 'legendary',
  ),
  'beta_hero': BadgeMeta(
    emoji: '🦸',
    name: 'Beta Kahramanı',
    description: 'v1.0 döneminde aktif kullanıcısın',
    rarity: 'gold',
  ),
};

/// Verilen rozet anahtarının meta verisini döndürür (bilinmiyorsa null).
BadgeMeta? badgeMetaFor(String key) => kBadgeCatalog[key];

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
  // Meydan okuma
  'challenge_first_win': BadgeMeta(
    emoji: '⚔️',
    name: 'İlk Meydan Okuma',
    description: 'İlk meydan okuma galibiyetini kazandın',
    rarity: 'bronze',
  ),
  'challenge_wins_10': BadgeMeta(
    emoji: '🗡️',
    name: 'Düello Meraklısı',
    description: 'Toplam 10 meydan okuma kazandın',
    rarity: 'silver',
  ),
  'challenge_wins_50': BadgeMeta(
    emoji: '🏅',
    name: 'Düello Ustası',
    description: 'Toplam 50 meydan okuma kazandın',
    rarity: 'gold',
  ),
  'challenge_streak_5': BadgeMeta(
    emoji: '🔥',
    name: 'Yenilmez Seri',
    description: 'Arka arkaya 5 meydan okuma kazandın',
    rarity: 'gold',
  ),
  'challenge_perfect_win': BadgeMeta(
    emoji: '💯',
    name: 'Kusursuz Düello',
    description: 'Bir meydan okumayı tüm soruları doğru cevaplayarak kazandın',
    rarity: 'silver',
  ),
  'challenge_variety': BadgeMeta(
    emoji: '🎭',
    name: 'Çok Yönlü Rakip',
    description: 'En az 3 farklı kategoride meydan okuma kazandın',
    rarity: 'legendary',
  ),
  // Canlı yarış
  'live_matches_10': BadgeMeta(
    emoji: '🏟️',
    name: 'Arenaya Alışıyorum',
    description: '10 canlı yarış tamamladın',
    rarity: 'bronze',
  ),
  'live_wins_10': BadgeMeta(
    emoji: '🏇',
    name: 'Canlı Yarışçı',
    description: '10 canlı yarış kazandın',
    rarity: 'silver',
  ),
  'live_perfect_win': BadgeMeta(
    emoji: '🎯',
    name: 'Kusursuz Zafer',
    description: 'Bir canlı yarışı tam puanla kazandın',
    rarity: 'gold',
  ),
  'live_comeback': BadgeMeta(
    emoji: '🔄',
    name: 'Geri Dönüş Ustası',
    description: 'Geriden gelerek bir canlı yarış kazandın',
    rarity: 'gold',
  ),
  'live_variety': BadgeMeta(
    emoji: '🧠',
    name: 'Arena Bilgesi',
    description: '3 farklı kategoride canlı yarış kazandın',
    rarity: 'legendary',
  ),
  // Eğlence quizi
  'fun_first_quiz': BadgeMeta(
    emoji: '🎉',
    name: 'Eğlence Başlasın',
    description: 'İlk eğlence quizini tamamladın',
    rarity: 'bronze',
  ),
  'fun_quizzes_10': BadgeMeta(
    emoji: '🧩',
    name: 'Quiz Meraklısı',
    description: '10 eğlence quizi tamamladın',
    rarity: 'silver',
  ),
  'fun_quizzes_50': BadgeMeta(
    emoji: '🎊',
    name: 'Eğlence Bilgesi',
    description: '50 eğlence quizi tamamladın',
    rarity: 'gold',
  ),
  'fun_perfect': BadgeMeta(
    emoji: '⭐',
    name: 'Eğlencede Kusursuz',
    description: 'Bir eğlence quizini %100 tamamladın',
    rarity: 'silver',
  ),
  'fun_categories_5': BadgeMeta(
    emoji: '🗺️',
    name: 'Kategori Kaşifi',
    description: '5 farklı eğlence kategorisinde quiz tamamladın',
    rarity: 'gold',
  ),
  'general_culture_master': BadgeMeta(
    emoji: '🌐',
    name: 'Genel Kültür Ustası',
    description: 'Genel kültürde 10 quiz tamamladın',
    rarity: 'gold',
  ),
  'word_game_master': BadgeMeta(
    emoji: '🔤',
    name: 'Kelime Ustası',
    description: '10 kelime oyunu tamamladın',
    rarity: 'legendary',
  ),
};

/// Verilen rozet anahtarının meta verisini döndürür (bilinmiyorsa null).
BadgeMeta? badgeMetaFor(String key) => kBadgeCatalog[key];

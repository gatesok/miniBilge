import 'package:shared_preferences/shared_preferences.dart';

/// İngilizce Kelime Oyunu — gösterilen DB kelime ID'lerini seviye bazında,
/// oturumlar arası kalıcı tutar (kayan pencere) ki aynı kelimeler kısa sürede
/// tekrar gelmesin. Entertainment modülündeki yaklaşımın birebir eşi.
class EnglishVocabHistoryService {
  EnglishVocabHistoryService._();

  static const int    _maxSeenIds   = 80;
  static const String _seenIdPrefix = 'english_vocab_seen_ids_';

  /// Seviye için son gösterilen kelime ID'lerini döner.
  static Future<List<int>> getSeenIds(String levelCode) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_seenIdPrefix$levelCode') ?? [];
    return raw.map(int.tryParse).whereType<int>().toList();
  }

  /// Gösterilen kelime ID'lerini kaydeder (en fazla son 80 tutulur).
  static Future<void> saveSeenIds(String levelCode, List<int> ids) async {
    if (ids.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_seenIdPrefix$levelCode';
    final existing = prefs.getStringList(key) ?? [];
    final merged = [...existing, ...ids.map((e) => e.toString())];
    final trimmed = merged.length > _maxSeenIds
        ? merged.sublist(merged.length - _maxSeenIds)
        : merged;
    await prefs.setStringList(key, trimmed);
  }
}

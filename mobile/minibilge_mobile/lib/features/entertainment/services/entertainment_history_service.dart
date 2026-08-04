import 'package:shared_preferences/shared_preferences.dart';

/// Eğlence modları için cihaz bazlı geçmiş takibi.
/// GPT'ye "yasak" listesi olarak gönderilir → aynı kullanıcıya tekrar etmez.
class EntertainmentHistoryService {
  EntertainmentHistoryService._();

  // ── Quiz (konu bazlı) ────────────────────────────────────────────────────

  static const int    _maxPerTopic  = 50;
  static const String _quizPrefix   = 'entertainment_asked_';

  /// Quiz: konuya ait geçmiş soru metinlerini döner.
  static Future<List<String>> getAskedQuiz(String topicKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_quizPrefix$topicKey') ?? [];
  }

  /// Quiz: oyun bittikten sonra soru metinlerini kaydeder.
  static Future<void> saveAskedQuiz(
      String topicKey, List<String> questions) async {
    await _appendToKey('$_quizPrefix$topicKey', questions, _maxPerTopic);
  }

  // ── Quiz görülen soru ID'leri (DB tekrarını önlemek için) ────────────────
  // AskedQuestions yalnızca GPT fallback'te kullanılır; DB seçimi ExcludeIds
  // ile filtrelendiğinden, gösterilen ID'ler oturumlar arası burada tutulur.

  static const int    _maxSeenIds  = 80;
  static const String _seenIdPrefix = 'entertainment_seen_ids_';

  /// Quiz: konu + zorluk için son gösterilen soru ID'lerini döner.
  static Future<List<int>> getSeenQuizIds(
      String topicKey, String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_seenIdPrefix${topicKey}_$difficulty') ?? [];
    return raw.map(int.tryParse).whereType<int>().toList();
  }

  /// Quiz: gösterilen DB soru ID'lerini kaydeder (kayan pencere).
  static Future<void> saveSeenQuizIds(
      String topicKey, String difficulty, List<int> ids) async {
    if (ids.isEmpty) return;
    await _appendToKey(
      '$_seenIdPrefix${topicKey}_$difficulty',
      ids.map((e) => e.toString()).toList(),
      _maxSeenIds,
    );
  }

  // ── Gerçek mi Uydurma mı? (zorluk bazlı) ────────────────────────────────

  static const int    _maxPerDifficulty = 60;
  static const String _ffPrefix         = 'ff_asked_';

  /// FF: zorluk seviyesine ait geçmiş ifadeleri döner.
  /// Backend'e ForbiddenStatements olarak gönderilir.
  static Future<List<String>> getAskedFf(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_ffPrefix$difficulty') ?? [];
  }

  /// FF: oyun bittikten sonra gösterilen ifadeleri kaydeder.
  static Future<void> saveAskedFf(
      String difficulty, List<String> statements) async {
    await _appendToKey('$_ffPrefix$difficulty', statements, _maxPerDifficulty);
  }

  // ── Kim Bu? (zorluk bazlı) ───────────────────────────────────────────────

  static const int    _maxPerKimBu = 30;
  static const String _kimBuPrefix = 'kimbu_asked_';

  /// Kim Bu: zorluk seviyesindeki geçmiş konu adlarını döner.
  static Future<List<String>> getAskedKimBu(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_kimBuPrefix$difficulty') ?? [];
  }

  /// Kim Bu: oyun bittikten sonra gösterilen konu adlarını kaydeder.
  static Future<void> saveAskedKimBu(
      String difficulty, List<String> subjects) async {
    await _appendToKey('$_kimBuPrefix$difficulty', subjects, _maxPerKimBu);
  }

  // ── Ne Ortak? (zorluk bazlı) ─────────────────────────────────────────────

  static const int    _maxPerNeOrtak = 40;
  static const String _neOrtakPrefix = 'neortak_asked_';

  /// Ne Ortak: zorluk seviyesinde gösterilen bağlantıları döner.
  static Future<List<String>> getAskedNeOrtak(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_neOrtakPrefix$difficulty') ?? [];
  }

  /// Ne Ortak: oyun bittikten sonra bağlantıları kaydeder.
  static Future<void> saveAskedNeOrtak(
      String difficulty, List<String> connections) async {
    await _appendToKey('$_neOrtakPrefix$difficulty', connections, _maxPerNeOrtak);
  }

  // ── Ortak yardımcı ───────────────────────────────────────────────────────

  static Future<void> _appendToKey(
      String key, List<String> items, int maxCount) async {
    final prefs    = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(key) ?? [];
    final merged   = [...existing, ...items];
    final trimmed  = merged.length > maxCount
        ? merged.sublist(merged.length - maxCount)
        : merged;
    await prefs.setStringList(key, trimmed);
  }

  /// Test / debug için belirli anahtarın geçmişini siler.
  static Future<void> clearKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

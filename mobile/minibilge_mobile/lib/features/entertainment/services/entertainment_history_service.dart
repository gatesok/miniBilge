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

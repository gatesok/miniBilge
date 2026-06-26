import 'package:shared_preferences/shared_preferences.dart';

/// Günlük Telaffuz Koçu hakkını yerel olarak takip eder.
///
/// Kural:
///   - Her çocuk profili için günde 2 ücretsiz değerlendirme (GPT maliyeti nedeniyle az tutuldu).
///   - İlk değerlendirmeden itibaren 24 saat sonra sıfırlanır.
///   - Reklam izlenince +1 hak eklenir (sınırsız reklam izlenebilir).
class PronunciationAttemptStore {
  PronunciationAttemptStore._();

  static const int _freeAttemptsPerDay = 3;
  static const Duration _resetDuration = Duration(hours: 24);

  static String _attemptsKey(String childId) => 'pronunciation_attempts_left_$childId';
  static String _resetAtKey(String childId)  => 'pronunciation_attempts_reset_at_$childId';

  /// Kalan hak sayısını döndürür. Otomatik sıfırlama kontrolü yapar.
  static Future<int> getAttemptsLeft(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfExpired(prefs, childId);
    return prefs.getInt(_attemptsKey(childId)) ?? _freeAttemptsPerDay;
  }

  /// Değerlendirme başlatılınca çağır — 1 hak düşer.
  /// Hak 0'sa false döner.
  static Future<bool> consumeAttempt(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfExpired(prefs, childId);

    final left = prefs.getInt(_attemptsKey(childId)) ?? _freeAttemptsPerDay;
    if (left <= 0) return false;

    if (prefs.getString(_resetAtKey(childId)) == null) {
      await prefs.setString(_resetAtKey(childId), DateTime.now().toIso8601String());
    }

    await prefs.setInt(_attemptsKey(childId), left - 1);
    return true;
  }

  /// Reklam izlenince çağır — 1 hak ekler.
  static Future<void> grantAttempt(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfExpired(prefs, childId);

    final left = prefs.getInt(_attemptsKey(childId)) ?? _freeAttemptsPerDay;
    await prefs.setInt(_attemptsKey(childId), left + 1);
  }

  static Future<void> _resetIfExpired(
      SharedPreferences prefs, String childId) async {
    final raw = prefs.getString(_resetAtKey(childId));
    if (raw == null) return;

    final resetAt = DateTime.tryParse(raw);
    if (resetAt == null) return;

    if (DateTime.now().difference(resetAt) >= _resetDuration) {
      await prefs.setInt(_attemptsKey(childId), _freeAttemptsPerDay);
      await prefs.remove(_resetAtKey(childId));
    }
  }
}

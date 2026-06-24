import 'package:shared_preferences/shared_preferences.dart';

/// Günlük yazma pratiği hakkını yerel olarak takip eder.
///
/// Kural:
///   - Her çocuk profili için günde 3 ücretsiz hak.
///   - İlk pratikten itibaren 24 saat sonra sıfırlanır.
///   - Reklam izlenince +1 hak eklenir (sınırsız reklam izlenebilir).
class WritingAttemptStore {
  WritingAttemptStore._();

  static const int _freeAttemptsPerDay = 3;
  static const Duration _resetDuration = Duration(hours: 24);

  // SharedPreferences key'leri çocuk ID'si ile prefix'lenir.
  static String _attemptsKey(String childId) => 'writing_attempts_left_$childId';
  static String _resetAtKey(String childId) => 'writing_attempts_reset_at_$childId';

  /// Kalan hak sayısını döndürür.
  /// Otomatik olarak sıfırlama kontrolü yapar.
  static Future<int> getAttemptsLeft(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfExpired(prefs, childId);
    return prefs.getInt(_attemptsKey(childId)) ?? _freeAttemptsPerDay;
  }

  /// Değerlendirme başarıyla tamamlanınca çağır — 1 hak düşer.
  /// Hak 0'sa false döner (çağıran kontrol etmeli).
  static Future<bool> consumeAttempt(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfExpired(prefs, childId);

    final left = prefs.getInt(_attemptsKey(childId)) ?? _freeAttemptsPerDay;
    if (left <= 0) return false;

    // İlk tüketimde zamanlayıcıyı başlat.
    if (prefs.getString(_resetAtKey(childId)) == null) {
      await prefs.setString(
        _resetAtKey(childId),
        DateTime.now().toIso8601String(),
      );
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

  /// İlk pratikten 24 saat geçtiyse hakkı 3'e sıfırlar.
  static Future<void> _resetIfExpired(
      SharedPreferences prefs, String childId) async {
    final raw = prefs.getString(_resetAtKey(childId));
    if (raw == null) return; // henüz hiç pratik yapılmamış

    final resetAt = DateTime.tryParse(raw);
    if (resetAt == null) return;

    if (DateTime.now().difference(resetAt) >= _resetDuration) {
      await prefs.setInt(_attemptsKey(childId), _freeAttemptsPerDay);
      await prefs.remove(_resetAtKey(childId));
    }
  }

  /// Sonraki sıfırlama zamanını döndürür (null = henüz timer başlamadı).
  static Future<DateTime?> getResetTime(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_resetAtKey(childId));
    if (raw == null) return null;
    final start = DateTime.tryParse(raw);
    return start?.add(_resetDuration);
  }
}

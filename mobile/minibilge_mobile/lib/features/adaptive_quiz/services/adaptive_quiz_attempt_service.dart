import 'package:shared_preferences/shared_preferences.dart';

/// Günlük AI Quiz hak takibi — 3 ücretsiz / gün, reklam izleyerek +1 kazanılır.
class AdaptiveQuizAttemptService {
  AdaptiveQuizAttemptService._();

  static const _keyDate  = 'ai_quiz_date';
  static const _keyCount = 'ai_quiz_count';
  static const _keyBonus = 'ai_quiz_bonus'; // reklam izleyerek kazanılan
  static const int freePerDay = 3;

  /// Bugün kalan hak sayısı.
  static Future<int> remaining() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    final used  = prefs.getInt(_keyCount) ?? 0;
    final bonus = prefs.getInt(_keyBonus) ?? 0;
    final total = freePerDay + bonus;
    return (total - used).clamp(0, total);
  }

  /// Hak kullan (quiz başlatmadan önce çağırın).
  /// false dönerse hak yok.
  static Future<bool> consume() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    final used  = prefs.getInt(_keyCount) ?? 0;
    final bonus = prefs.getInt(_keyBonus) ?? 0;
    if (used >= freePerDay + bonus) return false;
    await prefs.setInt(_keyCount, used + 1);
    return true;
  }

  /// Reklam izleyince +1 bonus hak ekle.
  static Future<void> addBonus() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    final bonus = prefs.getInt(_keyBonus) ?? 0;
    await prefs.setInt(_keyBonus, bonus + 1);
  }

  static Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final today = DateTime.now().toLocal();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final stored  = prefs.getString(_keyDate) ?? '';
    if (stored != dateKey) {
      await prefs.setString(_keyDate,  dateKey);
      await prefs.setInt(_keyCount, 0);
      await prefs.setInt(_keyBonus, 0);
    }
  }
}

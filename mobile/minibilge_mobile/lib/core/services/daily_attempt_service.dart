import 'package:shared_preferences/shared_preferences.dart';

/// Günlük quiz hak takibi — generic, farklı quiz türleri için kullanılır.
/// [key]: unique identifier (örn: 'ai_quiz', 'entertainment_quiz')
class DailyAttemptService {
  final String _key;
  final int    freePerDay;

  const DailyAttemptService({required String key, this.freePerDay = 3})
      : _key = key;

  String get _dateKey  => '${_key}_date';
  String get _countKey => '${_key}_count';
  String get _bonusKey => '${_key}_bonus';

  Future<int> remaining() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    final used  = prefs.getInt(_countKey) ?? 0;
    final bonus = prefs.getInt(_bonusKey) ?? 0;
    final total = freePerDay + bonus;
    return (total - used).clamp(0, total);
  }

  /// false dönerse hak yok.
  Future<bool> consume() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    final used  = prefs.getInt(_countKey) ?? 0;
    final bonus = prefs.getInt(_bonusKey) ?? 0;
    if (used >= freePerDay + bonus) return false;
    await prefs.setInt(_countKey, used + 1);
    return true;
  }

  Future<void> addBonus() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    final bonus = prefs.getInt(_bonusKey) ?? 0;
    await prefs.setInt(_bonusKey, bonus + 1);
  }

  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final today    = DateTime.now().toLocal();
    final dateKey  = '${today.year}-${today.month}-${today.day}';
    final stored   = prefs.getString(_dateKey) ?? '';
    if (stored != dateKey) {
      await prefs.setString(_dateKey,  dateKey);
      await prefs.setInt(_countKey, 0);
      await prefs.setInt(_bonusKey, 0);
    }
  }
}

/// Adaptif AI quiz için günlük hak servisi.
final adaptiveAttempts  = DailyAttemptService(key: 'ai_quiz');

/// Eğlence quiz için günlük hak servisi.
final entertainmentAttempts = DailyAttemptService(key: 'entertainment_quiz');

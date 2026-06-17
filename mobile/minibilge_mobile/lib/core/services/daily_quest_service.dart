import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class DailyQuestService {
  DailyQuestService._();

  static const int dailyGoal = 5; // Günlük hedef soru sayısı

  /// Bir soru cevaplandığında çağrılır.
  /// Dönüş değeri: (güncel ilerleme, hedef tamamlandı mı)
  static Future<({int progress, bool completed})> recordAnswer(
      String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final storedDate = prefs.getString(
        '${StorageKeys.dailyQuestDatePrefix}$childId');

    int progress;
    if (storedDate != today) {
      // Yeni gün, sıfırdan başla
      progress = 1;
    } else {
      progress = (prefs.getInt(
                  '${StorageKeys.dailyQuestProgressPrefix}$childId') ??
              0) +
          1;
    }

    await prefs.setString(
        '${StorageKeys.dailyQuestDatePrefix}$childId', today);
    await prefs.setInt(
        '${StorageKeys.dailyQuestProgressPrefix}$childId', progress);

    return (progress: progress, completed: progress >= dailyGoal);
  }

  /// Bugünkü ilerlemeyi döner (kaydetmez).
  static Future<int> getTodayProgress(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final storedDate = prefs.getString(
        '${StorageKeys.dailyQuestDatePrefix}$childId');
    if (storedDate != today) return 0;
    return prefs.getInt(
            '${StorageKeys.dailyQuestProgressPrefix}$childId') ??
        0;
  }

  /// Günlük görev bugün tamamlandı mı?
  static Future<bool> isCompletedToday(String childId) async {
    final progress = await getTodayProgress(childId);
    return progress >= dailyGoal;
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

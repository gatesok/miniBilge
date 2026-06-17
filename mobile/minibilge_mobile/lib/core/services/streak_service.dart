import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StreakService {
  StreakService._();

  /// Bugün quiz aktivitesi olduğunu kaydet ve streak'i güncelle.
  /// Dönüş değeri: güncel streak sayısı.
  static Future<int> recordActivity(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastDate = prefs.getString(
        '${StorageKeys.streakLastDatePrefix}$childId');

    int current = prefs.getInt(
            '${StorageKeys.streakCurrentPrefix}$childId') ??
        0;
    int longest = prefs.getInt(
            '${StorageKeys.streakLongestPrefix}$childId') ??
        0;

    if (lastDate == today) {
      // Bugün zaten kayıtlı, streak değişmez
      return current;
    }

    final yesterday = _yesterdayKey();
    if (lastDate == yesterday) {
      // Dün aktifti, zincir devam ediyor
      current++;
    } else {
      // Gün atlandı veya ilk kez, yeniden başlat
      current = 1;
    }

    if (current > longest) longest = current;

    await prefs.setString(
        '${StorageKeys.streakLastDatePrefix}$childId', today);
    await prefs.setInt(
        '${StorageKeys.streakCurrentPrefix}$childId', current);
    await prefs.setInt(
        '${StorageKeys.streakLongestPrefix}$childId', longest);

    return current;
  }

  /// Güncel streak sayısını döner (aktivite kaydetmez).
  static Future<int> getCurrentStreak(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(
            '${StorageKeys.streakCurrentPrefix}$childId') ??
        0;
  }

  /// En uzun streak rekorunu döner.
  static Future<int> getLongestStreak(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(
            '${StorageKeys.streakLongestPrefix}$childId') ??
        0;
  }

  /// Bugün hiç aktivite yapılıp yapılmadığını döner.
  static Future<bool> hasActivityToday(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(
        '${StorageKeys.streakLastDatePrefix}$childId');
    return lastDate == _todayKey();
  }

  /// Streak tehlikede mi? (Dün aktivite vardı ama bugün yok)
  static Future<bool> isStreakAtRisk(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(
        '${StorageKeys.streakLastDatePrefix}$childId');
    final current = prefs.getInt(
            '${StorageKeys.streakCurrentPrefix}$childId') ??
        0;
    if (current == 0) return false;
    // Dün aktifti ama bugün henüz aktivite yok
    return lastDate == _yesterdayKey();
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }
}

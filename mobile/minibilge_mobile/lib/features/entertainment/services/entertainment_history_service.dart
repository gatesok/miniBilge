import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Her konu için son 50 soru metnini cihazda saklar.
/// GPT'ye "yasak sorular" listesi olarak gönderilir → tekrar önlenir.
class EntertainmentHistoryService {
  EntertainmentHistoryService._();

  static const int _maxPerTopic = 50;
  static const String _prefix   = 'entertainment_asked_';

  /// Konuya ait geçmiş soru metinlerini döner.
  static Future<List<String>> getAsked(String topicKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList('$_prefix$topicKey') ?? [];
    return raw;
  }

  /// Quiz bittikten sonra yeni soru metinlerini kaydeder.
  /// Liste _maxPerTopic'i aşarsa en eski sorular silinir.
  static Future<void> saveAsked(
      String topicKey, List<String> newQuestions) async {
    final prefs    = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('$_prefix$topicKey') ?? [];
    final merged   = [...existing, ...newQuestions];
    final trimmed  = merged.length > _maxPerTopic
        ? merged.sublist(merged.length - _maxPerTopic)
        : merged;
    await prefs.setStringList('$_prefix$topicKey', trimmed);
  }

  /// Test / debug için konunun geçmişini siler.
  static Future<void> clearTopic(String topicKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$topicKey');
  }
}

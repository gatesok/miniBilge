import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Episode dinleme ilerlemesini yerel olarak saklar.
/// [progressNotifier] tüm uygulama genelinde reaktif olarak izlenebilir.
class PodcastProgressStore {
  static const _key = 'podcast_progress_v1';

  /// episodeId → 0.0 … 1.0 (tamamlanma oranı)
  static final progressNotifier = ValueNotifier<Map<String, double>>({});

  /// Episode listesi yüklenince çağır — SharedPrefs'ten progress'i okur.
  /// Notifier tamamen bu profilin verisiyle yenilenir (diğer profil verisi temizlenir).
  static Future<void> loadAll(List<String> episodeIds,
      {required String profileId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_key}_$profileId';
    final raw = prefs.getString(key);

    // Sıfırdan oluştur — sadece bu profilin verisi
    final fresh = <String, double>{};
    if (raw != null) {
      final stored = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      for (final id in episodeIds) {
        if (stored.containsKey(id)) {
          final data = stored[id] as Map<String, dynamic>;
          final line  = (data['line']  as int? ?? 0) + 1;
          final total = (data['total'] as int? ?? 1);
          fresh[id] = (line / total).clamp(0.0, 1.0);
        }
      }
    }

    // Merge değil, replace: eski profil verisi temizlenir
    progressNotifier.value = fresh;
  }

  /// Oynatıcı yeni bir satıra geçince çağır.
  static Future<void> saveProgress(
      String episodeId, int lineIndex, int totalLines,
      {required String profileId}) async {
    // Notifier anlık güncelle (UI reaktif)
    final updated = Map<String, double>.from(progressNotifier.value);
    updated[episodeId] = ((lineIndex + 1) / totalLines).clamp(0.0, 1.0);
    progressNotifier.value = updated;

    // Disk'e yaz (profil bazında)
    final prefs = await SharedPreferences.getInstance();
    final key = '${_key}_$profileId';
    final raw = prefs.getString(key);
    final stored = raw != null
        ? Map<String, dynamic>.from(jsonDecode(raw) as Map)
        : <String, dynamic>{};
    stored[episodeId] = {'line': lineIndex, 'total': totalLines};
    await prefs.setString(key, jsonEncode(stored));
  }
}

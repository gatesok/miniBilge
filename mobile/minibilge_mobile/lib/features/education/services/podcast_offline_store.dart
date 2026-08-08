import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/podcast_models.dart';

/// Premium kullanıcının açıkça indirdiği podcast metinlerini cihazda saklar.
/// Ses, çevrimdışı TTS ile üretildiği için bölüm metnini saklamak yeterlidir.
class PodcastOfflineStore {
  static const _episodePrefix = 'podcast_offline_episode_';
  static const _listPrefix = 'podcast_offline_list_';

  static Future<void> saveEpisode(PodcastEpisode episode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_episodePrefix${episode.id}',
      jsonEncode(episode.toJson()),
    );
  }

  static Future<PodcastEpisode?> getEpisode(String episodeId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_episodePrefix$episodeId');
    if (raw == null) return null;
    return PodcastEpisode.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<bool> isDownloaded(String episodeId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_episodePrefix$episodeId');
  }

  static Future<void> removeEpisode(String episodeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_episodePrefix$episodeId');
  }

  static Future<void> saveList(
    int level,
    List<PodcastEpisodeSummary> episodes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_listPrefix$level',
      jsonEncode(episodes.map((episode) => episode.toJson()).toList()),
    );
  }

  static Future<List<PodcastEpisodeSummary>> getList(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_listPrefix$level');
    if (raw == null) return const [];
    final values = jsonDecode(raw) as List<dynamic>;
    return values
        .map(
          (value) =>
              PodcastEpisodeSummary.fromJson(value as Map<String, dynamic>),
        )
        .toList();
  }
}

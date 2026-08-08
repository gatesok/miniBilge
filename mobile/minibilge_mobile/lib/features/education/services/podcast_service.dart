import 'package:dio/dio.dart';
import '../models/podcast_models.dart';
import 'podcast_offline_store.dart';

class PodcastService {
  final Dio _dio;

  PodcastService(this._dio);

  /// Belirli CEFR seviyesindeki episode özetlerini getirir.
  /// [level]: 1=A1 … 6=C2
  Future<List<PodcastEpisodeSummary>> getEpisodesByLevel(int level) async {
    try {
      final response = await _dio.get(
        '/podcast',
        queryParameters: {'level': level},
      );
      final List<dynamic> data = response.data;
      final episodes = data
          .map((json) => PodcastEpisodeSummary.fromJson(json))
          .toList();
      await PodcastOfflineStore.saveList(level, episodes);
      return episodes;
    } catch (e) {
      final cached = await PodcastOfflineStore.getList(level);
      if (cached.isNotEmpty) return cached;
      throw Exception('Podcast listesi yüklenirken hata oluştu: $e');
    }
  }

  /// Belirli episode'un tüm satırlarıyla birlikte detayını getirir.
  Future<PodcastEpisode> getEpisode(String episodeId) async {
    try {
      final response = await _dio.get('/podcast/$episodeId');
      return PodcastEpisode.fromJson(response.data);
    } catch (e) {
      final cached = await PodcastOfflineStore.getEpisode(episodeId);
      if (cached != null) return cached;
      throw Exception('Podcast yüklenirken hata oluştu: $e');
    }
  }
}

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_api_service.dart';
import '../services/leaderboard_hub_service.dart';
import '../services/leaderboard_service_provider.dart';
import 'leaderboard_state.dart';

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final LeaderboardApiService _apiService;
  final LeaderboardHubService _hubService;
  StreamSubscription<List<LeaderboardEntry>>? _hubSubscription;

  LeaderboardNotifier(this._apiService, this._hubService)
      : super(const LeaderboardState.initial());

  /// REST API'den leaderboard yükle
  Future<void> loadLeaderboard(String childProfileId) async {
    state = const LeaderboardState.loading();
    try {
      final results = await Future.wait([
        _apiService.getLeaderboard(topN: 15),
        _apiService.getChildRank(childProfileId),
      ]);

      state = LeaderboardState.loaded(
        entries: results[0] as List<LeaderboardEntry>,
        myEntry: results[1] as LeaderboardEntry?,
      );
    } catch (e) {
      state = LeaderboardState.error('Sıralama yüklenirken bir hata oluştu');
    }
  }

  /// SignalR Hub'a bağlan ve realtime güncellemeleri dinle
  Future<void> connectHub(String accessToken, String childProfileId) async {
    try {
      print('🔌 [Provider] Hub bağlantısı başlatılıyor...');
      await _hubService.connect(accessToken);

      _hubSubscription?.cancel();
      _hubSubscription = _hubService.leaderboardStream.listen(
        (entries) {
          print('📊 [Provider] Stream\'den ${entries.length} entry geldi!');
          // Realtime güncelleme geldi
          final myEntry = state.maybeWhen(
            loaded: (_, current) => current,
            orElse: () => null,
          );

          // Kendi sıramızı güncel entries'den bul
          final updatedMyEntry = entries.where(
            (e) => e.childProfileId == (myEntry?.childProfileId ?? ''),
          ).firstOrNull ?? myEntry;

          print('✅ [Provider] State güncelleniyor...');
          state = LeaderboardState.loaded(
            entries: entries,
            myEntry: updatedMyEntry,
          );
          print('✅ [Provider] State güncellendi!');
        },
        onError: (e) {
          print('❌ [Provider] Stream hatası: $e');
          // SignalR hatası olsa bile mevcut state'i koruyoruz
        },
        cancelOnError: false,
      );
      print('✅ [Provider] Stream dinlemeye başlandı!');
    } catch (e) {
      print('❌ [Provider] Hub bağlantı hatası: $e');
      // Hub bağlantısı başarısız olsa da REST data gösterilmeye devam eder
    }
  }

  /// Hub bağlantısını kes
  Future<void> disconnectHub() async {
    _hubSubscription?.cancel();
    _hubSubscription = null;
    await _hubService.disconnect();
  }

  @override
  void dispose() {
    _hubSubscription?.cancel();
    super.dispose();
  }
}

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  final apiService = ref.watch(leaderboardApiServiceProvider);
  final hubService = ref.watch(leaderboardHubServiceProvider);
  return LeaderboardNotifier(apiService, hubService);
});

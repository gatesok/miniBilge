import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardHubService {
  static const String _hubUrl = 'https://minibilge-api-465589060611.us-central1.run.app/hubs/leaderboard';

  HubConnection? _connection;
  final _leaderboardController = StreamController<List<LeaderboardEntry>>.broadcast();

  Stream<List<LeaderboardEntry>> get leaderboardStream => _leaderboardController.stream;

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  Future<void> connect(String accessToken) async {
    if (isConnected) {
      debugPrint('ℹ️ [SignalR] Zaten bağlı!');
      return;
    }

    debugPrint('🔄 [SignalR] Bağlantı kuruluyor...');
    _connection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => accessToken,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('ReceiveLeaderboardUpdate', (arguments) {
      debugPrint('🔔 [SignalR] ReceiveLeaderboardUpdate mesajı alındı!');
      if (arguments == null || arguments.isEmpty) {
        debugPrint('❌ [SignalR] Arguments boş!');
        return;
      }
      try {
        final rawList = arguments[0] as List<dynamic>;
        debugPrint('✅ [SignalR] ${rawList.length} entry parse ediliyor...');
        debugPrint('📦 [SignalR] Raw JSON: $rawList');
        final entries = rawList
            .map((e) {
              debugPrint('🔍 Entry: $e');
              return LeaderboardEntry.fromJson(e as Map<String, dynamic>);
            })
            .toList();
        _leaderboardController.add(entries);
        debugPrint('✅ [SignalR] Stream güncellendi!');
      } catch (e, stackTrace) {
        debugPrint('❌ [SignalR] Parse hatası: $e');
        debugPrint('📋 [SignalR] Stack: $stackTrace');
        // Parse hatası durumunda stream'e hata yollamıyoruz
      }
    });

    _connection!.onreconnecting(({error}) {
      debugPrint('🔄 [SignalR] Yeniden bağlanma girişimi...');
    });

    _connection!.onreconnected(({connectionId}) {
      debugPrint('✅ [SignalR] Yeniden bağlandı! Connection ID: $connectionId');
    });

    await _connection!.start();
    debugPrint('✅ [SignalR] Bağlantı başarılı! State: ${_connection!.state}');
  }

  Future<void> disconnect() async {
    debugPrint('🔌 [SignalR] Bağlantı kesiliyor...');
    await _connection?.stop();
    _connection = null;
    debugPrint('✅ [SignalR] Bağlantı kesildi!');
  }

  void dispose() {
    disconnect();
    _leaderboardController.close();
  }
}

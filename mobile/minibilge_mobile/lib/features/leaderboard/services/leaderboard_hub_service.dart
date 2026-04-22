import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardHubService {
  static const String _hubUrl = 'http://localhost:5077/hubs/leaderboard';

  HubConnection? _connection;
  final _leaderboardController = StreamController<List<LeaderboardEntry>>.broadcast();

  Stream<List<LeaderboardEntry>> get leaderboardStream => _leaderboardController.stream;

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  Future<void> connect(String accessToken) async {
    if (isConnected) {
      print('ℹ️ [SignalR] Zaten bağlı!');
      return;
    }

    print('🔄 [SignalR] Bağlantı kuruluyor...');
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
      print('🔔 [SignalR] ReceiveLeaderboardUpdate mesajı alındı!');
      if (arguments == null || arguments.isEmpty) {
        print('❌ [SignalR] Arguments boş!');
        return;
      }
      try {
        final rawList = arguments[0] as List<dynamic>;
        print('✅ [SignalR] ${rawList.length} entry parse ediliyor...');
        print('📦 [SignalR] Raw JSON: $rawList');
        final entries = rawList
            .map((e) {
              print('🔍 Entry: $e');
              return LeaderboardEntry.fromJson(e as Map<String, dynamic>);
            })
            .toList();
        _leaderboardController.add(entries);
        print('✅ [SignalR] Stream güncellendi!');
      } catch (e, stackTrace) {
        print('❌ [SignalR] Parse hatası: $e');
        print('📋 [SignalR] Stack: $stackTrace');
        // Parse hatası durumunda stream'e hata yollamıyoruz
      }
    });

    _connection!.onreconnecting(({error}) {
      print('🔄 [SignalR] Yeniden bağlanma girişimi...');
    });

    _connection!.onreconnected(({connectionId}) {
      print('✅ [SignalR] Yeniden bağlandı! Connection ID: $connectionId');
    });

    await _connection!.start();
    print('✅ [SignalR] Bağlantı başarılı! State: ${_connection!.state}');
  }

  Future<void> disconnect() async {
    print('🔌 [SignalR] Bağlantı kesiliyor...');
    await _connection?.stop();
    _connection = null;
    print('✅ [SignalR] Bağlantı kesildi!');
  }

  void dispose() {
    disconnect();
    _leaderboardController.close();
  }
}

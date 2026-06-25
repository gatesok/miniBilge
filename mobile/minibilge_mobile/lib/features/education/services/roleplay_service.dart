import 'package:dio/dio.dart';
import '../models/roleplay_models.dart';

class RolePlayService {
  final Dio _dio;

  RolePlayService(this._dio);

  /// Belirtilen seviyedeki senaryoları listeler.
  Future<List<ScenarioDto>> getScenarios(String level) async {
    try {
      final response = await _dio.get('/roleplay/scenarios', queryParameters: {'level': level});
      final list = response.data as List<dynamic>;
      return list.map((e) => ScenarioDto.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Senaryolar yüklenemedi: $e');
    }
  }

  /// Yeni oturum başlatır, yapay zekanın ilk mesajını döner.
  Future<StartRolePlayResponse> startSession({
    required String childProfileId,
    required String scenarioKey,
    required String level,
  }) async {
    try {
      final response = await _dio.post('/roleplay/start', data: {
        'ChildProfileId': childProfileId,
        'ScenarioKey': scenarioKey,
        'Level': level,
      });
      return StartRolePlayResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Oturum başlatılamadı: $e');
    }
  }

  /// Kullanıcı mesajını gönderir, AI yanıtını döner.
  Future<SendTurnResponse> sendTurn({
    required String sessionId,
    required String userMessage,
  }) async {
    try {
      final response = await _dio.post('/roleplay/turn', data: {
        'SessionId': sessionId,
        'UserMessage': userMessage,
      });
      return SendTurnResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Mesaj gönderilemedi: $e');
    }
  }

  /// Oturumu tamamlar, nihai değerlendirme ve ödülleri döner.
  Future<EndSessionResponse> endSession({
    required String sessionId,
    String? childProfileId,
  }) async {
    try {
      final response = await _dio.post('/roleplay/end', data: {
        'SessionId': sessionId,
        if (childProfileId != null) 'ChildProfileId': childProfileId,
      });
      return EndSessionResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Oturum tamamlanamadı: $e');
    }
  }
}

import 'package:dio/dio.dart';
import '../models/flashcard_models.dart';

class FlashcardService {
  final Dio _dio;

  FlashcardService(this._dio);

  Future<List<FlashcardDeck>> getDecksByLevel(int level, String childId) async {
    try {
      final response = await _dio.get(
        '/flashcard/decks',
        queryParameters: {'level': level, 'childId': childId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => FlashcardDeck.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Flashcard desteleri yüklenirken hata oluştu: $e');
    }
  }

  Future<List<FlashcardItem>> getCards(String deckId, String childId) async {
    try {
      final response = await _dio.get(
        '/flashcard/decks/$deckId/cards',
        queryParameters: {'childId': childId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => FlashcardItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Kartlar yüklenirken hata oluştu: $e');
    }
  }

  Future<FlashcardDeck?> getDeckByEpisode(
      String episodeId, String childId) async {
    try {
      final response = await _dio.get(
        '/flashcard/episode/$episodeId',
        queryParameters: {'childId': childId},
      );
      return FlashcardDeck.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception('Episode destesi yüklenirken hata oluştu: $e');
    }
  }

  Future<void> markCard(
      String flashcardId, String childProfileId, bool isLearned) async {
    try {
      await _dio.post(
        '/flashcard/cards/$flashcardId/mark',
        data: {'ChildProfileId': childProfileId, 'IsLearned': isLearned},
      );
    } catch (e) {
      throw Exception('Kart işaretlenirken hata oluştu: $e');
    }
  }

  Future<FlashcardSessionResult> completeSession(
      String deckId, String childId) async {
    try {
      final response = await _dio.post(
        '/flashcard/decks/$deckId/complete',
        queryParameters: {'childId': childId},
      );
      return FlashcardSessionResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Oturum tamamlanırken hata oluştu: $e');
    }
  }
}

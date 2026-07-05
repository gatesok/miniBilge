import '../../../core/services/daily_attempt_service.dart';

/// Adaptif AI quiz için günlük hak takibi.
/// DailyAttemptService üzerine ince bir sarmalayıcı.
class AdaptiveQuizAttemptService {
  AdaptiveQuizAttemptService._();

  static const int freePerDay = 3;

  static Future<int>  remaining()  => adaptiveAttempts.remaining();
  static Future<bool> consume()    => adaptiveAttempts.consume();
  static Future<void> addBonus()   => adaptiveAttempts.addBonus();
}

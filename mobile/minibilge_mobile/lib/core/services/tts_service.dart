import 'package:flutter_tts/flutter_tts.dart';

/// Basit TTS servisi. İngilizce için en-US, Türkçe için tr-TR kullanır.
/// Quiz ekranında her yeni soruda [speak] çağrılır; ekrandan çıkılınca [stop].
class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static bool _isSpeaking = false;

  static bool get isSpeaking => _isSpeaking;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    await _tts.setSharedInstance(true); // iOS: diğer seslerle birlikte çal
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.ambient,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.defaultMode,
    );

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) => _isSpeaking = false);
  }

  /// [language]: 'en' → İngilizce, diğer → Türkçe
  static Future<void> speak(String text, {String language = 'tr'}) async {
    await _ensureInitialized();
    await _tts.stop();

    final lang = language == 'en' ? 'en-US' : 'tr-TR';
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(language == 'en' ? 0.42 : 0.50); // İngilizce biraz yavaş
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05); // Çocuklar için biraz yüksek

    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }
}

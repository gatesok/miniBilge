import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS servisi.
/// - [speak]: Quiz/genel kullanım (tek ses)
/// - [speakWithVoice]: Podcast çok sesli kullanım — belirli bir ses ile okur
/// - [onCompleted]: Podcast player'ın sıradaki satıra geçmesi için stream
class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static bool _isSpeaking = false;

  // Podcast için completion stream
  static final StreamController<void> _completionController =
      StreamController<void>.broadcast();
  static Stream<void> get onCompleted => _completionController.stream;

  static bool get isSpeaking => _isSpeaking;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    await _tts.setSharedInstance(true);
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
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _completionController.add(null);
    });
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) {
      _isSpeaking = false;
      _completionController.add(null); // hata durumunda da ilerle
    });
  }

  /// Genel kullanım (quiz vb.) — tek ses, dil bazlı.
  static Future<void> speak(String text, {String language = 'tr'}) async {
    await _ensureInitialized();
    await _tts.stop();

    final lang = language == 'en' ? 'en-US' : 'tr-TR';
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(language == 'en' ? 0.42 : 0.50);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);

    await _tts.speak(text);
  }

  /// Podcast çok sesli okuma.
  /// [voiceName]: iOS'ta cihaz sesi adı (ör. "com.apple.ttsbundle.Samantha-compact")
  /// [gender]: 0=Male, 1=Female — ses ataması yapılamadığında pitch ile simüle edilir
  /// [rate]: konuşma hızı (0.0–1.0); varsayılan B2 için 0.40
  static Future<void> speakWithVoice(
    String text, {
    String? voiceName,
    int gender = 0,
    double rate = 0.40,
  }) async {
    await _ensureInitialized();
    await _tts.stop();

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(rate);
    await _tts.setVolume(1.0);

    if (voiceName != null) {
      // iOS: belirli ses (cihazda yüklü olmalı)
      await _tts.setVoice({'name': voiceName, 'locale': 'en-US'});
      await _tts.setPitch(1.0);
    } else {
      // Fallback: pitch ile erkek/kadın farkı simüle et
      await _tts.setPitch(gender == 1 ? 1.25 : 0.85);
    }

    await _tts.speak(text);
  }

  /// Cihazda kullanılabilir en-US seslerini döndürür.
  /// [{name: "...", locale: "en-US"}, ...]
  static Future<List<Map<String, String>>> getEnglishVoices() async {
    await _ensureInitialized();
    final voices = await _tts.getVoices as List<dynamic>? ?? [];
    return voices
        .cast<Map<dynamic, dynamic>>()
        .where((v) {
          final locale = (v['locale'] as String? ?? '').toLowerCase();
          return locale.startsWith('en');
        })
        .map((v) => {
              'name': (v['name'] as String?) ?? '',
              'locale': (v['locale'] as String?) ?? 'en-US',
            })
        .where((v) => v['name']!.isNotEmpty)
        .toList();
  }

  static Future<void> pause() async {
    await _tts.pause();
    _isSpeaking = false;
  }

  static Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }
}

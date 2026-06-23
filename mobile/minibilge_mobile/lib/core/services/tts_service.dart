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
  // iOS audio-session interrupt'larını (bildirim, BT, vb.) kendi durdurduğumuzdan
  // ayırt etmek için flag. Kasıtlı stop() çağrısı sırasında true yapılır.
  static bool _intentionalStop = false;

  // Podcast için completion stream
  static final StreamController<void> _completionController =
      StreamController<void>.broadcast();
  static Stream<void> get onCompleted => _completionController.stream;

  // Kelime highlight için progress stream
  // ({start, end}): aktif satır içindeki karakter pozisyonları
  static final StreamController<({int start, int end})> _progressController =
      StreamController<({int start, int end})>.broadcast();
  static Stream<({int start, int end})> get onWordBoundary =>
      _progressController.stream;

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
    // cancelHandler: iOS'un interrupt ettiği durumda (bildirim, telefon,
    // Bluetooth vb.) da sonraki satıra geçilmesi için completion emit et.
    // Sadece kasıtlı stop() çağrısı sırasında (_intentionalStop=true) emit etme.
    _tts.setCancelHandler(() {
      _isSpeaking = false;
      if (!_intentionalStop) {
        _completionController.add(null);
      }
    });
    _tts.setErrorHandler((_) {
      _isSpeaking = false;
      _completionController.add(null);
    });
    // Kelime sınırı — iOS AVSpeechSynthesizer destekler
    _tts.setProgressHandler((String text, int start, int end, String word) {
      _progressController.add((start: start, end: end));
    });
  }

  /// Genel kullanım (quiz vb.) — tek ses, dil bazlı.
  static Future<void> speak(String text, {String language = 'tr'}) async {
    await _ensureInitialized();
    _intentionalStop = true;
    await _tts.stop();
    _intentionalStop = false;

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
    _intentionalStop = true;
    await _tts.stop();
    _intentionalStop = false;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(rate);
    await _tts.setVolume(1.0);

    if (voiceName != null) {
      // iOS: belirli ses — önce sesi ayarla
      await _tts.setVoice({'name': voiceName, 'locale': 'en-US'});
    }
    // Cinsiyet bazlı pitch: ses atanmış olsa da olmasa da her zaman uygulanır.
    // Erkek: 0.65 — ~8 yarı ton aşağı, belirgin bariton; enhanced seste artefaktsız.
    // Kadın: 1.0 — doğal Samantha tonu.
    await _tts.setPitch(gender == 1 ? 1.0 : 0.58);

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
    _intentionalStop = true;
    await _tts.stop();
    _intentionalStop = false;
    _isSpeaking = false;
  }

  /// Podcast için yüksek kalite ses modu.
  /// iOS AVAudioSession.Mode.spokenAudio: diğer konuşma seslerini durdurur,
  /// daha temiz / daha az mekanik çıkış sağlar.
  static Future<void> configurePodcastMode() async {
    await _ensureInitialized();
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      ],
      IosTextToSpeechAudioMode.spokenAudio,
    );
  }

  /// Podcast bitince genel (ambient) moda dön.
  static Future<void> configureAmbientMode() async {
    await _ensureInitialized();
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.ambient,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.defaultMode,
    );
  }
}

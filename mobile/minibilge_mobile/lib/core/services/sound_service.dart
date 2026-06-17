import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  SoundService._();

  static const String _soundEnabledKey = 'sound_enabled';

  static bool _enabled = true;
  static bool _initialized = false;

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_soundEnabledKey) ?? true;
  }

  static bool get isEnabled => _enabled;

  static Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  static Future<void> _play(String asset) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$asset'));
    } catch (_) {}
  }

  static Future<void> playCorrect() => _play('correct.mp3');
  static Future<void> playWrong() => _play('wrong.mp3');
  static Future<void> playCombo() => _play('combo.mp3');
  static Future<void> playLevelUp() => _play('level_up.mp3');
  static Future<void> playWin() => _play('win.mp3');
  static Future<void> playLose() => _play('lose.mp3');
  static Future<void> playTap() => _play('tap.mp3');
}

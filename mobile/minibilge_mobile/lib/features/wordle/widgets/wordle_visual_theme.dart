import 'package:flutter/material.dart';

/// Kelime Oyunu'nun günlük ve seviye akışlarında ortak kullanılan görsel dil.
/// Oyun kurallarını değil, yalnızca yüzey renklerini ve durum tonlarını yönetir.
abstract final class WordleVisualTheme {
  static const sky = Color(0xFF74C5F3);
  static const lavender = Color(0xFFAE91E4);
  static const indigo = Color(0xFF5968D9);
  static const ink = Color(0xFF24315F);
  static const mutedInk = Color(0xFF66739B);
  static const surface = Color(0xFFF9FBFF);
  static const tile = Color(0xFFF5F7FF);
  static const filledTile = Color(0xFFE4ECFF);
  static const tileBorder = Color(0xFFB7C8ED);
  static const correct = Color(0xFF3DBA70);
  static const present = Color(0xFFFFB83D);
  static const absent = Color(0xFF8A96B8);
  static const key = Color(0xFFF8FAFF);
  static const specialKey = Color(0xFF6070DC);
  static const joker = Color(0xFF9A66E8);
  static const hint = Color(0xFF3F8FDC);
  static const error = Color(0xFFE36E7A);
  static const star = Color(0xFFFFC33D);

  static List<Color> backgroundForLevel(int level) {
    if (level <= 25) {
      return const [Color(0xFF7DCBF6), Color(0xFFB69BE8)];
    }
    if (level <= 75) {
      return const [Color(0xFF72BEEF), Color(0xFFAD90E3)];
    }
    if (level <= 150) {
      return const [Color(0xFF68B3E9), Color(0xFFA182D9)];
    }
    return const [Color(0xFF5C9DDD), Color(0xFF9272CC)];
  }

  static Color tileColor(String? status, {required bool hasLetter}) =>
      switch (status) {
        'correct' => correct,
        'present' => present,
        'absent' => absent,
        _ => hasLetter ? filledTile : tile,
      };

  static Color tileTextColor(String? status) =>
      status == null ? ink : Colors.white;

  static Color keyColor(String? status) => switch (status) {
    'correct' => correct,
    'present' => present,
    'absent' => absent,
    _ => key,
  };

  static Color keyTextColor(String? status) =>
      status == null ? ink : Colors.white;
}

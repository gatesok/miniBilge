import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/challenge_history.dart';
import '../models/entertainment_stats.dart';
import '../models/weak_topic.dart';
import '../models/weekly_summary.dart';

/// Builds and shares a sanitized parent report.
///
/// Security: the exported text intentionally excludes any identifier
/// (child id, parent email, GUIDs) and any other child's data. Only the
/// selected child's first name and aggregate statistics are included so a
/// shared report cannot leak personal or cross-profile information.
class ReportExportService {
  const ReportExportService();

  /// Returns only the first name token to avoid leaking a full legal name.
  static String sanitizeName(String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return 'Çocuk';
    final firstToken = trimmed.split(RegExp(r'\s+')).first;
    return firstToken;
  }

  /// Builds the plain-text report body. Pure and side-effect free so it can
  /// be unit tested for data-leak safety.
  static String buildReportText({
    required String childName,
    required WeeklySummary weekly,
    required List<WeakTopic> weakTopics,
    EntertainmentStats? entertainment,
    ChallengeHistory? challenge,
  }) {
    final name = sanitizeName(childName);
    final dateFmt = DateFormat('d MMM', 'tr');
    final period =
        '${dateFmt.format(weekly.weekStart)} - ${dateFmt.format(weekly.weekEnd)}';
    final rate = (weekly.correctAnswerRate * 100).round();

    final buffer = StringBuffer()
      ..writeln('📊 $name – Haftalık Gelişim Özeti')
      ..writeln('Dönem: $period')
      ..writeln('')
      ..writeln('• Çözülen soru: ${weekly.totalQuestionsAnswered}')
      ..writeln('• Doğruluk: %$rate')
      ..writeln('• Aktif gün: ${weekly.activeDays}')
      ..writeln('• Tamamlanan bölüm: ${weekly.levelsCompleted}')
      ..writeln('• Kazanılan yıldız: ${weekly.totalStarsEarned}');

    if (weekly.subjectBreakdown.isNotEmpty) {
      buffer
        ..writeln('')
        ..writeln('Derslere göre:');
      for (final subject in weekly.subjectBreakdown) {
        final subjectRate = (subject.correctAnswerRate * 100).round();
        buffer.writeln(
          '• ${subject.subjectName}: ${subject.totalQuestions} soru, %$subjectRate doğru',
        );
      }
    }

    if (weakTopics.isNotEmpty) {
      buffer
        ..writeln('')
        ..writeln('Gelişmesi gereken konular:');
      for (final topic in weakTopics.take(5)) {
        final topicRate = (topic.successRate * 100).round();
        buffer.writeln('• ${topic.topicName} (${topic.subjectName}): %$topicRate');
      }
    }

    if (entertainment != null && entertainment.totalPlayed > 0) {
      final entRate = (entertainment.averageSuccessRate * 100).round();
      buffer
        ..writeln('')
        ..writeln('Eğlence quizleri:')
        ..writeln(
          '• Oynanan: ${entertainment.totalPlayed}, Kazanılan: ${entertainment.totalWon}',
        )
        ..writeln('• Ortalama başarı: %$entRate');
      if (entertainment.perfectWins > 0) {
        buffer.writeln('• Kusursuz galibiyet: ${entertainment.perfectWins}');
      }
      for (final category in entertainment.categories.take(5)) {
        final categoryRate = (category.averageSuccessRate * 100).round();
        buffer.writeln(
          '• ${category.categoryName}: ${category.played} oyun, %$categoryRate başarı',
        );
      }
    }

    if (challenge != null && challenge.totalCompleted > 0) {
      buffer
        ..writeln('')
        ..writeln('Meydan okuma:')
        ..writeln(
          '• Tamamlanan: ${challenge.totalCompleted} (${challenge.won} galibiyet, ${challenge.tie} beraberlik, ${challenge.lost} mağlubiyet)',
        );
      for (final category in challenge.categories.take(5)) {
        final winRate = (category.winRate * 100).round();
        buffer.writeln(
          '• ${category.category}: ${category.played} maç, %$winRate galibiyet',
        );
      }
    }

    buffer
      ..writeln('')
      ..writeln('MiniBilge ile hazırlandı.');

    return buffer.toString();
  }

  /// Opens the native share sheet with the sanitized report.
  Future<void> shareReport({
    required String childName,
    required WeeklySummary weekly,
    required List<WeakTopic> weakTopics,
    EntertainmentStats? entertainment,
    ChallengeHistory? challenge,
    Rect? sharePositionOrigin,
  }) async {
    final text = buildReportText(
      childName: childName,
      weekly: weekly,
      weakTopics: weakTopics,
      entertainment: entertainment,
      challenge: challenge,
    );
    final name = sanitizeName(childName);
    await Share.share(
      text,
      subject: '$name – MiniBilge Gelişim Raporu',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}

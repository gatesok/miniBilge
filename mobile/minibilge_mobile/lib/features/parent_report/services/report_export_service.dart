import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

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
    Rect? sharePositionOrigin,
  }) async {
    final text = buildReportText(
      childName: childName,
      weekly: weekly,
      weakTopics: weakTopics,
    );
    final name = sanitizeName(childName);
    await Share.share(
      text,
      subject: '$name – MiniBilge Gelişim Raporu',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}

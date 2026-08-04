import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:minibilge_mobile/features/parent_report/models/challenge_history.dart';
import 'package:minibilge_mobile/features/parent_report/models/entertainment_stats.dart';
import 'package:minibilge_mobile/features/parent_report/models/subject_summary.dart';
import 'package:minibilge_mobile/features/parent_report/models/weak_topic.dart';
import 'package:minibilge_mobile/features/parent_report/models/weekly_summary.dart';
import 'package:minibilge_mobile/features/parent_report/services/report_export_service.dart';

void main() {
  setUpAll(() => initializeDateFormatting('tr', null));

  final weekly = WeeklySummary(
    childId: '11111111-1111-1111-1111-111111111111',
    weekStart: DateTime(2026, 7, 27),
    weekEnd: DateTime(2026, 8, 2),
    totalQuestionsAnswered: 120,
    correctAnswers: 96,
    wrongAnswers: 24,
    correctAnswerRate: 0.8,
    levelsCompleted: 6,
    totalPointsEarned: 1500,
    totalStarsEarned: 18,
    activeDays: 5,
    dailyBreakdown: const [],
    subjectBreakdown: const [
      SubjectSummary(
        subjectName: 'Matematik',
        totalQuestions: 70,
        correctAnswers: 60,
        wrongAnswers: 10,
        correctAnswerRate: 0.857,
      ),
    ],
  );

  const weakTopics = [
    WeakTopic(
      topicId: '22222222-2222-2222-2222-222222222222',
      topicName: 'Kesirler',
      subjectName: 'Matematik',
      totalAttempts: 20,
      correctAttempts: 8,
      successRate: 0.4,
    ),
  ];

  group('ReportExportService.sanitizeName', () {
    test('keeps only the first name token', () {
      expect(ReportExportService.sanitizeName('Ali Veli Yılmaz'), 'Ali');
    });

    test('falls back for empty name', () {
      expect(ReportExportService.sanitizeName('   '), 'Çocuk');
    });
  });

  group('ReportExportService.buildReportText', () {
    late String text;
    setUp(() {
      text = ReportExportService.buildReportText(
        childName: 'Ayşe Nur Demir',
        weekly: weekly,
        weakTopics: weakTopics,
      );
    });

    test('includes only the first name', () {
      expect(text, contains('Ayşe'));
      expect(text, isNot(contains('Nur')));
      expect(text, isNot(contains('Demir')));
    });

    test('never leaks any identifier', () {
      expect(text, isNot(contains('11111111')));
      expect(text, isNot(contains('22222222')));
      expect(text.toLowerCase(), isNot(contains('childid')));
      expect(text.toLowerCase(), isNot(contains('@')));
    });

    test('reports sanitized aggregate stats', () {
      expect(text, contains('Çözülen soru: 120'));
      expect(text, contains('%80'));
      expect(text, contains('Kesirler'));
    });
  });

  group('ReportExportService.buildReportText entertainment & challenge', () {
    const entertainment = EntertainmentStats(
      childId: '33333333-3333-3333-3333-333333333333',
      totalPlayed: 12,
      totalWon: 9,
      perfectWins: 3,
      averageSuccessRate: 0.75,
      categories: [
        EntertainmentCategoryStat(
          categoryKey: 'history',
          categoryName: 'Tarih',
          played: 5,
          won: 4,
          averageSuccessRate: 0.82,
        ),
      ],
    );

    const challenge = ChallengeHistory(
      childId: '44444444-4444-4444-4444-444444444444',
      totalCompleted: 8,
      won: 5,
      lost: 2,
      tie: 1,
      categories: [
        ChallengeCategoryStat(
          category: 'Matematik',
          played: 4,
          won: 3,
          lost: 1,
          tie: 0,
          winRate: 0.75,
        ),
      ],
    );

    test('includes entertainment and challenge sections when data exists', () {
      final text = ReportExportService.buildReportText(
        childName: 'Ayşe Nur Demir',
        weekly: weekly,
        weakTopics: weakTopics,
        entertainment: entertainment,
        challenge: challenge,
      );
      expect(text, contains('Eğlence quizleri:'));
      expect(text, contains('Oynanan: 12, Kazanılan: 9'));
      expect(text, contains('Tarih'));
      expect(text, contains('Meydan okuma:'));
      expect(text, contains('Tamamlanan: 8'));
      expect(text, contains('Matematik'));
    });

    test('omits sections when no activity', () {
      final text = ReportExportService.buildReportText(
        childName: 'Ayşe',
        weekly: weekly,
        weakTopics: weakTopics,
        entertainment: const EntertainmentStats(
          childId: '33333333-3333-3333-3333-333333333333',
          totalPlayed: 0,
          totalWon: 0,
          perfectWins: 0,
          averageSuccessRate: 0,
        ),
        challenge: const ChallengeHistory(
          childId: '44444444-4444-4444-4444-444444444444',
          totalCompleted: 0,
          won: 0,
          lost: 0,
          tie: 0,
        ),
      );
      expect(text, isNot(contains('Eğlence quizleri:')));
      expect(text, isNot(contains('Meydan okuma:')));
    });

    test('never leaks identifiers from added sections', () {
      final text = ReportExportService.buildReportText(
        childName: 'Ayşe',
        weekly: weekly,
        weakTopics: weakTopics,
        entertainment: entertainment,
        challenge: challenge,
      );
      expect(text, isNot(contains('33333333')));
      expect(text, isNot(contains('44444444')));
      expect(text.toLowerCase(), isNot(contains('childid')));
    });
  });
}

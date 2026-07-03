import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/adaptive_quiz_config.dart';
import '../models/adaptive_quiz_models.dart';
import '../providers/adaptive_quiz_provider.dart';

class AdaptiveQuizSelectScreen extends ConsumerWidget {
  const AdaptiveQuizSelectScreen({super.key});

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4FACFE), Color(0xFF7B2FBE), Color(0xFF4776E6)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(weakTopicsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) context.pop();
                        else context.go('/dashboard');
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🤖 Sana Özel Quiz',
                              style: GoogleFonts.luckiestGuy(
                                  color: Colors.white,
                                  fontSize: 20,
                                  shadows: const [
                                    Shadow(
                                        blurRadius: 0,
                                        color: Color(0xFF2C0654),
                                        offset: Offset(1, 1))
                                  ])),
                          Text('Zayıf konunu seç, pratik yap',
                              style: GoogleFonts.nunito(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: topicsAsync.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: Colors.white)),
                  error: (_, __) => _ErrorState(
                      onRetry: () => ref.invalidate(weakTopicsProvider)),
                  data: (topics) => topics.isEmpty
                      ? _NoWeakTopics()
                      : _TopicList(topics: topics),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Zayıf konu listesi ────────────────────────────────────────────────────────

class _TopicList extends StatelessWidget {
  final List<WeakTopicModel> topics;
  const _TopicList({required this.topics});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: topics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TopicCard(topic: topics[i]),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final WeakTopicModel topic;
  const _TopicCard({required this.topic});

  AdaptiveQuizConfig get _config {
    final levelDisplay = topic.englishLevel != null
        ? topic.englishLevel!
        : topic.gradeLevel > 0
            ? '${topic.gradeLevel}. Sınıf'
            : topic.subjectName;

    return AdaptiveQuizConfig(
      subjectName:  topic.subjectName,
      levelDisplay: levelDisplay,
      topicName:    topic.topicName,
      gradeLevel:   topic.gradeLevel > 0 ? topic.gradeLevel : 1,
      difficulty:   topic.suggestedDifficulty,
      englishLevel: topic.englishLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = topic.avgSuccessPercent;
    final color = pct < 50
        ? const Color(0xFFEF5350)
        : pct < 60
            ? const Color(0xFFFF8C00)
            : const Color(0xFFFFB300);

    final levelLabel = topic.englishLevel != null
        ? topic.englishLevel!
        : topic.gradeLevel > 0
            ? '${topic.gradeLevel}. Sınıf'
            : '';

    return GestureDetector(
      onTap: () => context.push('/adaptive-quiz', extra: _config),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            // Sol: Başarı yüzdesi çemberi
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                    color: color.withOpacity(0.6), width: 2),
              ),
              child: Center(
                child: Text(
                  '%${pct.toStringAsFixed(0)}',
                  style: GoogleFonts.nunito(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Konu bilgisi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.topicName,
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(topic.subjectName,
                        style: GoogleFonts.nunito(
                            color: Colors.white60, fontSize: 12)),
                    if (levelLabel.isNotEmpty) ...[
                      Text(' · ',
                          style: GoogleFonts.nunito(
                              color: Colors.white38, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(levelLabel,
                            style: GoogleFonts.nunito(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${topic.attemptCount} deneme',
                      style: GoogleFonts.nunito(
                          color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Pratik butonu
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FBE), Color(0xFF4776E6)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 18)),
                  Text('Pratik',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Zayıf konu yok ───────────────────────────────────────────────────────────

class _NoWeakTopics extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text('Harika! Zayıf konun yok',
                textAlign: TextAlign.center,
                style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 22,
                    shadows: const [
                      Shadow(
                          blurRadius: 0,
                          color: Color(0xFF2C0654),
                          offset: Offset(2, 2))
                    ])),
            const SizedBox(height: 12),
            Text(
              'Son 30 günde %70\'in altında konu yok.\nYeni konular çalışmaya devam et!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (context.canPop()) context.pop();
                else context.go('/dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7B2FBE),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
              child: Text('Ana Sayfaya Dön',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ],
        ),
      );
}

// ── Hata ─────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😔', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text('Konular yüklenemedi',
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF7B2FBE)),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/adaptive_quiz_config.dart';
import '../models/adaptive_quiz_models.dart';
import '../providers/adaptive_quiz_provider.dart';

class AdaptiveQuizSelectScreen extends ConsumerStatefulWidget {
  const AdaptiveQuizSelectScreen({super.key});

  @override
  ConsumerState<AdaptiveQuizSelectScreen> createState() =>
      _AdaptiveQuizSelectScreenState();
}

class _AdaptiveQuizSelectScreenState
    extends ConsumerState<AdaptiveQuizSelectScreen> {

  @override
  void initState() {
    super.initState();
  }

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4FACFE), Color(0xFF7B2FBE), Color(0xFF4776E6)],
  );

  @override
  Widget build(BuildContext context) {
    final topicsAsync  = ref.watch(weakTopicsProvider);
    final remaining    = ref.watch(remainingAttemptsProvider).valueOrNull ?? 3;

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
                    // Kalan hak göstergesi
                    _AttemptsBadge(remaining: remaining),
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

// ── Hak göstergesi ───────────────────────────────────────────────────────────

class _AttemptsBadge extends StatelessWidget {
  final int remaining;
  const _AttemptsBadge({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final color = remaining > 0
        ? const Color(0xFF43A047)
        : const Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            remaining > 0 ? '$remaining' : '0',
            style: GoogleFonts.luckiestGuy(
                color: Colors.white, fontSize: 18),
          ),
          Text(
            'Hak',
            style: GoogleFonts.nunito(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w700),
          ),
        ],
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
    final isMastered = topic.isMastered;

    final borderColor = isMastered
        ? const Color(0xFF43A047)
        : pct < 50
            ? const Color(0xFFEF5350)
            : pct < 60
                ? const Color(0xFFFF8C00)
                : const Color(0xFFFFB300);

    final circleColor = isMastered ? const Color(0xFF43A047) : borderColor;

    final levelLabel = topic.englishLevel != null
        ? topic.englishLevel!
        : topic.gradeLevel > 0
            ? '${topic.gradeLevel}. Sınıf'
            : '';

    return GestureDetector(
      onTap: isMastered ? null : () => context.push('/adaptive-quiz', extra: _config),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMastered
              ? const Color(0xFF1B5E20).withOpacity(0.25)
              : Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Sol: başarı çemberi
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: circleColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: circleColor.withOpacity(0.6), width: 2),
                  ),
                  child: Center(
                    child: isMastered
                        ? const Text('🏆', style: TextStyle(fontSize: 26))
                        : Text(
                            '%${pct.toStringAsFixed(0)}',
                            style: GoogleFonts.nunito(
                                color: circleColor,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(topic.topicName,
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ),
                          if (isMastered)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF43A047),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('✅ AI Tamamlandı',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10)),
                            ),
                        ],
                      ),
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
                          valueColor:
                              AlwaysStoppedAnimation(borderColor),
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
                // Pratik / Kilitli butonu
                if (!isMastered)
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
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔒', style: TextStyle(fontSize: 18)),
                        Text('Kilitli',
                            style: GoogleFonts.nunito(
                                color: Colors.white38,
                                fontWeight: FontWeight.w700,
                                fontSize: 10)),
                      ],
                    ),
                  ),
              ],
            ),
            // Mastered bilgi bandı
            if (isMastered)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF43A047).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Normal testlerde %70\'in üzerinde çözersen bu konu 7 gün içinde listeden kalkar.',
                          style: GoogleFonts.nunito(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
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
            Text('Harika iş!',
                textAlign: TextAlign.center,
                style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 26,
                    shadows: const [
                      Shadow(
                          blurRadius: 0,
                          color: Color(0xFF2C0654),
                          offset: Offset(2, 2))
                    ])),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                'Şu an için AI quiz önerilecek konu bulunamadı.\n\n'
                'Bu iki durumdan biri anlamına gelir:\n'
                '• Son 30 günde %70 altında başarılı İngilizce konun yok 🎉\n'
                '• Zayıf konuların var ama AI testlerinde hepsinde 5/5 yaptın 🏆',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Yeni konular çalışmaya devam et!',
              style: GoogleFonts.nunito(
                  color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 28),
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

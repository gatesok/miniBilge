import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/entertainment_models.dart';
import '../providers/entertainment_provider.dart';

class EntertainmentSelectScreen extends ConsumerStatefulWidget {
  const EntertainmentSelectScreen({super.key});

  @override
  ConsumerState<EntertainmentSelectScreen> createState() =>
      _EntertainmentSelectScreenState();
}

class _EntertainmentSelectScreenState
    extends ConsumerState<EntertainmentSelectScreen> {
  String? _selectedTopicKey;
  String _difficulty = 'Orta';

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF137F7A), Color(0xFF075D5B), Color(0xFF043F42)],
  );

  static const _difficulties = ['Kolay', 'Orta', 'Zor'];

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(entertainmentTopicsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: Stack(
          children: [
            const _BackgroundSparkles(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/dashboard');
                            }
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Eğlence Quiz',
                                style: GoogleFonts.luckiestGuy(
                                  color: Colors.white,
                                  fontSize: 22,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 0,
                                      color: Color(0xFF004D40),
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Konu ve zorluk seç, başla!',
                                style: GoogleFonts.nunito(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const _EntertainmentAttemptsBadge(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: topicsAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: (_, _) => _ErrorView(
                        onRetry: () =>
                            ref.invalidate(entertainmentTopicsProvider),
                      ),
                      data: (topics) => _Body(
                        topics: topics,
                        selectedTopicKey: _selectedTopicKey,
                        difficulty: _difficulty,
                        onTopicTap: (key) =>
                            setState(() => _selectedTopicKey = key),
                        onDifficultyTap: (d) => setState(() => _difficulty = d),
                        difficulties: _difficulties,
                        onStart: _start,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _start() {
    if (_selectedTopicKey == null) return;
    context.push(
      '/entertainment/quiz',
      extra: {'topicKey': _selectedTopicKey, 'difficulty': _difficulty},
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final List<EntertainmentTopicModel> topics;
  final String? selectedTopicKey;
  final String difficulty;
  final void Function(String) onTopicTap;
  final void Function(String) onDifficultyTap;
  final List<String> difficulties;
  final VoidCallback onStart;

  const _Body({
    required this.topics,
    required this.selectedTopicKey,
    required this.difficulty,
    required this.onTopicTap,
    required this.onDifficultyTap,
    required this.difficulties,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Konu seçimi
          Text(
            '1. Konu Seç',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: topics
                .map(
                  (t) => _TopicCard(
                    topic: t,
                    selected: selectedTopicKey == t.key,
                    onTap: () => onTopicTap(t.key),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 28),

          // Zorluk seçimi
          Text(
            '2. Zorluk Seç',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: difficulties.map((d) {
              final selected = d == difficulty;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: d == difficulties.last ? 0 : 8,
                  ),
                  child: GestureDetector(
                    onTap: () => onDifficultyTap(d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: selected
                            ? _difficultyColor(d)
                            : Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.78)
                              : Colors.white38,
                          width: selected ? 2 : 1.5,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: _difficultyColor(
                                    d,
                                  ).withValues(alpha: 0.45),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _difficultyIcon(d),
                            color: Colors.white,
                            size: 17,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            d,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Başla butonu
          if (selectedTopicKey != null) ...[
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x9900302F),
                    blurRadius: 0,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8054F5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 26),
                    const SizedBox(width: 7),
                    Text(
                      'Quize Başla',
                      style: GoogleFonts.luckiestGuy(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final EntertainmentTopicModel topic;
  final bool selected;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF9E9), Color(0xFFFFFFFF)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _topicColor(topic.key).withValues(alpha: 0.36),
                  Colors.white.withValues(alpha: 0.12),
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFFFFD25A) : Colors.white38,
          width: selected ? 2.5 : 1.5,
        ),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (selected)
            const Positioned(
              right: 10,
              top: 10,
              child: Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF3AA84F),
                size: 21,
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: selected
                        ? _topicColor(topic.key).withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _topicIcon(topic.key),
                    color: selected ? _topicColor(topic.key) : Colors.white,
                    size: 29,
                  ),
                ),
                const SizedBox(height: 9),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    topic.label,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: selected ? const Color(0xFF075D5B) : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.sentiment_dissatisfied_rounded,
          color: Colors.white,
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          'Konular yüklenemedi',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF11998E),
          ),
          child: const Text('Tekrar Dene'),
        ),
      ],
    ),
  );
}

// ── Attempts Badge ────────────────────────────────────────────────────────────

class _EntertainmentAttemptsBadge extends ConsumerWidget {
  const _EntertainmentAttemptsBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining =
        ref.watch(entertainmentRemainingProvider).valueOrNull ?? 3;
    final color = remaining > 0
        ? const Color(0xFF43A047)
        : const Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFFFD55A), size: 19),
          const SizedBox(width: 5),
          Text(
            '$remaining',
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 19),
          ),
          const SizedBox(width: 4),
          Text(
            'quiz',
            style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Color _topicColor(String key) {
  switch (key) {
    case 'spor':
      return const Color(0xFF4CAF50);
    case 'genel_kultur':
      return const Color(0xFF7861E8);
    case 'muzik':
      return const Color(0xFFE55A9A);
    case 'sinema_dizi':
      return const Color(0xFFFF914D);
    case 'teknoloji':
      return const Color(0xFF32A9D8);
    case 'sanat':
      return const Color(0xFFEDAA32);
    default:
      return const Color(0xFF7C5CE0);
  }
}

IconData _topicIcon(String key) {
  switch (key) {
    case 'spor':
      return Icons.sports_soccer_rounded;
    case 'genel_kultur':
      return Icons.public_rounded;
    case 'muzik':
      return Icons.music_note_rounded;
    case 'sinema_dizi':
      return Icons.movie_filter_rounded;
    case 'teknoloji':
      return Icons.memory_rounded;
    case 'sanat':
      return Icons.palette_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}

Color _difficultyColor(String difficulty) {
  switch (difficulty) {
    case 'Kolay':
      return const Color(0xFF43A047);
    case 'Zor':
      return const Color(0xFFE05252);
    default:
      return const Color(0xFFE2A52C);
  }
}

IconData _difficultyIcon(String difficulty) {
  switch (difficulty) {
    case 'Kolay':
      return Icons.sentiment_satisfied_alt_rounded;
    case 'Zor':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.psychology_alt_rounded;
  }
}

class _BackgroundSparkles extends StatelessWidget {
  const _BackgroundSparkles();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      children: const [
        Positioned(
          top: 116,
          right: 26,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Color(0x334EDED0),
            size: 30,
          ),
        ),
        Positioned(
          top: 360,
          left: 15,
          child: Icon(Icons.star_rounded, color: Color(0x224EDED0), size: 24),
        ),
        Positioned(
          bottom: 110,
          right: 20,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Color(0x2259D8FF),
            size: 36,
          ),
        ),
      ],
    ),
  );
}

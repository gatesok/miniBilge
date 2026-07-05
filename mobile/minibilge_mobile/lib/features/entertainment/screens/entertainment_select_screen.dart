import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/entertainment_models.dart';
import '../providers/entertainment_provider.dart';
import '../services/entertainment_history_service.dart';

class EntertainmentSelectScreen extends ConsumerStatefulWidget {
  const EntertainmentSelectScreen({super.key});

  @override
  ConsumerState<EntertainmentSelectScreen> createState() =>
      _EntertainmentSelectScreenState();
}

class _EntertainmentSelectScreenState
    extends ConsumerState<EntertainmentSelectScreen> {
  String? _selectedTopicKey;
  String  _difficulty = 'Orta';

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  static const _difficulties = ['Kolay', 'Orta', 'Zor'];

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(entertainmentTopicsProvider);

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
                          Text('🎉 Eğlence Quiz',
                              style: GoogleFonts.luckiestGuy(
                                  color: Colors.white,
                                  fontSize: 22,
                                  shadows: const [
                                    Shadow(
                                        blurRadius: 0,
                                        color: Color(0xFF004D40),
                                        offset: Offset(1, 1))
                                  ])),
                          Text('Konu ve zorluk seç, başla!',
                              style: GoogleFonts.nunito(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: topicsAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (_, __) => _ErrorView(
                      onRetry: () => ref.invalidate(entertainmentTopicsProvider)),
                  data: (topics) => _Body(
                    topics:           topics,
                    selectedTopicKey: _selectedTopicKey,
                    difficulty:       _difficulty,
                    onTopicTap: (key) =>
                        setState(() => _selectedTopicKey = key),
                    onDifficultyTap: (d) =>
                        setState(() => _difficulty = d),
                    difficulties:    _difficulties,
                    onStart:         _start,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _start() {
    if (_selectedTopicKey == null) return;
    context.push(
      '/entertainment/quiz',
      extra: {
        'topicKey':   _selectedTopicKey,
        'difficulty': _difficulty,
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final List<EntertainmentTopicModel> topics;
  final String? selectedTopicKey;
  final String  difficulty;
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Konu seçimi
          Text('1. Konu Seç',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: topics.map((t) => _TopicCard(
                  topic:    t,
                  selected: selectedTopicKey == t.key,
                  onTap:    () => onTopicTap(t.key),
                )).toList(),
          ),

          const SizedBox(height: 24),

          // Zorluk seçimi
          Text('2. Zorluk Seç',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: difficulties.map((d) {
              final selected = d == difficulty;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onDifficultyTap(d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: selected
                                ? Colors.white
                                : Colors.white38,
                            width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          d == 'Kolay' ? '😊 Kolay'
                              : d == 'Orta' ? '🤔 Orta'
                                  : '🔥 Zor',
                          style: GoogleFonts.nunito(
                              color: selected
                                  ? const Color(0xFF004D40)
                                  : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13),
                        ),
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
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF11998E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Başla 🚀',
                  style: GoogleFonts.luckiestGuy(
                      fontSize: 18,
                      shadows: const [
                        Shadow(
                            blurRadius: 0,
                            color: Color(0xFF004D40),
                            offset: Offset(1, 1))
                      ])),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final EntertainmentTopicModel topic;
  final bool       selected;
  final VoidCallback onTap;

  const _TopicCard(
      {required this.topic, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? Colors.white : Colors.white30,
                width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(topic.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(topic.label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        color: selected
                            ? const Color(0xFF004D40)
                            : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('😔', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('Konular yüklenemedi',
              style: GoogleFonts.nunito(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF11998E)),
              child: const Text('Tekrar Dene')),
        ]),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flashcard_models.dart';
import '../providers/flashcard_provider.dart';

class FlashcardDeckListScreen extends ConsumerWidget {
  final int englishLevel;
  final String levelCode; // "A1", "B2" vb.

  const FlashcardDeckListScreen({
    super.key,
    required this.englishLevel,
    required this.levelCode,
  });

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
    colors: [Color(0xFF7B1FA2), Color(0xFF4A148C), Color(0xFF1A0030)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(flashcardDeckListProvider(englishLevel));

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4), width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Text('📚 Kelime Kartları',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.luckiestGuy(
                                fontSize: 24,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                      blurRadius: 0,
                                      color: Color(0xFF1A0030),
                                      offset: Offset(2, 2)),
                                ],
                              )),
                          Text(levelCode,
                              style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white60)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: decksAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (e, _) => Center(
                    child: Text('Yüklenemedi 😔\n$e',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            color: Colors.white70, fontSize: 14)),
                  ),
                  data: (decks) {
                    if (decks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📭', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('Bu seviye için henüz deste yok.',
                                style: GoogleFonts.nunito(
                                    color: Colors.white70, fontSize: 15)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: decks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _DeckTile(deck: decks[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  final FlashcardDeck deck;

  const _DeckTile({required this.deck});

  @override
  Widget build(BuildContext context) {
    final progress =
        deck.totalCards > 0 ? deck.learnedCount / deck.totalCards : 0.0;
    final isCompleted = deck.learnedCount == deck.totalCards && deck.totalCards > 0;

    return GestureDetector(
      onTap: () => context.push(
        '/flashcard/study/${deck.id}',
        extra: deck.title,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted
                ? Colors.greenAccent.withOpacity(0.6)
                : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    deck.title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.greenAccent, size: 22)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${deck.totalCards} kart',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.greenAccent : const Color(0xFFCE93D8),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${deck.learnedCount} / ${deck.totalCards} öğrenildi',
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

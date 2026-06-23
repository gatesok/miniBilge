import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/flashcard_card_widget.dart';

class FlashcardStudyScreen extends ConsumerStatefulWidget {
  final String deckId;
  final String deckTitle;

  const FlashcardStudyScreen({
    super.key,
    required this.deckId,
    required this.deckTitle,
  });

  @override
  ConsumerState<FlashcardStudyScreen> createState() =>
      _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends ConsumerState<FlashcardStudyScreen> {
  bool _isNavigating = false;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
    colors: [Color(0xFF7B1FA2), Color(0xFF4A148C), Color(0xFF1A0030)],
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashcardStudyProvider(widget.deckId));

    // Session tamamlandığında sonuç ekranına git
    if (state.isComplete && !_isNavigating) {
      _isNavigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          final result = await ref
              .read(flashcardStudyProvider(widget.deckId).notifier)
              .completeSession();
          if (!mounted) return;
          context.pushReplacement(
            '/flashcard/result',
            extra: result,
          );
        } catch (_) {
          if (!mounted) return;
          context.pop();
        }
      });
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(context, state),
              const SizedBox(height: 8),
              _buildProgressBar(state),
              const SizedBox(height: 24),
              Expanded(
                child: _buildBody(state),
              ),
              if (!state.isLoading && state.currentCard != null)
                _buildButtons(context, state),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FlashcardStudyState state) {
    return Padding(
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
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.deckTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 20,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                          blurRadius: 0,
                          color: Color(0xFF1A0030),
                          offset: Offset(2, 2)),
                    ],
                  ),
                ),
                if (!state.isLoading)
                  Text(
                    '${state.learned.length} / ${state.totalCards} öğrenildi',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white60),
                  ),
              ],
            ),
          ),
          // remaining queue count badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${state.queue.length} kart',
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(FlashcardStudyState state) {
    final progress =
        state.totalCards > 0 ? state.learned.length / state.totalCards : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: Colors.white.withOpacity(0.15),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCE93D8)),
        ),
      ),
    );
  }

  Widget _buildBody(FlashcardStudyState state) {
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (state.error != null) {
      return Center(
        child: Text('Yüklenemedi 😔\n${state.error}',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14)),
      );
    }
    if (state.isComplete) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    final card = state.currentCard!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FlashcardCardWidget(
        key: ValueKey(card.id),
        card: card,
        isFlipped: state.isFlipped,
        onTap: () =>
            ref.read(flashcardStudyProvider(widget.deckId).notifier).flip(),
      ),
    );
  }

  Widget _buildButtons(
      BuildContext context, FlashcardStudyState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // "Kartı çevir" hint — sadece flip olmadıysa göster
          if (!state.isFlipped) ...[
            Text(
              'Kartı çevir, ardından cevabını değerlendir',
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.white38,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              // Bilmiyorum
              Expanded(
                child: _ActionButton(
                  label: 'Bilmiyorum',
                  icon: Icons.replay_rounded,
                  color: const Color(0xFFEF5350),
                  onTap: state.isFlipped
                      ? () => ref
                          .read(flashcardStudyProvider(widget.deckId).notifier)
                          .markUnknown()
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Biliyorum
              Expanded(
                child: _ActionButton(
                  label: 'Biliyorum',
                  icon: Icons.check_rounded,
                  color: const Color(0xFF66BB6A),
                  onTap: state.isFlipped
                      ? () => ref
                          .read(flashcardStudyProvider(widget.deckId).notifier)
                          .markKnown()
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.white.withOpacity(0.07)
              : color.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDisabled
                ? Colors.white.withOpacity(0.1)
                : color,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isDisabled ? Colors.white24 : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDisabled ? Colors.white24 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

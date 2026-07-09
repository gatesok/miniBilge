import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wordle_level_models.dart';
import '../models/wordle_models.dart';
import '../providers/wordle_level_provider.dart';
import '../providers/wordle_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../../../core/widgets/card_drop_animation.dart';
import '../../collection/models/card_dto.dart';
import '../../adaptive_quiz/models/adaptive_quiz_models.dart';
import '../../../../core/services/ad_service.dart';

// ── Türkçe klavye ─────────────────────────────────────────────────────────────
const _kbRow1 = ['E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü'];
const _kbRow2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ'];
const _kbRow3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç'];

class WordleLevelGameScreen extends ConsumerStatefulWidget {
  const WordleLevelGameScreen({super.key});

  @override
  ConsumerState<WordleLevelGameScreen> createState() =>
      _WordleLevelGameScreenState();
}

class _WordleLevelGameScreenState extends ConsumerState<WordleLevelGameScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _levelUpCtrl;
  late final Animation<double>   _levelUpAnim;
  static const _adCounterKey   = 'wordle_level_word_count';
  static const _adEvery        = 5; // Her 5 kelimede 1 reklam

  /// Her yeni kelime üretiminden önce çağrılır.
  /// Sayaç 5'in katıysa interstitial gösterir, sonra [action] çalıştırır.
  Future<void> _generateWithAd(Future<void> Function() action) async {
    final prefs   = await SharedPreferences.getInstance();
    final count   = (prefs.getInt(_adCounterKey) ?? 0) + 1;
    await prefs.setInt(_adCounterKey, count);

    if (count % _adEvery == 0) {
      // Reklam göster, bittikten sonra kelime üretimini başlat
      AdService.showInterstitialAd(onComplete: () {
        if (mounted) action();
      });
    } else {
      await action();
    }
  }
  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _levelUpCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _levelUpAnim = CurvedAnimation(parent: _levelUpCtrl, curve: Curves.easeOut);

    Future.microtask(() async {
      final child = ref.read(selectedChildProvider);
      if (child == null) return;
      await ref.read(wordleLevelProvider(child.id).notifier).load();
      // Seviye idle ise otomatik kelime üret
      final state = ref.read(wordleLevelProvider(child.id));
      if (state.phase == WordleLevelPhase.idle && !state.isFinished) {
        // İlk kelime yüklenirken reklam sayacı başlatma — sadece tekrar/sonraki
        await ref.read(wordleLevelProvider(child.id).notifier).generateWord();
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _levelUpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final child = ref.read(selectedChildProvider);
    if (child == null) return;
    final state = ref.read(wordleLevelProvider(child.id));
    if (!state.canSubmit) return;

    final response = await ref
        .read(wordleLevelProvider(child.id).notifier)
        .submitGuess();
    if (response == null) return;

    if (response.solved) _confetti.play();

    // Milestone: kart drop
    if (response.milestone && mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        // Milestone reward — card drop göster
        // (gerçek kart için backend'den kart bilgisi gelebilir)
        await CardDropAnimation.show(
          context,
          drop: CardDropResult(
            cardId:     '',
            cardName:   'Seviye ${response.solved ? (state.levelData!.currentLevel) : state.levelData!.currentLevel} Ödülü',
            rarity:     'epic',
            imageAsset: '',
            isNew:      true,
          ),
        );
      }
    }

    if (response.levelUp) {
      await _levelUpCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        ref.read(wordleLevelProvider(child.id).notifier).onLevelUpAnimationDone();
        await _generateWithAd(() =>
            ref.read(wordleLevelProvider(child.id).notifier).generateWord());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.read(selectedChildProvider);
    if (child == null) return const Scaffold();

    final state  = ref.watch(wordleLevelProvider(child.id));
    final colors = state.themeColors;
    final bg1    = Color(colors[0]);
    final bg2    = Color(colors[1]);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [bg1, bg2],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _Header(state: state, onBack: () {
                    if (context.canPop()) context.pop();
                    else context.go('/dashboard');
                  }),
                  Expanded(
                    child: state.isLoading &&
                            state.phase == WordleLevelPhase.generating
                        ? _GeneratingView()
                        : state.error != null
                            ? _ErrorView(
                                onRetry: () => ref
                                    .read(wordleLevelProvider(child.id).notifier)
                                    .load(),
                              )
                            : state.phase == WordleLevelPhase.idle ||
                                    state.levelData == null
                                ? _IdleView(
                                    onGenerate: () => _generateWithAd(() =>
                                        ref.read(wordleLevelProvider(child.id).notifier)
                                            .generateWord()),
                                  )
                                : Column(
                                    children: [
                                      if (state.levelData?.hint != null)
                                        _HintCard(hint: state.levelData!.hint!),
                                      const SizedBox(height: 6),
                                      _LevelGrid(
                                          state: state,
                                          levelUpAnim: _levelUpAnim),
                                      const SizedBox(height: 8),
                                      if (!state.isFinished)
                                        _LevelKeyboard(
                                          keyColors: state.keyColors,
                                          onLetter: (l) => ref
                                              .read(wordleLevelProvider(child.id)
                                                  .notifier)
                                              .addLetter(l),
                                          onDelete: () => ref
                                              .read(wordleLevelProvider(child.id)
                                                  .notifier)
                                              .removeLetter(),
                                          onEnter: _submit,
                                        ),
                                      if (state.isFinished)
                                        _ResultBar(
                                          state:    state,
                                          // Çözüldüyse → sonraki seviye, başarısızsa → aynı seviye yeni kelime
                                          onNext: state.levelData!.solved
                                              ? () => _generateWithAd(() =>
                                                  ref.read(wordleLevelProvider(child.id).notifier).generateWord())
                                              : () => _generateWithAd(() =>
                                                  ref.read(wordleLevelProvider(child.id).notifier).retryLevel()),
                                          onSkip: state.levelData!.skipTickets > 0
                                              ? () => ref
                                                  .read(wordleLevelProvider(child.id)
                                                      .notifier)
                                                  .skipLevel()
                                              : null,
                                        ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                  ),
                ],
              ),
              // Konfeti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController:  _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles:   25,
                  colors: const [
                    Colors.green, Colors.yellow, Colors.white,
                    Colors.teal,  Colors.amber,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final WordleLevelState state;
  final VoidCallback     onBack;
  const _Header({required this.state, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final level = state.levelData?.currentLevel ?? 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white70),
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              children: [
                Text('SEVİYE $level',
                    style: GoogleFonts.luckiestGuy(
                        color: Colors.white, fontSize: 18, letterSpacing: 3)),
                if (state.levelData != null)
                  Text(
                    '${state.levelData!.wordLength} harf · '
                    '${state.levelData!.maxAttempts} hak',
                    style: GoogleFonts.nunito(
                        color: Colors.white54, fontSize: 11),
                  ),
              ],
            ),
          ),
          // Skip ticket badge
          if ((state.levelData?.skipTickets ?? 0) > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⏭', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text('${state.levelData!.skipTickets}',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Hint Kartı ────────────────────────────────────────────────────────────────

class _HintCard extends StatelessWidget {
  final String hint;
  const _HintCard({required this.hint});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(hint,
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
}

// ── Grid ──────────────────────────────────────────────────────────────────────

class _LevelGrid extends StatelessWidget {
  final WordleLevelState   state;
  final Animation<double>  levelUpAnim;
  const _LevelGrid({required this.state, required this.levelUpAnim});

  @override
  Widget build(BuildContext context) {
    final rows     = state.maxAttempts;
    final cols     = state.wordLength;
    final guesses  = state.levelData?.guesses ?? [];
    final inputRow = guesses.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!state.isFinished)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${inputRow + 1}. deneme · $rows hak',
                style: GoogleFonts.nunito(
                    color: Colors.white38, fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ...List.generate(rows, (row) {
            final isCurrentRow = row == inputRow && !state.isFinished;
            final isFutureRow  = row > inputRow;
            final guess        = row < guesses.length ? guesses[row] : null;

            final tileSize = cols <= 5 ? 48.0 : cols == 6 ? 42.0 : 38.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    child: Text('${row + 1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isCurrentRow
                              ? Colors.white70
                              : isFutureRow
                                  ? Colors.white.withOpacity(0.12)
                                  : Colors.white38,
                          fontSize: 11,
                          fontWeight: isCurrentRow
                              ? FontWeight.w800
                              : FontWeight.w400,
                        )),
                  ),
                  const SizedBox(width: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(cols, (col) {
                      String  letter = '';
                      String? status;
                      if (guess != null) {
                        letter = col < guess.guess.length    ? guess.guess[col]   : '';
                        status = col < guess.pattern.length  ? guess.pattern[col] : null;
                      } else if (isCurrentRow) {
                        letter = col < state.currentInput.length
                            ? state.currentInput[col]
                            : '';
                      }
                      return _LevelTile(
                          letter: letter, status: status,
                          col: col, size: tileSize);
                    }),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final String  letter;
  final String? status;
  final int     col;
  final double  size;
  const _LevelTile({
    required this.letter,
    required this.status,
    required this.col,
    required this.size,
  });

  Color get _bg => switch (status) {
    'correct' => const Color(0xFF538D4E),
    'present' => const Color(0xFFB59F3B),
    'absent'  => const Color(0xFF3A3A3C),
    _         => const Color(0xFF121213),
  };

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: Duration(milliseconds: status != null ? 300 + col * 80 : 100),
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        width:  size,
        height: size,
        decoration: BoxDecoration(
          color:  _bg,
          border: Border.all(
            color: status != null
                ? Colors.transparent
                : letter.isNotEmpty
                    ? Colors.white54
                    : const Color(0xFF3A3A3C),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(letter,
              style: GoogleFonts.luckiestGuy(
                  color: Colors.white,
                  fontSize: size * 0.52)),
        ),
      );
}

// ── Klavye ────────────────────────────────────────────────────────────────────

class _LevelKeyboard extends StatelessWidget {
  final Map<String, String> keyColors;
  final ValueChanged<String> onLetter;
  final VoidCallback         onDelete;
  final VoidCallback         onEnter;
  const _LevelKeyboard({
    required this.keyColors,
    required this.onLetter,
    required this.onDelete,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) {
          final available = constraints.maxWidth - 12;
          final keyW      = ((available - 63) / 11.6).clamp(22.0, 36.0);
          return Column(
            children: [
              _row(_kbRow1, keyW),
              const SizedBox(height: 5),
              _row(_kbRow2, keyW),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SpecKey(label: '⌫', keyW: keyW * 1.2, onTap: onDelete),
                  const SizedBox(width: 4),
                  ..._kbRow3.map((l) => _LetKey(
                      letter: l, status: keyColors[l],
                      keyW: keyW, onTap: () => onLetter(l))),
                  const SizedBox(width: 4),
                  _SpecKey(label: '↵', keyW: keyW * 1.4, onTap: onEnter),
                ],
              ),
            ],
          );
        },
      );

  Widget _row(List<String> letters, double keyW) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters
            .map((l) => _LetKey(
                letter: l, status: keyColors[l],
                keyW: keyW, onTap: () => onLetter(l)))
            .toList(),
      );
}

class _LetKey extends StatelessWidget {
  final String  letter;
  final String? status;
  final double  keyW;
  final VoidCallback onTap;
  const _LetKey({
    required this.letter,
    required this.keyW,
    required this.onTap,
    this.status,
  });
  Color get _bg => switch (status) {
    'correct' => const Color(0xFF538D4E),
    'present' => const Color(0xFFB59F3B),
    'absent'  => const Color(0xFF3A3A3C),
    _         => const Color(0xFF818384),
  };
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: keyW, height: 50,
          decoration: BoxDecoration(
              color: _bg, borderRadius: BorderRadius.circular(4)),
          child: Center(
            child: Text(letter,
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ),
      );
}

class _SpecKey extends StatelessWidget {
  final String label;
  final double keyW;
  final VoidCallback onTap;
  const _SpecKey({required this.label, required this.keyW, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: keyW, height: 50,
          decoration: BoxDecoration(
              color: const Color(0xFF818384),
              borderRadius: BorderRadius.circular(4)),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      );
}

// ── Sonuç Barı ────────────────────────────────────────────────────────────────

class _ResultBar extends StatelessWidget {
  final WordleLevelState state;
  final VoidCallback     onNext;
  final VoidCallback?    onSkip;
  const _ResultBar({required this.state, required this.onNext, this.onSkip});

  @override
  Widget build(BuildContext context) {
    final solved = state.levelData?.solved ?? false;
    final stars  = state.levelData?.starsEarned ?? 0;
    final answer = state.lastResponse?.answer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(solved ? '🎉 Doğru!' : '😔 Başarısız',
                  style: GoogleFonts.luckiestGuy(
                      color: Colors.white, fontSize: 20)),
              if (solved && stars > 0) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('+$stars ⭐',
                      style: GoogleFonts.luckiestGuy(
                          color: Colors.white, fontSize: 16)),
                ),
              ],
            ],
          ),
          if (!solved && answer != null) ...[
            const SizedBox(height: 4),
            Text('Kelime: $answer',
                style: GoogleFonts.nunito(
                    color: Colors.white70, fontSize: 14)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (onSkip != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('⏭ Geç',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              if (onSkip != null) const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: solved
                        ? const Color(0xFF538D4E)
                        : Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(solved ? 'Sonraki Seviye →' : 'Tekrar Dene',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Yardımcı görünümler ───────────────────────────────────────────────────────

class _GeneratingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white54),
            SizedBox(height: 14),
            Text('Kelime hazırlanıyor...',
                style: TextStyle(color: Colors.white60)),
          ],
        ),
      );
}

class _IdleView extends StatelessWidget {
  final VoidCallback onGenerate;
  const _IdleView({required this.onGenerate});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔤', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text('Kelime Oyunu',
                  style: GoogleFonts.luckiestGuy(
                      color: Colors.white, fontSize: 22)),
              const SizedBox(height: 8),
              Text('Her seviyede yeni bir kelime!',
                  style: GoogleFonts.nunito(
                      color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF538D4E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Başla 🎯',
                    style: GoogleFonts.luckiestGuy(
                        fontSize: 16, letterSpacing: 1)),
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
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Bir hata oluştu',
                style: GoogleFonts.nunito(
                    color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
}

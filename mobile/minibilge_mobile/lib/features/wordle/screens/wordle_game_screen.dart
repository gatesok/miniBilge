import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wordle_models.dart';
import '../providers/wordle_provider.dart';
import '../services/wordle_notification_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';

// ── Renkler ───────────────────────────────────────────────────────────────────

const _bg        = Color(0xFF121213);
const _correct   = Color(0xFF538D4E);   // 🟩
const _present   = Color(0xFFB59F3B);   // 🟨
const _absent    = Color(0xFF3A3A3C);   // ⬛
const _filled    = Color(0xFF121213);   // Yazılmış ama submit edilmemiş
const _empty     = Color(0xFF121213);

// ── Türkçe klavye ─────────────────────────────────────────────────────────────
const _kbRow1 = ['E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü'];
const _kbRow2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ'];
const _kbRow3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç'];

class WordleGameScreen extends ConsumerStatefulWidget {
  const WordleGameScreen({super.key});

  @override
  ConsumerState<WordleGameScreen> createState() => _WordleGameScreenState();
}

class _WordleGameScreenState extends ConsumerState<WordleGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;
  String? _lastShareText;
  int     _lastStarsEarned = 0;
  bool    _showResult = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _load() {
    final child = ref.read(selectedChildProvider);
    if (child == null) return;
    ref.read(wordleProvider(child.id).notifier).load();
  }

  Future<void> _submit() async {
    final child = ref.read(selectedChildProvider);
    if (child == null) return;
    final notifier = ref.read(wordleProvider(child.id).notifier);
    final state    = ref.read(wordleProvider(child.id));

    if (!state.canSubmit) {
      // Shake animasyonu — eksik harf
      _shakeCtrl.forward(from: 0);
      return;
    }

    final response = await notifier.submitGuess();
    if (response == null) return;

    if (response.finished) {
      // Günlük Wordle gizlendi — bildirim yeniden planlanmıyor
      setState(() {
        _lastShareText   = response.shareText;
        _lastStarsEarned = response.starsEarned;
        _showResult      = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.read(selectedChildProvider);
    if (child == null) return const Scaffold(backgroundColor: _bg);

    final state = ref.watch(wordleProvider(child.id));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70),
          onPressed: () {
            if (context.canPop()) context.pop();
            else context.go('/dashboard');
          },
        ),
        title: Text('WORDLE',
            style: GoogleFonts.luckiestGuy(
                color: Colors.white, fontSize: 24, letterSpacing: 4)),
        actions: [
          if (state.today != null)
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded, color: Colors.white70),
              onPressed: () => _showStats(context, child.id),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFF3A3A3C), height: 1),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white54))
          : state.error != null
              ? _ErrorView(onRetry: _load)
              : _showResult
                  ? _ResultView(
                      state:      state,
                      shareText:  _lastShareText,
                      starsEarned: _lastStarsEarned,
                      onClose:    () => setState(() => _showResult = false),
                    )
                  : Column(
                      children: [
                        // İpucu kartı
                        if (state.today?.hint != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFF538D4E), width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('💡',
                                      style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.today!.hint!,
                                      style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        _Grid(state: state, shakeAnim: _shakeAnim),
                        const SizedBox(height: 12),
                        _Keyboard(
                          keyColors: state.keyColors,
                          onLetter:  (l) {
                            ref.read(wordleProvider(child.id).notifier).addLetter(l);
                          },
                          onDelete:  () {
                            ref.read(wordleProvider(child.id).notifier).removeLetter();
                          },
                          onEnter:   _submit,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
    );
  }

  void _showStats(BuildContext context, String childId) {
    showModalBottomSheet(
      context:          context,
      backgroundColor:  const Color(0xFF1A1A1B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _StatsSheet(childId: childId),
    );
  }
}

// ── 6×5 Tahmin Izgarası ───────────────────────────────────────────────────────

class _Grid extends StatelessWidget {
  final WordleState      state;
  final Animation<double> shakeAnim;

  const _Grid({required this.state, required this.shakeAnim});

  @override
  Widget build(BuildContext context) {
    final rows     = state.maxAttempts;
    final cols     = state.wordLength;
    final guesses  = state.today?.previousGuesses ?? [];
    final inputRow = guesses.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Deneme sayacı
          if (!state.isFinished)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${(state.today?.attemptsUsed ?? 0) + 1}. deneme  ·  toplam 6 hak',
                style: GoogleFonts.nunito(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ...List.generate(rows, (row) {
            final isCurrentRow = row == inputRow && !state.isFinished;
            final isFutureRow  = row > inputRow;
            final guess        = row < guesses.length ? guesses[row] : null;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: AnimatedBuilder(
                animation: shakeAnim,
                builder: (_, child) {
                  final dx = isCurrentRow
                      ? (shakeAnim.value * 8 * (row.isEven ? 1 : -1))
                      : 0.0;
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Satır numarası
                    SizedBox(
                      width: 18,
                      child: Text(
                        '${row + 1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isCurrentRow
                              ? Colors.white70
                              : isFutureRow
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.white38,
                          fontSize: 12,
                          fontWeight: isCurrentRow
                              ? FontWeight.w800
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Harf kareleri
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(cols, (col) {
                        String  letter = '';
                        String? status;
                        if (guess != null) {
                          letter = col < guess.guess.length    ? guess.guess[col]    : '';
                          status = col < guess.pattern.length  ? guess.pattern[col]  : null;
                        } else if (isCurrentRow) {
                          letter = col < state.currentInput.length
                              ? state.currentInput[col]
                              : '';
                        }
                        return _Tile(letter: letter, status: status, col: col);
                      }),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String  letter;
  final String? status;  // "correct" | "present" | "absent" | null
  final int     col;

  const _Tile({required this.letter, required this.status, required this.col});

  Color get _bg => switch (status) {
    'correct' => _correct,
    'present' => _present,
    'absent'  => _absent,
    _         => _empty,
  };

  Color get _borderColor {
    if (status != null) return Colors.transparent;
    if (letter.isNotEmpty) return Colors.white54;
    return const Color(0xFF3A3A3C);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: status != null ? 300 + col * 100 : 100),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _bg,
        border: Border.all(color: _borderColor, width: 2),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.luckiestGuy(
            color:    Colors.white,
            fontSize: 26,
          ),
        ),
      ),
    );
  }
}

// ── Türkçe Klavye ─────────────────────────────────────────────────────────────

class _Keyboard extends StatelessWidget {
  final Map<String, String> keyColors;
  final ValueChanged<String> onLetter;
  final VoidCallback         onDelete;
  final VoidCallback         onEnter;

  const _Keyboard({
    required this.keyColors,
    required this.onLetter,
    required this.onDelete,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // En geniş sıra row3: ⌫(×1.2) + 9 tuş + ↵(×1.4) + marjinler
        // keyW × (1.2 + 9 + 1.4) + 5×11 + 8(spacer) = available → keyW hesapla
        final available = constraints.maxWidth - 12; // 6px her yandan güvenlik
        final keyW = ((available - 63) / 11.6).clamp(26.0, 36.0);

        return Column(
          children: [
            _buildRow(_kbRow1, keyW),
            const SizedBox(height: 6),
            _buildRow(_kbRow2, keyW),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SpecialKey(label: '⌫', onTap: onDelete, keyW: keyW * 1.2),
                const SizedBox(width: 4),
                ..._kbRow3.map((l) => _LetterKey(
                    letter: l,
                    status: keyColors[l],
                    keyW:   keyW,
                    onTap:  () => onLetter(l))),
                const SizedBox(width: 4),
                _SpecialKey(label: '⏎', onTap: onEnter, keyW: keyW * 1.4),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow(List<String> letters, double keyW) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters.map((l) => _LetterKey(
            letter: l,
            status: keyColors[l],
            keyW:   keyW,
            onTap:  () => onLetter(l))).toList(),
      );
}

class _LetterKey extends StatelessWidget {
  final String  letter;
  final String? status;
  final double  keyW;
  final VoidCallback onTap;

  const _LetterKey({
    required this.letter,
    required this.onTap,
    required this.keyW,
    this.status,
  });

  Color get _bg => switch (status) {
    'correct' => _correct,
    'present' => _present,
    'absent'  => _absent,
    _         => const Color(0xFF818384),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin:   const EdgeInsets.symmetric(horizontal: 2.5),
        width:    keyW,
        height:   50,
        decoration: BoxDecoration(
          color:        _bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(letter,
              style: GoogleFonts.nunito(
                  color:      Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize:   13)),
        ),
      ),
    );
  }
}

class _SpecialKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double keyW;

  const _SpecialKey({
    required this.label,
    required this.onTap,
    required this.keyW,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin:   const EdgeInsets.symmetric(horizontal: 2.5),
        width:    keyW,
        height:   50,
        decoration: BoxDecoration(
          color:        const Color(0xFF818384),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ── Sonuç Görünümü ────────────────────────────────────────────────────────────

class _ResultView extends StatefulWidget {
  final WordleState state;
  final String?     shareText;
  final int         starsEarned;
  final VoidCallback onClose;

  const _ResultView({
    required this.state,
    required this.shareText,
    required this.starsEarned,
    required this.onClose,
  });

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    if (widget.state.today?.solved == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solved   = widget.state.today?.solved ?? false;
    final attempts = widget.state.today?.attemptsUsed ?? 0;
    final max      = widget.state.today?.maxAttempts ?? 6;

    return Stack(
      children: [
        // İçerik
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  solved ? '🎉' : '😔',
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 12),
                Text(
                  solved ? 'Harika!' : 'Yarın Tekrar Dene!',
                  style: GoogleFonts.luckiestGuy(
                  color: Colors.white, fontSize: 24),
            ),
            if (solved) ...[
              const SizedBox(height: 6),
              Text('$attempts / $max denemede buldun!',
                  style: GoogleFonts.nunito(
                      color: Colors.white70, fontSize: 16)),
            ],
            if (widget.starsEarned > 0) ...[  
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text('+${widget.starsEarned} Yıldız',
                        style: GoogleFonts.luckiestGuy(
                            color: Colors.white, fontSize: 20)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Paylaşım kartı
            if (widget.shareText != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  widget.shareText!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.6,
                      fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.shareText!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Panoya kopyalandı!'),
                        duration: Duration(seconds: 2)),
                  );
                },
                icon:  const Icon(Icons.copy_rounded),
                label: const Text('Sonucu Kopyala'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            const SizedBox(height: 16),
            TextButton(
              onPressed: widget.onClose,
              child: Text('Tahtaya Dön',
                  style: GoogleFonts.nunito(
                      color: Colors.white54, fontSize: 14)),
            ),
          ],
        ),
      ),
    ),

    // Konfeti — yalnızca kelime çözüldüğünde
    if (solved)
      Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 30,
          colors: const [
            Colors.green, Color(0xFF538D4E), Colors.yellow,
            Colors.white, Colors.amber,
          ],
        ),
      ),
    ],
  );
  }
}

// ── İstatistik Alt Sayfası ────────────────────────────────────────────────────

class _StatsSheet extends ConsumerWidget {
  final String childId;
  const _StatsSheet({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(wordleStatsProvider(childId));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: statsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white54)),
        error:   (_, __) => const Center(
            child: Text('Yüklenemedi', style: TextStyle(color: Colors.white54))),
        data: (stats) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('İSTATİSTİKLER',
                  style: GoogleFonts.luckiestGuy(
                      color: Colors.white, fontSize: 18, letterSpacing: 2)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(value: '${stats.totalPlayed}',  label: 'Oynanan'),
                _StatItem(
                    value: stats.totalPlayed > 0
                        ? '${(stats.totalSolved / stats.totalPlayed * 100).round()}%'
                        : '0%',
                    label: 'Kazanma'),
                _StatItem(value: '${stats.currentStreak}', label: 'Güncel\nSeri'),
                _StatItem(value: '${stats.bestStreak}',    label: 'En İyi\nSeri'),
              ],
            ),
            const SizedBox(height: 20),
            Text('TAHMİN DAĞILIMI',
                style: GoogleFonts.nunito(
                    color: Colors.white54, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...List.generate(6, (i) {
              final count = stats.guessDist[i + 1] ?? 0;
              final maxCount = stats.guessDist.values
                  .fold(1, (a, b) => a > b ? a : b);
              return _GuessBar(
                  attempt: i + 1,
                  count:   count,
                  fraction: count / maxCount);
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: GoogleFonts.luckiestGuy(
                  color: Colors.white, fontSize: 28)),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  color: Colors.white54, fontSize: 11, height: 1.3)),
        ],
      );
}

class _GuessBar extends StatelessWidget {
  final int attempt, count;
  final double fraction;
  const _GuessBar(
      {required this.attempt,
      required this.count,
      required this.fraction});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Text('$attempt',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction.clamp(0.05, 1.0),
                child: Container(
                  height: 20,
                  color: _correct,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 6),
                  child: Text('$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Hata Görünümü ─────────────────────────────────────────────────────────────

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
            Text('Yüklenemedi',
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

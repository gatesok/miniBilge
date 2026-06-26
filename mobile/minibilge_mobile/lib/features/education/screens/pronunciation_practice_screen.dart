import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/pronunciation_models.dart';
import '../providers/pronunciation_provider.dart';
import '../services/pronunciation_attempt_store.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../../core/services/ad_service.dart';

class PronunciationPracticeScreen extends ConsumerStatefulWidget {
  final int levelInt;   // 1=A1 … 6=C2
  final String level;  // "A1", "B1" vb.

  const PronunciationPracticeScreen({
    super.key,
    required this.levelInt,
    required this.level,
  });

  @override
  ConsumerState<PronunciationPracticeScreen> createState() =>
      _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState
    extends ConsumerState<PronunciationPracticeScreen>
    with SingleTickerProviderStateMixin {
  static const _bgColor    = Color(0xFF0D1B2A);
  static const _accentColor = Color(0xFF7C4DFF);

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;
  String _spokenText = '';
  int _sentenceIndex = 0;
  int _attemptsLeft = 3;
  bool _isLoadingAd = false;
  bool _hasActiveSession = false; // true iken overlay gösterilmez

  late final AnimationController _micPulse;
  late final Animation<double> _pulseAnim;

  String get _currentSentence {
    final sentences = ref.read(pronunciationProvider).sentences;
    if (sentences.isEmpty) return '';
    return sentences[_sentenceIndex % sentences.length];
  }

  String? get _childId => ref.read(selectedChildProvider)?.id;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _micPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _micPulse, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Önce hak kontrolü: 0 ise cümle yükleme, overlay göster
      await _loadAttempts();
      if (!mounted) return;
      if (_attemptsLeft <= 0) return; // overlay zaten görünür

      // Hakkı düş ve cümleleri yükle
      await PronunciationAttemptStore.consumeAttempt(_childId ?? 'guest');
      await _loadAttempts();
      if (!mounted) return;
      setState(() => _hasActiveSession = true); // bu oturum boyunca overlay gösterme
      ref.read(pronunciationProvider.notifier).loadSentences(widget.levelInt);
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _micPulse.dispose();
    super.dispose();
  }

  Future<void> _loadAttempts() async {
    final id = _childId ?? 'guest';
    final left = await PronunciationAttemptStore.getAttemptsLeft(id);
    if (mounted) setState(() => _attemptsLeft = left);
  }

  Future<void> _watchAd() async {
    setState(() => _isLoadingAd = true);
    RewardedAdService.showRewardedAd(
      onRewarded: () async {
        await PronunciationAttemptStore.grantAttempt(_childId ?? 'guest');
        await _loadAttempts();
        if (!mounted) return;
        // Yeni hak kazanıldı → oturumu başlat
        await PronunciationAttemptStore.consumeAttempt(_childId ?? 'guest');
        await _loadAttempts();
        if (!mounted) return;
        setState(() => _hasActiveSession = true);
        ref.read(pronunciationProvider.notifier).loadSentences(widget.levelInt);
      },
      onComplete: () {
        if (mounted) setState(() => _isLoadingAd = false);
      },
    );
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
          _micPulse.stop();
          _micPulse.reset();
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
        _micPulse.stop();
        _micPulse.reset();
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  // ─── Mic: basılı tut → oku ────────────────────────────────────────────────

  Future<void> _startListening() async {
    if (!_speechAvailable || _isListening) return;
    setState(() {
      _isListening = true;
      _spokenText  = '';
    });
    _micPulse.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        if (mounted) setState(() => _spokenText = result.recognizedWords);
      },
      localeId: 'en_US',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _stopListeningAndEvaluate() async {
    await _speech.stop();
    _micPulse.stop();
    _micPulse.reset();
    if (mounted) setState(() => _isListening = false);

    final spoken = _spokenText.trim();
    if (spoken.isEmpty) return;

    await ref.read(pronunciationProvider.notifier).evaluate(
      targetSentence: _currentSentence,
      spokenText: spoken,
      level: widget.level,
      childProfileId: _childId,
    );
  }

  void _reset() {
    ref.read(pronunciationProvider.notifier).reset();
    setState(() => _spokenText = '');
  }

  void _nextSentence() {
    ref.read(pronunciationProvider.notifier).reset();
    setState(() {
      _spokenText = '';
      _sentenceIndex = (_sentenceIndex + 1) % ref.read(pronunciationProvider).sentences.length;
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pronunciationProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(
          'Telaffuz Koçu · ${widget.level}',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          _AttemptsChip(attemptsLeft: _attemptsLeft),
          if (state.sentences.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${_sentenceIndex + 1} / ${state.sentences.length}',
                  style: GoogleFonts.nunito(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Yükleniyor ──────────────────────────────────────────────
              if (state.isLoadingSentences) ...[  
                const SizedBox(height: 60),
                const Center(
                  child: CircularProgressIndicator(
                    color: _accentColor,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cümleler yükleniyor...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      color: Colors.white54, fontSize: 14),
                ),
              ] else ...[
              // ── Hedef cümle kartı ─────────────────────────────────────────
              _SentenceCard(sentence: _currentSentence),

              const SizedBox(height: 32),

              // ── Mikrofon bölümü ───────────────────────────────────────────
              if (state.result == null) ...[
                _MicSection(
                  isListening: _isListening,
                  speechAvailable: _speechAvailable,
                  spokenText: _spokenText,
                  pulseAnim: _pulseAnim,
                  onPressStart: _startListening,
                  onPressEnd: _stopListeningAndEvaluate,
                ),
                const SizedBox(height: 16),
              ],

              // ── Loading ───────────────────────────────────────────────────
              if (state.isEvaluating) ...[
                const SizedBox(height: 12),
                const Center(
                  child: CircularProgressIndicator(
                    color: _accentColor,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Değerlendiriliyor...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Hata ─────────────────────────────────────────────────────
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: const Color(0xFFEF5350),
                      fontSize: 14,
                    ),
                  ),
                ),

              // ── Sonuç ───────────────────────────────────────────────
              if (state.result != null) ...[  
                _ScoreCard(score: state.result!.overallScore),
                const SizedBox(height: 20),
                _WordResultsWrap(words: state.result!.words),
                const SizedBox(height: 32),
                _ActionButtons(
                  onRetry: _reset,
                  onNext: state.sentences.length > 1 ? _nextSentence : null,
                ),
                const SizedBox(height: 16),
              ],
              ], // end else
            ],
          ),
        ),
      ),
          // ── Hak Bitti Overlay ──────────────────────────────────────────
          if (_attemptsLeft <= 0 && !_hasActiveSession)
            _LimitOverlay(
              isLoadingAd: _isLoadingAd,
              onWatchAd: _watchAd,
              onBack: () { if (context.canPop()) context.pop(); },
            ),
        ],
      ),
    );
  }
}

// ─── Sentence Card ────────────────────────────────────────────────────────────

class _SentenceCard extends StatelessWidget {
  final String sentence;
  const _SentenceCard({required this.sentence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            '🎯 Şu cümleyi oku:',
            style: GoogleFonts.nunito(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            sentence,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mic Section ──────────────────────────────────────────────────────────────

class _MicSection extends StatelessWidget {
  final bool isListening;
  final bool speechAvailable;
  final String spokenText;
  final Animation<double> pulseAnim;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;

  const _MicSection({
    required this.isListening,
    required this.speechAvailable,
    required this.spokenText,
    required this.pulseAnim,
    required this.onPressStart,
    required this.onPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Okunan metin önizleme
        if (spokenText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$spokenText"',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

        // Mikrofon butonu
        GestureDetector(
          onLongPressStart: speechAvailable ? (_) => onPressStart() : null,
          onLongPressEnd:   speechAvailable ? (_) => onPressEnd()   : null,
          child: AnimatedBuilder(
            animation: pulseAnim,
              builder: (_, _) => Transform.scale(
              scale: isListening ? pulseAnim.value : 1.0,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening
                      ? const Color(0xFFEF5350)
                      : const Color(0xFF7C4DFF),
                  boxShadow: [
                    BoxShadow(
                      color: (isListening
                              ? const Color(0xFFEF5350)
                              : const Color(0xFF7C4DFF))
                          .withOpacity(0.45),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          speechAvailable
              ? (isListening ? 'Dinleniyor… bırak' : 'Basılı tut ve oku')
              : 'Mikrofon kullanılamıyor',
          style: GoogleFonts.nunito(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ─── Score Card ───────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final int score;
  const _ScoreCard({required this.score});

  Color get _color {
    if (score >= 80) return const Color(0xFF26A69A);
    if (score >= 50) return const Color(0xFFFFB300);
    return const Color(0xFFEF5350);
  }

  String get _emoji {
    if (score >= 80) return '🏆';
    if (score >= 50) return '⭐';
    return '💪';
  }

  String get _title {
    if (score >= 80) return 'Harika telaffuz!';
    if (score >= 50) return 'İyi iş!';
    return 'Tekrar deneyelim!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animasyonlu skor
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: score),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (_, val, _) => Text(
              '$val',
              style: GoogleFonts.nunito(
                color: _color,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '/100',
            style: GoogleFonts.nunito(
              color: Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _emoji,
                style: const TextStyle(fontSize: 28),
              ),
              Text(
                _title,
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Word Results ─────────────────────────────────────────────────────────────

class _WordResultsWrap extends StatelessWidget {
  final List<WordResult> words;
  const _WordResultsWrap({required this.words});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelime Analizi',
          style: GoogleFonts.nunito(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: words.map((w) => _WordChip(wordResult: w)).toList(),
        ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  final WordResult wordResult;
  const _WordChip({required this.wordResult});

  @override
  Widget build(BuildContext context) {
    final isCorrect = wordResult.isCorrect;
    final color     = isCorrect ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
    final hasHint   = !isCorrect && (wordResult.hint?.isNotEmpty ?? false);

    return GestureDetector(
      onTap: hasHint
          ? () => _showHint(context, wordResult.word, wordResult.hint!)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              wordResult.word,
              style: GoogleFonts.nunito(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (hasHint) ...[
              const SizedBox(width: 4),
              Icon(Icons.info_outline_rounded, color: color, size: 14),
            ],
          ],
        ),
      ),
    );
  }

  void _showHint(BuildContext context, String word, String hint) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2A3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.record_voice_over_rounded,
                    color: Color(0xFFEF5350), size: 22),
                const SizedBox(width: 8),
                Text(
                  '"$word" nasıl okunur?',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hint,
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback? onNext;

  const _ActionButtons({required this.onRetry, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Tekrar Dene',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        if (onNext != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                'Sonraki',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Kalan Hak Rozeti ─────────────────────────────────────────────────────────

class _AttemptsChip extends StatelessWidget {
  final int attemptsLeft;
  const _AttemptsChip({required this.attemptsLeft});

  @override
  Widget build(BuildContext context) {
    final color = attemptsLeft > 1
        ? const Color(0xFFF06292)
        : attemptsLeft == 1
            ? Colors.orange
            : Colors.red;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          '🗣️ $attemptsLeft',
          style: GoogleFonts.nunito(
              color: color, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}

// ─── Hak Bitti Overlay ────────────────────────────────────────────────────────

class _LimitOverlay extends StatelessWidget {
  final bool isLoadingAd;
  final VoidCallback onWatchAd;
  final VoidCallback onBack;

  const _LimitOverlay({
    required this.isLoadingAd,
    required this.onWatchAd,
    required this.onBack,
  });

  static const _accentColor = Color(0xFFF06292);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A3A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⏳', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  Text(
                    'Günlük Hakkın Bitti',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bugünkü 3 ücretsiz telaffuz değerlendirmeni kullandın. Kısa bir reklam izleyerek ekstra hak kazanabilirsin.',
                    style: GoogleFonts.nunito(
                      color: Colors.white60,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoadingAd ? null : onWatchAd,
                      icon: isLoadingAd
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.play_circle_outline_rounded),
                      label: Text(
                        isLoadingAd ? 'Reklam yükleniyor...' : '📺 Reklam İzle +1 Hak',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onBack,
                    child: Text(
                      'Geri Dön',
                      style: GoogleFonts.nunito(
                          color: Colors.white38, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

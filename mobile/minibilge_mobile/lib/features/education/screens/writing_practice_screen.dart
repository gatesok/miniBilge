import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/writing_models.dart';
import '../providers/writing_provider.dart';
import '../services/writing_attempt_store.dart';
import '../../../core/services/ad_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';

class WritingPracticeScreen extends ConsumerStatefulWidget {
  final String level;
  final String? episodeId;

  const WritingPracticeScreen({
    super.key,
    required this.level,
    this.episodeId,
  });

  @override
  ConsumerState<WritingPracticeScreen> createState() =>
      _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends ConsumerState<WritingPracticeScreen> {
  static const _bgColor = Color(0xFF0D1B2A);
  static const _accentColor = Color(0xFF7C4DFF);
  static const _cardColor = Color(0xFF1A2A3A);

  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;
  String _inputMethod = 'keyboard';

  // Phase: 'prompts' → 'writing'
  String _phase = 'prompts';

  // Günlük hak takibi
  int _attemptsLeft = 3;
  bool _isLoadingAd = false;

  String get _childId => ref.read(selectedChildProvider)?.id ?? 'guest';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(writingProvider.notifier)
        ..setLevel(widget.level)
        ..loadPrompts(widget.level, episodeId: widget.episodeId);
      _loadAttempts();
    });
  }

  Future<void> _loadAttempts() async {
    final left = await WritingAttemptStore.getAttemptsLeft(_childId);
    if (mounted) setState(() => _attemptsLeft = left);
  }

  Future<void> _watchAd() async {
    setState(() => _isLoadingAd = true);
    RewardedAdService.showRewardedAd(
      onRewarded: () async {
        await WritingAttemptStore.grantAttempt(_childId);
        await _loadAttempts();
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
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  // ─── Voice ─────────────────────────────────────────────────────────────────

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    setState(() {
      _isListening = true;
      _inputMethod = 'voice';
    });
    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _textController.text = result.recognizedWords;
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
          });
        }
      },
      localeId: 'en_US',
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 4),
    );
  }

  // ─── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir şeyler yaz.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    await ref
        .read(writingProvider.notifier)
        .evaluate(text, inputMethod: _inputMethod);

    // ref.listen handles navigation — no duplicate push here
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(writingProvider);

    // Watch evaluation result → hak düş + navigate
    ref.listen<WritingState>(writingProvider, (_, next) {
      if (next.result != null && !next.isEvaluating) {
        WritingAttemptStore.consumeAttempt(_childId);
        _loadAttempts();
        context.pushNamed(
          'writing-result',
          extra: {
            'result': next.result!,
            'level': widget.level,
          },
        );
      }
    });

    return Stack(
      children: [
        Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('dashboard');
            }
          },
        ),
        title: Text(
          'Yazma Pratiği · ${widget.level}',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          _AttemptsChip(attemptsLeft: _attemptsLeft),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _phase == 'prompts'
            ? _buildPromptPhase(state)
            : _buildWritingPhase(state),
      ),
    ),
        // Limit overlay — hak 0 olduğunda tam ekran gösterilir
        if (_attemptsLeft <= 0)
          _LimitOverlay(
            isLoadingAd: _isLoadingAd,
            onWatchAd: _watchAd,
            onBack: () {
              if (context.canPop()) context.pop();
              else context.goNamed('dashboard');
            },
          ),
      ],
    );
  }

  // ─── Phase 1: Prompt Seçimi ─────────────────────────────────────────────────

  Widget _buildPromptPhase(WritingState state) {
    if (state.isLoadingPrompts) {
      return const Center(
        child: CircularProgressIndicator(color: _accentColor),
      );
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
              onPressed: () => ref
                  .read(writingProvider.notifier)
                  .loadPrompts(widget.level, episodeId: widget.episodeId),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bir konu seç ve yazmaya başla ✍️',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aşağıdaki konulardan birini seçerek İngilizce yazma pratiği yap.',
            style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ...state.prompts.asMap().entries.map(
                (e) => _PromptCard(
              index: e.key,
              prompt: e.value,
              isSelected: state.selectedPrompt?.id == e.value.id,
              onTap: () {
                ref.read(writingProvider.notifier).selectPrompt(e.value);
              },
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.selectedPrompt != null
                    ? _accentColor
                    : Colors.white12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: state.selectedPrompt != null
                  ? () => setState(() => _phase = 'writing')
                  : null,
              child: Text(
                'Yazmaya Başla →',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Phase 2: Yazma ─────────────────────────────────────────────────────────

  Widget _buildWritingPhase(WritingState state) {
    final prompt = state.selectedPrompt;
    if (prompt == null) {
      setState(() => _phase = 'prompts');
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt kutusu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accentColor.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konu',
                  style: GoogleFonts.nunito(
                    color: _accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  prompt.promptText,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (prompt.context != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    prompt.context!,
                    style: GoogleFonts.nunito(
                        color: Colors.white54, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Yazı alanı
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: GoogleFonts.nunito(
                    color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(14),
                  hintText: 'Buraya İngilizce yaz...',
                  hintStyle: GoogleFonts.nunito(
                      color: Colors.white30, fontSize: 15),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                onChanged: (_) {
                  if (_inputMethod == 'voice') {
                    setState(() => _inputMethod = 'keyboard');
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Alt bar: geri + mikrofon + gönder
          Row(
            children: [
              // Geri
              _CircleBtn(
                icon: Icons.arrow_back,
                color: Colors.white24,
                onTap: () => setState(() => _phase = 'prompts'),
              ),
              const SizedBox(width: 10),

              // Mikrofon
              if (_speechAvailable)
                _CircleBtn(
                  icon: _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening
                      ? Colors.redAccent
                      : Colors.white24,
                  onTap: _toggleListening,
                ),

              const Spacer(),

              // Gönder
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                  ),
                  onPressed: state.isEvaluating ? null : _submit,
                  child: state.isEvaluating
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Değerlendir ✨',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Prompt Kartı ─────────────────────────────────────────────────────────────

class _PromptCard extends StatelessWidget {
  final int index;
  final WritingPrompt prompt;
  final bool isSelected;
  final VoidCallback onTap;

  const _PromptCard({
    required this.index,
    required this.prompt,
    required this.isSelected,
    required this.onTap,
  });

  static const List<Color> _colors = [
    Color(0xFF7C4DFF),
    Color(0xFF00BCD4),
    Color(0xFF26A69A),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : const Color(0xFF1A2A3A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.nunito(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                prompt.promptText,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Yuvarlak Buton ───────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
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
        ? const Color(0xFF26A69A)
        : attemptsLeft == 1
            ? Colors.orangeAccent
            : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note_rounded, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            '$attemptsLeft hak',
            style: GoogleFonts.nunito(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Limit Overlay ────────────────────────────────────────────────────────────

class _LimitOverlay extends StatelessWidget {
  final bool isLoadingAd;
  final VoidCallback onWatchAd;
  final VoidCallback onBack;

  const _LimitOverlay({
    required this.isLoadingAd,
    required this.onWatchAd,
    required this.onBack,
  });

  static const _accentColor = Color(0xFF7C4DFF);

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
                    'Bugünkü 3 ücretsiz yazma hakkını kullandın. Kısa bir reklam izleyerek ekstra hak kazanabilirsin.',
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isLoadingAd ? null : onWatchAd,
                      icon: isLoadingAd
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.play_circle_filled_rounded,
                              color: Colors.white),
                      label: Text(
                        isLoadingAd ? 'Yükleniyor...' : 'Reklam İzle → +1 Hak',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onBack,
                    child: Text(
                      'Geri Dön',
                      style: GoogleFonts.nunito(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
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

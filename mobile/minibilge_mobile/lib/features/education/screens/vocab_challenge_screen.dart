import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/vocab_challenge_models.dart';
import '../services/vocab_challenge_service.dart';
import '../services/vocab_attempt_store.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/services/ad_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';

class VocabChallengeScreen extends ConsumerStatefulWidget {
  final String level;

  const VocabChallengeScreen({super.key, required this.level});

  @override
  ConsumerState<VocabChallengeScreen> createState() =>
      _VocabChallengeScreenState();
}

class _VocabChallengeScreenState extends ConsumerState<VocabChallengeScreen> {
  static const _bgColor = Color(0xFF0D1B2A);
  static const _cardColor = Color(0xFF1A2A3A);
  static const _accentColor = Color(0xFF00BFA5);

  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;
  String _inputMethod = 'keyboard';

  VocabChallengeTask? _task;
  bool _isLoadingTask = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Günlük hak takibi
  int _attemptsLeft = 3;
  bool _isLoadingAd = false;

  // Hangi hedef kelimeler metinde mevcut (gerçek zamanlı)
  Set<String> _usedWords = {};

  String get _childId => ref.read(selectedChildProvider)?.id ?? 'guest';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadAttempts();
    _textController.addListener(_updateUsedWords);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _loadAttempts() async {
    final left = await VocabAttemptStore.getAttemptsLeft(_childId);
    if (mounted) setState(() => _attemptsLeft = left);
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoadingTask = true;
      _errorMessage = null;
    });
    try {
      final service = VocabChallengeService(ref.read(dioProvider));
      final task = await service.generateChallenge(
        childId: _childId,
        level: widget.level,
      );
      if (mounted) {
        setState(() {
          _task = task;
          _isLoadingTask = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTask = false;
          _errorMessage = 'Görev yüklenemedi, tekrar dene.';
        });
      }
    }
  }

  // ─── Kelime takibi ─────────────────────────────────────────────────────────

  void _updateUsedWords() {
    if (_task == null) return;
    final text = _textController.text.toLowerCase();
    final used = <String>{};
    for (final word in _task!.targetWords) {
      if (text.contains(word.toLowerCase())) used.add(word);
    }
    if (used != _usedWords) {
      setState(() => _usedWords = used);
    }
  }

  // ─── Ad / hak ─────────────────────────────────────────────────────────────

  Future<void> _watchAd() async {
    setState(() => _isLoadingAd = true);
    RewardedAdService.showRewardedAd(
      placement: AdPlacements.vocabExtraAttempt,
      onRewarded: () async {
        await VocabAttemptStore.grantAttempt(_childId);
        await _loadAttempts();
      },
      onComplete: () {
        if (mounted) setState(() => _isLoadingAd = false);
      },
    );
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

  // ─── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lütfen bir şeyler yaz.')));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final child = ref.read(selectedChildProvider);
      final service = VocabChallengeService(ref.read(dioProvider));
      final result = await service.evaluate(
        text: text,
        taskText: _task!.task,
        targetWords: _task!.targetWords,
        level: widget.level,
        inputMethod: _inputMethod,
        childProfileId: child?.id,
      );

      await VocabAttemptStore.consumeAttempt(_childId);
      await _loadAttempts();

      if (!mounted) return;
      context.pushNamed('vocab-result', extra: {
        'result': result,
        'targetWords': _task!.targetWords,
        'level': widget.level,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Değerlendirme yapılamadı, tekrar dene.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => context.canPop() ? context.pop() : context.goNamed('dashboard'),
        ),
        title: Text(
          'Kelime Meydan Okuması · ${widget.level}',
          style: GoogleFonts.nunito(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          _AttemptsChip(attemptsLeft: _attemptsLeft),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoadingTask
            ? _buildLoading()
            : _errorMessage != null
                ? _buildError()
                : _attemptsLeft <= 0
                    ? _buildLimitOverlay()
                    : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _accentColor),
            const SizedBox(height: 16),
            Text('Görev hazırlanıyor...',
                style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14)),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😵', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTask,
                style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
                child: Text('Tekrar Dene',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );

  Widget _buildLimitOverlay() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⏳', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text('Günlük hakkın doldu!',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Kısa bir reklam izleyerek +1 hak kazanabilirsin.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingAd ? null : _watchAd,
                  icon: _isLoadingAd
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.play_circle_outline),
                  label: Text(_isLoadingAd ? 'Yükleniyor...' : 'Reklam İzle (+1 Hak)',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildContent() {
    final task = _task!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görev kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accentColor.withOpacity(0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('🎯', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('Görev',
                      style: GoogleFonts.nunito(
                          color: _accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                ]),
                const SizedBox(height: 10),
                Text(task.task,
                    style: GoogleFonts.nunito(
                        color: Colors.white, fontSize: 15, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Hedef kelimeler
          Text('Kullanman gereken kelimeler:',
              style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: task.targetWords.map((word) {
              final used = _usedWords.contains(word);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: used
                      ? const Color(0xFF00BFA5).withOpacity(0.2)
                      : _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: used
                        ? const Color(0xFF00BFA5)
                        : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (used)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_circle,
                            color: Color(0xFF00BFA5), size: 14),
                      ),
                    Text(word,
                        style: GoogleFonts.nunito(
                            color: used
                                ? const Color(0xFF00BFA5)
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Yazı alanı
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: 8,
              minLines: 5,
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Hikayeni buraya yaz...',
                hintStyle: GoogleFonts.nunito(color: Colors.white38),
                border: InputBorder.none,
                filled: true,
                fillColor: _cardColor,
                contentPadding: const EdgeInsets.all(16),
              ),
              onTap: () => setState(() => _inputMethod = 'keyboard'),
            ),
          ),
          const SizedBox(height: 12),
          // Mic + Submit satırı
          Row(
            children: [
              // Mic butonu
              if (_speechAvailable)
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? Colors.red.shade700
                          : _cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _isListening ? Colors.red : Colors.white24,
                          width: 1.5),
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: _isListening ? Colors.white : Colors.white70,
                      size: 22,
                    ),
                  ),
                ),
              if (_speechAvailable) const SizedBox(width: 10),
              // Submit butonu
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Değerlendir',
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Kelime sayacı
          ValueListenableBuilder(
            valueListenable: _textController,
            builder: (_, value, __) {
              final wordCount = value.text.trim().isEmpty
                  ? 0
                  : value.text.trim().split(RegExp(r'\s+')).length;
              return Text(
                '$wordCount kelime',
                style: GoogleFonts.nunito(color: Colors.white38, fontSize: 12),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── AttemptsChip ─────────────────────────────────────────────────────────────

class _AttemptsChip extends StatelessWidget {
  final int attemptsLeft;
  const _AttemptsChip({required this.attemptsLeft});

  @override
  Widget build(BuildContext context) {
    final color = attemptsLeft > 1
        ? const Color(0xFF00BFA5)
        : attemptsLeft == 1
            ? Colors.orange
            : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '✍️ $attemptsLeft',
        style: GoogleFonts.nunito(
            color: color, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

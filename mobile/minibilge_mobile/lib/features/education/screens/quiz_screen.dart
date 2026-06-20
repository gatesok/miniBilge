import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quiz_provider.dart';
import '../models/submit_answer_response.dart';
import '../widgets/answer_widget.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/daily_quest_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/widgets/answer_feedback_overlay.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../progress/models/save_answer_attempt_request.dart';
import '../../progress/services/progress_service.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String levelId;
  final String levelName;
  final String topicName;
  final String subjectName;

  const QuizScreen({
    super.key,
    required this.levelId,
    required this.levelName,
    required this.topicName,
    this.subjectName = '',
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _isInitialized = false;
  bool _isProcessingAnswer = false;
  bool _hasNavigatedToResult = false;

  // Feedback state — sunucudan dönen sonuç
  SubmitAnswerResponse? _feedbackResult;
  String? _submittedAnswer;

  // Combo tracking
  int _consecutiveCorrect = 0;

  // TTS — son okunan soru index'i (aynı soruyu iki kere okumamak için)
  int _lastSpokenIndex = -1;
  bool _isSpeaking = false;

  bool get _isEnglish =>
      widget.subjectName.toLowerCase().contains('ingilizce') ||
      widget.subjectName.toLowerCase().contains('english');

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId) {
      setState(() {
        _isInitialized = false;
        _hasNavigatedToResult = false;
      });
      _initializeQuiz();
    }
  }

  void _initializeQuiz() {
    Future.microtask(() async {
      if (!_isInitialized) {
        ref.read(quizProvider.notifier).resetQuiz();
        await ref.read(quizProvider.notifier).startQuiz(widget.levelId);
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _hasNavigatedToResult = false;
          });
        }
      }
    });
  }

  Future<void> _speakQuestion(String text) async {
    setState(() => _isSpeaking = true);
    await TtsService.speak(text, language: _isEnglish ? 'en' : 'tr');
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _retryQuiz() {
    TtsService.stop();
    setState(() {
      _isInitialized = false;
      _hasNavigatedToResult = false;
      _lastSpokenIndex = -1;
    });
    _initializeQuiz();
  }

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  Widget _gradientScaffold(Widget body) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(child: body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    if (quizState.isCompleted && _isInitialized && !_hasNavigatedToResult) {
      TtsService.stop();
      _hasNavigatedToResult = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print('🚀 Going to quiz result screen with context.go');
          context.go('/education/quiz-result', extra: {
            'levelId': widget.levelId,
            'correctCount': quizState.correctCount,
            'wrongCount': quizState.wrongCount,
            'totalQuestions': quizState.questions.length,
            'results': quizState.results,
            'subjectName': widget.subjectName,
          });
        }
      });
    }

    if (quizState.hasError) {
      return _gradientScaffold(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😵', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  quizState.errorMessage ?? 'Sorular yüklenemedi.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _retryQuiz,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3FCC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text('Tekrar Dene',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized || quizState.isLoading) {
      return _gradientScaffold(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (quizState.questions.isEmpty) {
      return _gradientScaffold(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text('Bu seviyede henüz soru bulunmuyor',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3FCC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text('Geri Dön',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = quizState.currentQuestion;
    if (currentQuestion == null) {
      return _gradientScaffold(
        Center(
          child: Text('Soru yüklenemedi',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ),
      );
    }

    // Yeni soru geldi — İngilizce ise otomatik oku
    final currentIndex = quizState.currentQuestionIndex;
    if (_isEnglish &&
        _isInitialized &&
        currentIndex != _lastSpokenIndex &&
        !quizState.isCompleted) {
      _lastSpokenIndex = currentIndex;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !quizState.isCompleted) {
          _speakQuestion(currentQuestion.questionText);
        }
      });
    }

    final progress =
        (quizState.currentQuestionIndex + 1) / quizState.questions.length;
    final questionNumber = quizState.currentQuestionIndex + 1;
    final totalQuestions = quizState.questions.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar: back + topic + question counter
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.topicName} – ${widget.levelName}',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.28),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1.5),
                      ),
                      child: Text(
                        '$questionNumber/$totalQuestions',
                        style: GoogleFonts.luckiestGuy(
                            fontSize: 16,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF3D35CC),
                                  offset: Offset(1, 1))
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7B61FF)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Combo overlay — progress bar altında, soruların üstünde
              ComboOverlay(comboCount: _consecutiveCorrect),
              const SizedBox(height: 4),
              // Quiz content
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7B61FF).withOpacity(0.18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7B61FF).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Soru $questionNumber',
                                        style: GoogleFonts.nunito(
                                            color: const Color(0xFF7B61FF),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13),
                                      ),
                                    ),
                                    const Spacer(),
                                    // 🔊 TTS butonu — her zaman görünür
                                    GestureDetector(
                                      onTap: _isSpeaking
                                          ? () async {
                                              await TtsService.stop();
                                              if (mounted) setState(() => _isSpeaking = false);
                                            }
                                          : () => _speakQuestion(currentQuestion.questionText),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _isSpeaking
                                              ? const Color(0xFF7B61FF)
                                              : const Color(0xFF7B61FF).withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _isSpeaking
                                              ? Icons.stop_rounded
                                              : Icons.volume_up_rounded,
                                          color: _isSpeaking
                                              ? Colors.white
                                              : const Color(0xFF7B61FF),
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  currentQuestion.questionText,
                                  style: GoogleFonts.nunito(
                                      color: const Color(0xFF1A1A2E),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnswerWidget(
                            question: currentQuestion,
                            feedbackResult: _feedbackResult,
                            submittedAnswer: _submittedAnswer,
                            onAnswerSubmitted: (answer) async {
                              if (_isProcessingAnswer) return;
                              setState(() => _isProcessingAnswer = true);

                              await ref.read(quizProvider.notifier).submitAnswer(answer);

                              final result = ref.read(quizProvider).results[currentQuestion.id];
                              if (result != null && mounted) {
                                // Combo
                                if (result.isCorrect) {
                                  _consecutiveCorrect++;
                                } else {
                                  _consecutiveCorrect = 0;
                                }

                                // Daily quest + attempt log
                                final selectedChild = ref.read(selectedChildProvider);
                                if (selectedChild != null) {
                                  DailyQuestService.recordAnswer(selectedChild.id);
                                  ref.read(progressServiceProvider).saveAnswerAttempt(
                                    SaveAnswerAttemptRequest(
                                      childId: selectedChild.id,
                                      questionId: currentQuestion.id,
                                      submittedAnswer: answer,
                                      isCorrect: result.isCorrect,
                                    ),
                                  ).catchError((_) {});
                                }

                                // Ses
                                if (_consecutiveCorrect >= 3 && result.isCorrect) {
                                  SoundService.playCombo();
                                } else if (result.isCorrect) {
                                  SoundService.playCorrect();
                                } else {
                                  SoundService.playWrong();
                                }

                                // Şıkları renklendir + banner göster
                                setState(() {
                                  _feedbackResult = result;
                                  _submittedAnswer = answer;
                                });

                                // 2 saniye bekle
                                await Future.delayed(const Duration(milliseconds: 2000));

                                if (mounted) {
                                  setState(() {
                                    _feedbackResult = null;
                                    _submittedAnswer = null;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 150));
                                  ref.read(quizProvider.notifier).nextQuestion();
                                  setState(() => _isProcessingAnswer = false);
                                }
                              } else if (mounted) {
                                setState(() => _isProcessingAnswer = false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    // Loading spinner — sadece feedback yokken
                    if (_isProcessingAnswer && _feedbackResult == null)
                      Container(
                        color: Colors.black.withOpacity(0.25),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    // Feedback banner — alttan kayar, şıklar görünür kalır
                    if (_feedbackResult != null)
                      Positioned(
                        left: 0, right: 0, bottom: 0,
                        child: _FeedbackBanner(result: _feedbackResult!),
                      ),
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

// ── Feedback Banner ────────────────────────────────────────────────────────
// Alttan kayarak çıkar. Ekranı kapatmaz, şıklar görünür kalır.
class _FeedbackBanner extends StatefulWidget {
  final SubmitAnswerResponse result;
  const _FeedbackBanner({required this.result});

  @override
  State<_FeedbackBanner> createState() => _FeedbackBannerState();
}

class _FeedbackBannerState extends State<_FeedbackBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.result.isCorrect;
    final color = isCorrect ? const Color(0xFF27AE60) : const Color(0xFFE53935);
    final icon  = isCorrect ? '✓' : '✗';
    final title = isCorrect ? 'Harika! 🎉' : 'Yanlış 😕';
    final sub   = isCorrect ? null : 'Doğru cevap: ${widget.result.correctAnswer}';

    return SlideTransition(
      position: _slide,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.55), width: 2),
              ),
              child: Center(
                child: Text(icon,
                    style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: GoogleFonts.luckiestGuy(
                          fontSize: 22,
                          color: Colors.white,
                          shadows: const [Shadow(blurRadius: 0, color: Color(0x44000000), offset: Offset(1, 1))])),
                  if (sub != null) ...[
                    const SizedBox(height: 4),
                    Text(sub,
                        style: GoogleFonts.nunito(
                            fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.90))),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

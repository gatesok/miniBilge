import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/podcast_quiz_models.dart';
import '../providers/podcast_quiz_provider.dart';

class PodcastQuizScreen extends ConsumerStatefulWidget {
  final String episodeId;
  final String episodeTitle;

  const PodcastQuizScreen({
    super.key,
    required this.episodeId,
    required this.episodeTitle,
  });

  @override
  ConsumerState<PodcastQuizScreen> createState() => _PodcastQuizScreenState();
}

class _PodcastQuizScreenState extends ConsumerState<PodcastQuizScreen>
    with SingleTickerProviderStateMixin {
  bool _isNavigating = false;
  late final AnimationController _feedbackController;
  late final Animation<double> _feedbackAnimation;

  static const _bgColor = Color(0xFF0D1B2A);
  static const _accentColor = Color(0xFF26A69A);

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(podcastQuizProvider(widget.episodeId));

    // Tüm sorular cevaplandı → submit ve result ekranına git
    if (state.isComplete && !_isNavigating) {
      _isNavigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          final result = await ref
              .read(podcastQuizProvider(widget.episodeId).notifier)
              .submitQuiz();
          if (!mounted) return;
          context.pushReplacement(
            '/podcast/quiz/result',
            extra: {'result': result, 'episodeId': widget.episodeId},
          );
        } catch (_) {
          if (!mounted) return;
          context.pop();
        }
      });
    }

    // Cevap verilince feedback animasyonunu tetikle
    ref.listen<PodcastQuizState>(podcastQuizProvider(widget.episodeId), (prev, next) {
      if (!(prev?.isAnswered ?? false) && next.isAnswered) {
        _feedbackController.forward(from: 0);
      }
    });

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, state),
            _buildProgressBar(state),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PodcastQuizState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2D3E),
        border: Border(bottom: BorderSide(color: _accentColor, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anlama Testi',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: const [
                      Shadow(blurRadius: 0, color: Color(0xFF0D1B2A), offset: Offset(1, 1)),
                    ],
                  ),
                ),
                Text(
                  widget.episodeTitle,
                  style: GoogleFonts.nunito(fontSize: 11, color: _accentColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!state.isLoading && state.questions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.currentIndex + 1} / ${state.questions.length}',
                style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(PodcastQuizState state) {
    final progress = state.questions.isEmpty
        ? 0.0
        : (state.currentIndex + (state.isAnswered ? 1 : 0)) / state.questions.length;
    return LinearProgressIndicator(
      value: progress,
      minHeight: 3,
      backgroundColor: Colors.white12,
      valueColor: const AlwaysStoppedAnimation<Color>(_accentColor),
    );
  }

  Widget _buildBody(PodcastQuizState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _accentColor));
    }
    if (state.error != null) {
      return Center(
        child: Text(
          'Sorular yüklenemedi 😔\n${state.error}',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    if (state.isComplete || state.currentQuestion == null) {
      return const Center(child: CircularProgressIndicator(color: _accentColor));
    }

    return _buildQuestion(state, state.currentQuestion!);
  }

  Widget _buildQuestion(PodcastQuizState state, PodcastQuizQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Soru tipi badge
          _QuestionTypeBadge(type: PodcastQuestionType.fromValue(question.questionType)),
          const SizedBox(height: 16),
          // Soru metni
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2D3E),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              question.questionText,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Şıklar
          ...question.options.map((option) => _buildOption(state, option)),
          // Sonraki buton (cevap verildikten sonra)
          if (state.isAnswered) ...[
            const SizedBox(height: 24),
            ScaleTransition(
              scale: _feedbackAnimation,
              child: GestureDetector(
                onTap: () => ref
                    .read(podcastQuizProvider(widget.episodeId).notifier)
                    .nextQuestion(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26A69A), Color(0xFF00695C)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    state.isLastQuestion ? '✅  Sonuçları Gör' : '➡️  Sonraki Soru',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(PodcastQuizState state, PodcastQuizOption option) {
    final labels = ['A', 'B', 'C', 'D'];
    final label = option.displayOrder < labels.length ? labels[option.displayOrder] : '?';
    final isSelected = state.selectedAnswer == option.optionText;
    final isAnswered = state.isAnswered;

    Color borderColor = Colors.white.withOpacity(0.15);
    Color bgColor = Colors.white.withOpacity(0.05);
    Color labelColor = Colors.white54;
    IconData? trailingIcon;

    if (isAnswered && isSelected) {
      // Bu sprint'te backend'den doğru cevabı bilmiyoruz (sadece submit sonrası)
      // Seçilen şık vurgulanır; doğru/yanlış result ekranında gösterilir
      borderColor = _accentColor;
      bgColor = _accentColor.withOpacity(0.15);
      labelColor = _accentColor;
    }

    return GestureDetector(
      onTap: isAnswered ? null : () {
        ref
            .read(podcastQuizProvider(widget.episodeId).notifier)
            .selectAnswer(option.optionText);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _accentColor : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : labelColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.optionText,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ),
            if (trailingIcon != null) Icon(trailingIcon, size: 20, color: labelColor),
          ],
        ),
      ),
    );
  }
}

// ─── Soru tipi badge ─────────────────────────────────────────────────────────

class _QuestionTypeBadge extends StatelessWidget {
  final PodcastQuestionType type;

  const _QuestionTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      PodcastQuestionType.multipleChoice => ('Çoktan Seçmeli', const Color(0xFF26A69A)),
      PodcastQuestionType.trueFalse => ('Doğru / Yanlış', const Color(0xFFFF7043)),
      PodcastQuestionType.vocabularyMeaning => ('Kelime Anlamı', const Color(0xFF9C27B0)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

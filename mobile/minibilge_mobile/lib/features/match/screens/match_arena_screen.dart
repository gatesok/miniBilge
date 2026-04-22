import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/match_provider.dart';

/// Match arena screen - real-time gameplay with questions and answers
class MatchArenaScreen extends ConsumerStatefulWidget {
  final String matchId;

  const MatchArenaScreen({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<MatchArenaScreen> createState() => _MatchArenaScreenState();
}

class _MatchArenaScreenState extends ConsumerState<MatchArenaScreen> {
  String? _selectedAnswer;
  bool _isAnswering = false;
  bool _opponentAnswered = false;
  int _timeLeft = 30;
  Timer? _timer;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinMatch();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 1) {
        t.cancel();
        // Auto-submit empty if time runs out
        if (_selectedAnswer == null && !_isAnswering) {
          _submitAnswer('');
        }
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _joinMatch() {
    ref.read(matchProvider.notifier).joinMatch(widget.matchId);
  }

  void _submitAnswer(String answer) async {
    // Block if already answered or local state is answering
    final matchState = ref.read(matchProvider);
    if (_isAnswering || matchState.hasAnsweredCurrentQuestion) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswering = true;
    });
    _timer?.cancel();

    await ref.read(matchProvider.notifier).submitAnswer(answer);
    // Keep _isAnswering=true and input locked - only unlock when QuestionAdvance arrives
    // (handled by ref.listen in build, which calls _onQuestionAdvanced)
  }

  void _onQuestionAdvanced() {
    setState(() {
      _isAnswering = false;
      _selectedAnswer = null;
      _opponentAnswered = false;
    });
    _textController.clear();
  }

  void _leaveMatch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yarıştan Ayrıl'),
        content: const Text(
          'Yarıştan ayrılırsan rakibin kazanacak. Emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(matchProvider.notifier).leaveMatch();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ayrıl'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final myParticipant = matchState.myParticipant;
    final opponent = matchState.opponent;
    final currentQuestion = matchState.currentQuestion;

    // Listen for match completion and question advance
    ref.listen<MatchState>(matchProvider, (previous, next) {
      if (next.status == MatchStatus.completed) {
        context.pushReplacement(
          '/match/result?matchId=${next.currentMatch!.id}',
        );
      }
      // When question index advances, reset local state and restart timer
      if (previous != null &&
          next.currentQuestionIndex != previous.currentQuestionIndex) {
        _onQuestionAdvanced();
        _startTimer();
      }
    });

    // Start timer when match becomes active
    if (matchState.status == MatchStatus.inMatch && _timer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
    }

    if (matchState.status == MatchStatus.error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(matchState.error ?? 'Bir hata oluştu'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _joinMatch,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (myParticipant == null || opponent == null || currentQuestion == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final questionNumber = matchState.currentQuestionIndex + 1;
    final totalQuestions = matchState.currentMatch!.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Soru $questionNumber/$totalQuestions'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _leaveMatch,
        ),
        actions: [
          // Timer could go here
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '⏱️ ${_timeLeft}s',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 10 ? Colors.red : null,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Player scores section
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Player score
                  _buildScoreCard(
                    context: context,
                    name: myParticipant.childName,
                    score: myParticipant.score,
                    isPlayer: true,
                    avatarId: myParticipant.avatarId,
                    hasAnswered: _selectedAnswer != null,
                  ),

                  // VS indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'VS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                  // Opponent score
                  _buildScoreCard(
                    context: context,
                    name: opponent.childName,
                    score: opponent.score,
                    isPlayer: false,
                    avatarId: opponent.avatarId,
                    hasAnswered: _opponentAnswered,
                  ),
                ],
              ),
            ),

            // Question section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question text
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        currentQuestion.questionText,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Waiting for opponent banner
                    if (matchState.hasAnsweredCurrentQuestion) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Rakip cevaplıyor...'),
                          ],
                        ),
                      ),
                    ] else ...[
                    // Answer options or text input
                    if (currentQuestion.options.isNotEmpty)
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final optionLetter =
                          String.fromCharCode(65 + index); // A, B, C, D

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildAnswerOption(
                          context: context,
                          letter: optionLetter,
                          text: option,
                          isSelected: _selectedAnswer == optionLetter,
                          onTap: _isAnswering
                              ? null
                              : () => _submitAnswer(optionLetter),
                        ),
                      );
                    })
                    else ...[
                      // Open-ended: text input
                      TextField(
                        controller: _textController,
                        enabled: !_isAnswering && _selectedAnswer == null,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                        decoration: InputDecoration(
                          hintText: 'Cevabını yaz...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (v) {
                          if (v.isNotEmpty) _submitAnswer(v.trim());
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: (_isAnswering || _selectedAnswer != null)
                            ? null
                            : () {
                                final v = _textController.text.trim();
                                if (v.isNotEmpty) _submitAnswer(v);
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cevapla',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ],
                    ], // end of else (not hasAnsweredCurrentQuestion)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required BuildContext context,
    required String name,
    required int score,
    required bool isPlayer,
    int? avatarId,
    bool hasAnswered = false,
  }) {
    return Column(
      children: [
        // Avatar or placeholder
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isPlayer
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasAnswered ? Colors.green : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            if (hasAnswered)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score puan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerOption({
    required BuildContext context,
    required String letter,
    required String text,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Row(
          children: [
            // Option letter
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Option text
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

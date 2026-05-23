import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/match_provider.dart';

class MatchArenaScreen extends ConsumerStatefulWidget {
  final String matchId;
  const MatchArenaScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchArenaScreen> createState() => _MatchArenaScreenState();
}

class _MatchArenaScreenState extends ConsumerState<MatchArenaScreen> {
  String? _selectedAnswer;
  bool _isAnswering = false;
  bool _opponentAnswered = false;
  int _timeLeft = 45;
  Timer? _timer;
  final TextEditingController _textController = TextEditingController();

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  static const _optionColors = [
    Color(0xFF3498DB), // A - blue
    Color(0xFF2ECC71), // B - green
    Color(0xFFE67E22), // C - orange
    Color(0xFF9B59B6), // D - purple
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _joinMatch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    final tpq = ref.read(matchProvider).timePerQuestion;
    setState(() => _timeLeft = tpq);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 1) {
        t.cancel();
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
    final matchState = ref.read(matchProvider);
    if (_isAnswering || matchState.hasAnsweredCurrentQuestion) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswering = true;
    });
    _timer?.cancel();
    await ref.read(matchProvider.notifier).submitAnswer(answer);
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: Colors.white.withOpacity(0.45), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('⚠️ Yarıştan Ayrıl',
                  style: GoogleFonts.luckiestGuy(
                      fontSize: 22,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                            blurRadius: 0,
                            color: Color(0xFF3D35CC),
                            offset: Offset(2, 2))
                      ])),
              const SizedBox(height: 16),
              Text(
                  'Yarıştan ayrılırsan rakibin kazanacak. Emin misin?',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.45)),
                        ),
                        child: Center(
                          child: Text('İptal',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        ref.read(matchProvider.notifier).leaveMatch();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFFFF5252),
                            Color(0xFFE53935)
                          ]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text('Ayrıl',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final myParticipant = matchState.myParticipant;
    final opponent = matchState.opponent;
    final currentQuestion = matchState.currentQuestion;

    ref.listen<MatchState>(matchProvider, (previous, next) {
      if (next.status == MatchStatus.completed) {
        context.pushReplacement(
            '/match/result?matchId=${next.currentMatch!.id}');
      }
      if (previous != null &&
          next.currentQuestionIndex != previous.currentQuestionIndex) {
        _onQuestionAdvanced();
        _startTimer();
      }
    });

    if (matchState.status == MatchStatus.inMatch && _timer == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _startTimer());
    }

    if (matchState.status == MatchStatus.error) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _gradient),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  Text(matchState.error ?? 'Bir hata oluştu',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _joinMatch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                          color: const Color(0xFF7B61FF),
                          borderRadius: BorderRadius.circular(24)),
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
        ),
      );
    }

    if (myParticipant == null ||
        opponent == null ||
        currentQuestion == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _gradient),
          child: const SafeArea(
            child: Center(
                child: CircularProgressIndicator(color: Colors.white)),
          ),
        ),
      );
    }

    final questionNumber = matchState.currentQuestionIndex + 1;
    final totalQuestions =
        matchState.currentMatch!.questions.length;
    final isUrgent = _timeLeft <= 15;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _leaveMatch,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Soru $questionNumber/$totalQuestions',
                        style: GoogleFonts.luckiestGuy(
                            fontSize: 20,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF3D35CC),
                                  offset: Offset(2, 2))
                            ]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Timer pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? const Color(0xFFFF5252).withOpacity(0.85)
                            : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⏱️',
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text('${_timeLeft}s',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Player score bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.45),
                        width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      _PlayerCard(
                        name: myParticipant.childName,
                        score: myParticipant.score,
                        isPlayer: true,
                        hasAnswered: _selectedAnswer != null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFF7B61FF),
                            Color(0xFFE88EC9)
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('VS',
                            style: GoogleFonts.luckiestGuy(
                                fontSize: 18,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                      blurRadius: 0,
                                      color: Color(0xFF3D35CC),
                                      offset: Offset(1, 1))
                                ])),
                      ),
                      _PlayerCard(
                        name: opponent.childName,
                        score: opponent.score,
                        isPlayer: false,
                        hasAnswered: _opponentAnswered,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Question + answers
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.45),
                              width: 1.5),
                        ),
                        child: Text(
                          currentQuestion.questionText,
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Waiting banner or answer options
                      if (matchState.hasAnsweredCurrentQuestion) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.45)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Text('Rakip cevaplıyor...',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ],
                          ),
                        ),
                      ] else ...[
                        if (currentQuestion.options.isNotEmpty)
                          ...currentQuestion.options
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            final letter =
                                String.fromCharCode(65 + index);
                            final color = _optionColors[
                                index % _optionColors.length];
                            final isSelected =
                                _selectedAnswer == letter;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 12),
                              child: GestureDetector(
                                onTap: _isAnswering
                                    ? null
                                    : () => _submitAnswer(letter),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color.withOpacity(0.4)
                                        : Colors.white.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                        color: isSelected
                                            ? color
                                            : Colors.white
                                                .withOpacity(0.4),
                                        width: isSelected ? 2.5 : 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? color
                                              : color.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(letter,
                                              style: GoogleFonts.nunito(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  fontSize: 15)),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(option,
                                            style: GoogleFonts.nunito(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.w700,
                                                fontSize: 15)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                        else ...[
                          // Open-ended text input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.45),
                                  width: 1.5),
                            ),
                            child: TextField(
                              controller: _textController,
                              enabled: !_isAnswering &&
                                  _selectedAnswer == null,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24),
                              decoration: InputDecoration(
                                hintText: 'Cevabını yaz...',
                                hintStyle: GoogleFonts.nunito(
                                    color: Colors.white.withOpacity(0.5),
                                    fontWeight: FontWeight.w700),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(20),
                              ),
                              onSubmitted: (v) {
                                if (v.isNotEmpty) _submitAnswer(v.trim());
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Submit button
                          GestureDetector(
                            onTap: (_isAnswering ||
                                    _selectedAnswer != null)
                                ? null
                                : () {
                                    final v =
                                        _textController.text.trim();
                                    if (v.isNotEmpty) _submitAnswer(v);
                                  },
                            child: Opacity(
                              opacity: (_isAnswering ||
                                      _selectedAnswer != null)
                                  ? 0.5
                                  : 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3D35CC),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF9B59B6),
                                          Color(0xFF7B61FF)
                                        ]),
                                    borderRadius:
                                        BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Text('CEVAPLA 🚀',
                                        style: GoogleFonts.luckiestGuy(
                                            fontSize: 20,
                                            color: Colors.white,
                                            shadows: const [
                                              Shadow(
                                                  blurRadius: 0,
                                                  color: Color(0xFF3D35CC),
                                                  offset: Offset(1, 1))
                                            ])),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String name;
  final int score;
  final bool isPlayer;
  final bool hasAnswered;

  const _PlayerCard({
    required this.name,
    required this.score,
    required this.isPlayer,
    required this.hasAnswered,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isPlayer ? const Color(0xFF7B61FF) : const Color(0xFFE67E22);

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)]),
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasAnswered
                      ? Colors.greenAccent
                      : Colors.white.withOpacity(0.4),
                  width: hasAnswered ? 3 : 2,
                ),
              ),
              child: Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: GoogleFonts.luckiestGuy(
                      fontSize: 22,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                            blurRadius: 0,
                            color: Color(0xFF3D35CC),
                            offset: Offset(1, 1))
                      ]),
                ),
              ),
            ),
            if (hasAnswered)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(name,
            style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        const SizedBox(height: 2),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$score puan',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ),
      ],
    );
  }
}

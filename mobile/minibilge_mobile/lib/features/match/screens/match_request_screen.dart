import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/match_provider.dart';

class MatchRequestScreen extends ConsumerStatefulWidget {
  final String? subjectId;
  final String? subjectName;
  final String? levelId;
  final int? competitionType;
  final String? competitionTopicKey;
  final String? competitionDifficulty;

  const MatchRequestScreen({
    super.key,
    this.subjectId,
    this.subjectName,
    this.levelId,
    this.competitionType,
    this.competitionTopicKey,
    this.competitionDifficulty,
  });

  @override
  ConsumerState<MatchRequestScreen> createState() => _MatchRequestScreenState();
}

class _MatchRequestScreenState extends ConsumerState<MatchRequestScreen>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  int _secondsElapsed = 0;
  static const int _maxWaitSeconds = 60;
  late AnimationController _animationController;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestMatch());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
      if (_secondsElapsed >= _maxWaitSeconds) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _requestMatch() {
    ref
        .read(matchProvider.notifier)
        .requestMatch(
          subjectId: widget.subjectId,
          levelId: widget.levelId,
          competitionType: widget.competitionType,
          competitionTopicKey: widget.competitionTopicKey,
          competitionDifficulty: widget.competitionDifficulty,
        );
  }

  void _handleTimeout() {
    ref.read(matchProvider.notifier).cancelMatchRequest();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rakip bulunamadı. Lütfen daha sonra tekrar deneyin.'),
          backgroundColor: Colors.orange,
        ),
      );
      context.go('/dashboard');
    }
  }

  void _cancelRequest() async {
    await ref.read(matchProvider.notifier).cancelMatchRequest();
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MatchState>(matchProvider, (previous, next) {
      if (next.status == MatchStatus.matchFound && next.currentMatch != null) {
        context.pushReplacement(
          '/match/arena?matchId=${next.currentMatch!.id}',
        );
      } else if (next.status == MatchStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? 'Bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final remainingSeconds = _maxWaitSeconds - _secondsElapsed;
    final progress = _secondsElapsed / _maxWaitSeconds;
    final isUrgent = remainingSeconds <= 10;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spinning search icon
                  RotationTransition(
                    turns: _animationController,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text('🔍', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Title
                  Text(
                    'Rakip Aranıyor...',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 32,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          blurRadius: 0,
                          color: Color(0xFF3D35CC),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Seninle yarışacak bir rakip buluyoruz',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Countdown timer card
                  Container(
                    width: 180,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isUrgent
                            ? Colors.redAccent.withOpacity(0.7)
                            : Colors.white.withOpacity(0.45),
                        width: isUrgent ? 2.5 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Kalan Süre',
                          style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.75),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$remainingSeconds',
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 56,
                            color: isUrgent
                                ? const Color(0xFFFF5252)
                                : Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 0,
                                color: isUrgent
                                    ? const Color(0xFF8B0000)
                                    : const Color(0xFF3D35CC),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'saniye',
                          style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.75),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Progress bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isUrgent
                                ? [
                                    const Color(0xFFFF5252),
                                    const Color(0xFFFF1744),
                                  ]
                                : [
                                    const Color(0xFF7B61FF),
                                    const Color(0xFFE88EC9),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Cancel button (3D style)
                  GestureDetector(
                    onTap: _cancelRequest,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B0000),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5252), Color(0xFFE53935)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'İptal Et',
                              style: GoogleFonts.luckiestGuy(
                                fontSize: 20,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 0,
                                    color: Color(0xFF8B0000),
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/match_provider.dart';

/// Match request screen - shows "Finding opponent" with countdown
class MatchRequestScreen extends ConsumerStatefulWidget {
  const MatchRequestScreen({super.key});

  @override
  ConsumerState<MatchRequestScreen> createState() => _MatchRequestScreenState();
}

class _MatchRequestScreenState extends ConsumerState<MatchRequestScreen>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  int _secondsElapsed = 0;
  static const int _maxWaitSeconds = 60;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startCountdown();
    
    // Delay provider modification until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestMatch();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });

      if (_secondsElapsed >= _maxWaitSeconds) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _requestMatch() {
    ref.read(matchProvider.notifier).requestMatch();
  }

  void _handleTimeout() {
    // Cancel request and go back
    ref.read(matchProvider.notifier).cancelMatchRequest();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rakip bulunamadı. Lütfen daha sonra tekrar deneyin.'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _cancelRequest() async {
    await ref.read(matchProvider.notifier).cancelMatchRequest();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for match found
    ref.listen<MatchState>(matchProvider, (previous, next) {
      if (next.status == MatchStatus.matchFound && next.currentMatch != null) {
        // Navigate to match arena
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

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated search icon
                  RotationTransition(
                    turns: _animationController,
                    child: Icon(
                      Icons.sync,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Rakip Aranıyor...',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Seninle yarışacak bir rakip buluyoruz',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Countdown timer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Kalan Süre',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$remainingSeconds',
                          style:
                              Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: remainingSeconds <= 10
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                        Text(
                          'saniye',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Progress indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: _secondsElapsed / _maxWaitSeconds,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Cancel button
                  ElevatedButton.icon(
                    onPressed: _cancelRequest,
                    icon: const Icon(Icons.close),
                    label: const Text('İptal Et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

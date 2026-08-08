import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/submit_answer_response.dart';
import '../models/question.dart';
import '../models/certificate_data.dart';
import '../widgets/achievement_certificate.dart';
import 'package:confetti/confetti.dart';
import '../../progress/services/progress_service.dart';
import '../../progress/models/save_progress_request.dart';
import '../../progress/providers/progress_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/streak_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/dio_provider.dart';
import '../services/topic_explanation_service.dart';
import '../../../core/widgets/card_drop_animation.dart';
import '../../../core/widgets/badge_earned_overlay.dart';
import '../../collection/models/card_dto.dart';
import '../../collection/providers/collection_provider.dart';
import '../../challenge/providers/challenge_provider.dart';
import '../../challenge/widgets/challenge_result_card.dart';
import 'package:share_plus/share_plus.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  final String levelId;
  final int correctCount;
  final int wrongCount;
  final int totalQuestions;
  final Map<String, SubmitAnswerResponse> results;
  final List<Question> questions;
  final String subjectName;
  final String topicName;

  /// Quiz toplam tamamlanma süresi (saniye) — Hız Treni rozeti için.
  final int? quizDurationSeconds;

  /// En hızlı doğru cevabın süresi (saniye) — Şimşek rozeti için.
  final int? fastestCorrectAnswerSeconds;

  /// Async meydan okuma modunda challenge ID'si (null ise normal quiz)
  final String? challengeId;

  const QuizResultScreen({
    super.key,
    required this.levelId,
    required this.correctCount,
    required this.wrongCount,
    required this.totalQuestions,
    required this.results,
    this.questions = const [],
    this.subjectName = '',
    this.topicName = '',
    this.quizDurationSeconds,
    this.fastestCorrectAnswerSeconds,
    this.challengeId,
  });

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  ConfettiController? _confettiController;
  int? _earnedScore;
  int? _earnedStars;
  bool _progressSaved = false;
  bool _confettiStarted = false;
  CardDropResult? _cardDrop;
  List<String> _earnedBadges = [];
  CertificateData? _certificateData;

  /// Meydan okuma sonucu mesajı — score submit sonrası set edilir
  String? _challengeResultMessage;
  bool _isLoadingExplanation = false;

  bool get _isEnglish {
    final s = widget.subjectName.toLowerCase();
    return s.contains('ingilizce') || s.contains('english');
  }

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  void initState() {
    super.initState();
    debugPrint('🎊 QuizResultScreen initState - levelId: ${widget.levelId}');
    debugPrint(
      '📊 Results: ${widget.correctCount}/${widget.totalQuestions} correct',
    );

    try {
      _confettiController = ConfettiController(
        duration: const Duration(seconds: 3),
      );
      if (_isPassed && !_confettiStarted) {
        _confettiStarted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _confettiController != null) {
            try {
              debugPrint('🎉 Playing confetti animation');
              _confettiController!.play();
              SoundService.playWin();
            } catch (e) {
              debugPrint('[QuizResult] Error playing confetti: $e');
            }
          }
        });
      } else if (!_isPassed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SoundService.playLose();
        });
      }
    } catch (e) {
      debugPrint('[QuizResult] Error creating confetti controller: $e');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _saveProgress();
    });
  }

  Future<void> _saveProgress() async {
    if (!mounted) {
      debugPrint('[QuizResult] Widget not mounted, skipping progress save');
      return;
    }
    try {
      ChildProfileDto? selectedChild;
      ProgressService? progressService;
      try {
        selectedChild = ref.read(selectedChildProvider);
        progressService = ref.read(progressServiceProvider);
      } catch (e) {
        debugPrint('❌ Error reading ref: $e');
        return;
      }
      if (selectedChild == null) {
        debugPrint('Selected child bulunamadı');
        return;
      }
      // Yetişkin meydan okuması eğitim LevelId'sine bağlı değildir. Eğitim
      // progress endpoint'ine boş LevelId göndermeden yalnızca challenge
      // skorunu kaydet; sonuç ekranının geri kalanı aynen kullanılır.
      if (widget.challengeId != null && widget.levelId.isEmpty) {
        final updated = await ref
            .read(challengeNotifierProvider.notifier)
            .submitScore(widget.challengeId!, widget.correctCount);
        CardDropResult? rewardCard;
        if (updated?.rewardCardDropped == true &&
            updated?.rewardCardId != null &&
            updated?.rewardCardName != null &&
            updated?.rewardCardRarity != null &&
            updated?.rewardCardImageAsset != null) {
          rewardCard = CardDropResult(
            cardId: updated!.rewardCardId!,
            cardName: updated.rewardCardName!,
            rarity: updated.rewardCardRarity!,
            imageAsset: updated.rewardCardImageAsset!,
            isNew: updated.rewardCardIsNew,
          );
        }
        ref.invalidate(cardCollectionProvider(selectedChild.id));
        ref.invalidate(badgeCollectionProvider(selectedChild.id));
        await ref.read(childProfileProvider.notifier).loadProfiles();
        final challengeBadges = updated?.rewardBadges ?? const <String>[];
        if (mounted) {
          setState(() {
            _earnedScore = widget.correctCount * 10;
            _earnedStars = updated?.rewardStars ?? 0;
            _progressSaved = true;
            _challengeResultMessage = updated?.resultMessage;
            _cardDrop = rewardCard;
            _earnedBadges = challengeBadges;
          });
        }
        if (rewardCard != null && mounted) {
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            await CardDropAnimation.show(context, drop: rewardCard);
          }
        }
        if (challengeBadges.isNotEmpty && mounted) {
          await BadgeEarnedOverlay.showQueue(context, challengeBadges);
        }
        return;
      }
      if (progressService == null) {
        debugPrint('Progress service bulunamadı');
        return;
      }
      final successPercentage =
          (widget.correctCount / widget.totalQuestions) * 100;
      final isEnglish =
          widget.subjectName.toLowerCase().contains('ingilizce') ||
          widget.subjectName.toLowerCase().contains('english');
      final request = SaveProgressRequest(
        childId: selectedChild.id,
        levelId: widget.levelId,
        correctCount: widget.correctCount,
        totalQuestions: widget.totalQuestions,
        successPercentage: successPercentage,
        subjectName: widget.subjectName.isNotEmpty ? widget.subjectName : null,
        englishLevel: isEnglish ? 'english' : null,
        quizDurationSeconds: widget.quizDurationSeconds,
        fastestCorrectAnswerSeconds: widget.fastestCorrectAnswerSeconds,
      );
      debugPrint('💾 Saving progress...');
      final response = await progressService.saveProgress(request);

      // Always invalidate providers after successful save, regardless of mount state.
      ref.invalidate(childProgressProvider(selectedChild.id));
      ref.invalidate(levelResultsProvider(selectedChild.id));

      if (!mounted) {
        debugPrint(
          '[QuizResult] Widget unmounted after saveProgress — providers invalidated, skipping UI update',
        );
        return;
      }

      // Kart drop parse et
      CardDropResult? cardDrop;
      if (response['cardDrop'] != null) {
        try {
          cardDrop = CardDropResult.fromJson(
            response['cardDrop'] as Map<String, dynamic>,
          );
        } catch (e) {
          debugPrint('[QuizResult] cardDrop parse hatası: $e');
        }
      }

      // Kazanılan rozetler
      List<String> badges = [];
      if (response['earnedBadges'] is List) {
        badges = (response['earnedBadges'] as List)
            .map((e) => e.toString())
            .toList();
      }

      CertificateData? certificate;
      if (response['certificate'] is Map) {
        certificate = CertificateData.fromJson(
          Map<String, dynamic>.from(response['certificate'] as Map),
        );
      }

      setState(() {
        _earnedScore = response['score'] as int?;
        _earnedStars = response['stars'] as int?;
        _progressSaved = true;
        _cardDrop = cardDrop;
        _earnedBadges = badges;
        _certificateData = certificate;
      });
      debugPrint(
        'Progress kaydedildi: Score=$_earnedScore, Stars=$_earnedStars, card=$cardDrop, badges=$badges',
      );

      // Kart animasyonu göster + koleksiyon cache'i temizle
      if (cardDrop != null) {
        ref.invalidate(cardCollectionProvider(selectedChild.id));
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            await CardDropAnimation.show(context, drop: cardDrop);
          }
        }
      }

      // Rozet gelince badge cache'i de temizle + ortak overlay ile göster
      if (badges.isNotEmpty) {
        ref.invalidate(badgeCollectionProvider(selectedChild.id));
        if (mounted) {
          await BadgeEarnedOverlay.showQueue(context, badges);
        }
      }

      // Streak güncelle
      await StreakService.recordActivity(selectedChild.id);
      await ref.read(childProfileProvider.notifier).loadProfiles();

      // Async meydan okuma: skoru gönder
      if (widget.challengeId != null) {
        try {
          final updated = await ref
              .read(challengeNotifierProvider.notifier)
              .submitScore(widget.challengeId!, widget.correctCount);
          if (mounted && updated?.resultMessage != null) {
            setState(() => _challengeResultMessage = updated!.resultMessage);
          }
        } catch (e) {
          debugPrint('[QuizResult] Challenge score submit hatası: $e');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Progress kaydedilirken hata: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    debugPrint('[QuizResult] dispose called');
    _confettiController?.dispose();
    _confettiController = null;
    super.dispose();
  }

  bool get _isPassed {
    final successPercentage =
        (widget.correctCount / widget.totalQuestions) * 100;
    return successPercentage >= 70;
  }

  /// Challenge modunda gösterilecek büyük sonuç ikonu.
  IconData get _resultIcon {
    if (widget.challengeId == null || _challengeResultMessage == null) {
      return _isPassed ? Icons.emoji_events_rounded : Icons.trending_up_rounded;
    }
    if (_challengeResultMessage!.contains('Kazandın')) {
      return Icons.emoji_events_rounded;
    }
    if (_challengeResultMessage!.contains('Berabere')) {
      return Icons.handshake_rounded;
    }
    return Icons.sentiment_dissatisfied_rounded;
  }

  /// Challenge modunda gösterilecek başlık metni
  String get _resultTitle {
    if (widget.challengeId == null || _challengeResultMessage == null) {
      return _isPassed ? 'Tebrikler!' : 'Daha fazla çalışmalısın!';
    }
    if (_challengeResultMessage!.contains('Kazandın')) return 'Kazandın!';
    if (_challengeResultMessage!.contains('Berabere')) return 'Berabere!';
    return 'Kaybettin!';
  }

  // ─── Konu Anlatımı ────────────────────────────────────────────────────────

  String get _cefrLevel {
    final child = ref.read(selectedChildProvider);
    return child?.englishLevel?.toUpperCase() ?? 'B1';
  }

  Future<void> _requestExplanation() async {
    final isPremium = ref
        .read(authProvider)
        .maybeWhen(
          authenticated: (user) => user.isPremium,
          orElse: () => false,
        );
    if (!isPremium) {
      context.push('/premium');
      return;
    }
    setState(() => _isLoadingExplanation = true);
    // Soru metni + yanlış cevap + doğru cevap bilgisini birleştir
    final questionMap = {for (final q in widget.questions) q.id: q};
    final wrongTopics = widget.results.entries
        .where((e) => !e.value.isCorrect)
        .map((e) {
          final q = questionMap[e.key];
          final questionText = q?.questionText ?? '';
          final correctAnswer = e.value.correctAnswer;
          if (questionText.isNotEmpty) {
            return 'Soru: "$questionText" → Doğru cevap: "$correctAnswer"';
          }
          return 'Doğru cevap: "$correctAnswer"';
        })
        .toList();
    try {
      final service = TopicExplanationService(ref.read(dioProvider));
      final topicLabel = widget.topicName.isNotEmpty
          ? widget.topicName
          : widget.subjectName;
      final explanation = await service.explain(
        level: _cefrLevel,
        subjectName: topicLabel,
        wrongTopics: wrongTopics,
      );
      if (!mounted) return;
      _showExplanationSheet(explanation);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingExplanation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konu anlatımı yüklenemedi, tekrar dene.'),
        ),
      );
    }
  }

  void _showExplanationSheet(dynamic explanation) {
    setState(() => _isLoadingExplanation = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TopicExplanationSheet(
        subjectName: widget.topicName.isNotEmpty
            ? widget.topicName
            : widget.subjectName,
        explanation: explanation,
      ),
    );
  }

  Future<void> _shareCertificate() async {
    final isPremium = ref
        .read(authProvider)
        .maybeWhen(
          authenticated: (user) => user.isPremium,
          orElse: () => false,
        );
    if (!isPremium) {
      final openPremium = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFFFFA000),
            size: 44,
          ),
          title: const Text('Premium Özelliği'),
          content: const Text(
            'Başarı sertifikası oluşturmak ve paylaşmak için Premium üye '
            'olmalısın.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Şimdilik Değil'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.workspace_premium_rounded),
              label: const Text('Premium’a Geç'),
            ),
          ],
        ),
      );
      if (openPremium == true && mounted) context.push('/premium');
      return;
    }

    final certificate = _certificateData;
    if (certificate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sertifika hazırlanıyor. Lütfen kısa süre sonra dene.'),
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CertificateDialog(certificate: certificate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final successPercentage =
        (widget.correctCount / widget.totalQuestions) * 100;
    final successColor = _isPassed ? Colors.green : Colors.orange;
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final scale = isTablet ? 1.2 : 1.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 16,
                      vertical: 12 * scale,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Sonuç',
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 24 * scale,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 32 : 16,
                        0,
                        isTablet ? 32 : 16,
                        24,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 720 : double.infinity,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 8 * scale),
                              Icon(
                                _resultIcon,
                                size: 80 * scale,
                                color: _isPassed
                                    ? Colors.amberAccent
                                    : Colors.white,
                              ),
                              SizedBox(height: 8 * scale),
                              Text(
                                _resultTitle,
                                style: GoogleFonts.luckiestGuy(
                                  fontSize: 28 * scale,
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
                              SizedBox(height: 24 * scale),
                              // Async meydan okuma sonuç mesajı
                              if (_challengeResultMessage != null)
                                ChallengeResultCard(
                                  resultMessage: _challengeResultMessage!,
                                ),
                              // Score card
                              Container(
                                padding: EdgeInsets.all(24 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(
                                    28 * scale,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Circular progress
                                    SizedBox(
                                      width: 150 * scale,
                                      height: 150 * scale,
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: SizedBox(
                                              width: 150 * scale,
                                              height: 150 * scale,
                                              child: CircularProgressIndicator(
                                                value: successPercentage / 100,
                                                strokeWidth: 14 * scale,
                                                backgroundColor: Colors.white
                                                    .withValues(alpha: 0.2),
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(successColor),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${successPercentage.toStringAsFixed(0)}%',
                                                  style:
                                                      GoogleFonts.luckiestGuy(
                                                        fontSize: 36 * scale,
                                                        color: Colors.white,
                                                        shadows: const [
                                                          Shadow(
                                                            blurRadius: 0,
                                                            color: Color(
                                                              0xFF3D35CC,
                                                            ),
                                                            offset: Offset(
                                                              2,
                                                              2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                ),
                                                Text(
                                                  'Başarı',
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 13 * scale,
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.85,
                                                        ),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 28 * scale),
                                    // Stats row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _StatItem(
                                          icon: Icons.task_alt_rounded,
                                          label: 'Doğru',
                                          value: widget.correctCount.toString(),
                                          color: Colors.green,
                                        ),
                                        _StatItem(
                                          icon: Icons.close_rounded,
                                          label: 'Yanlış',
                                          value: widget.wrongCount.toString(),
                                          color: Colors.red,
                                        ),
                                        _StatItem(
                                          icon: Icons.extension_rounded,
                                          label: 'Toplam',
                                          value: widget.totalQuestions
                                              .toString(),
                                          color: const Color(0xFF4FC3F7),
                                        ),
                                      ],
                                    ),
                                    // Rewards
                                    if (_progressSaved &&
                                        _earnedScore != null) ...[
                                      SizedBox(height: 20 * scale),
                                      Container(
                                        height: 1,
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      SizedBox(height: 20 * scale),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _RewardCard(
                                              icon: Icons.star_rounded,
                                              label: 'Kazanılan Puan',
                                              value: '+$_earnedScore',
                                              color: const Color(0xFFFFB300),
                                            ),
                                          ),
                                          SizedBox(width: 14 * scale),
                                          Expanded(
                                            child: _RewardCard(
                                              icon: Icons.auto_awesome_rounded,
                                              label: 'Yıldız',
                                              value: '${_earnedStars ?? 0}/3',
                                              color: const Color(0xFFFF8C00),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Kart banner
                                      if (_cardDrop != null) ...[
                                        SizedBox(height: 12 * scale),
                                        _CardEarnedBanner(drop: _cardDrop!),
                                      ],
                                      // Rozet banner
                                      if (_earnedBadges.isNotEmpty) ...[
                                        SizedBox(height: 12 * scale),
                                        _BadgeEarnedBanner(
                                          badgeCount: _earnedBadges.length,
                                        ),
                                      ],
                                    ] else if (!_progressSaved) ...[
                                      SizedBox(height: 20 * scale),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Sonuç kaydediliyor...',
                                            style: GoogleFonts.nunito(
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: 24 * scale),
                              // Action buttons
                              if (_isEnglish) ...[
                                _Game3DButton(
                                  label: _isLoadingExplanation
                                      ? 'Yükleniyor...'
                                      : 'Konuyu Öğren',
                                  icon: Icons.menu_book_rounded,
                                  gradientColors: const [
                                    Color(0xFF26A69A),
                                    Color(0xFF00BFA5),
                                  ],
                                  shadowColor: const Color(0xFF00695C),
                                  onTap: _isLoadingExplanation
                                      ? () {}
                                      : _requestExplanation,
                                ),
                                SizedBox(height: 12 * scale),
                              ],
                              if (_isPassed) ...[
                                _Game3DButton(
                                  label: ref
                                      .watch(authProvider)
                                      .maybeWhen(
                                        authenticated: (user) => user.isPremium
                                            ? 'Seviye Sertifikasını Paylaş'
                                            : 'Başarı Sertifikasını Paylaş',
                                        orElse: () =>
                                            'Başarı Sertifikasını Paylaş',
                                      ),
                                  icon: Icons.workspace_premium_rounded,
                                  gradientColors: const [
                                    Color(0xFFFFB300),
                                    Color(0xFFFF8C00),
                                  ],
                                  shadowColor: const Color(0xFFB85C00),
                                  onTap: _shareCertificate,
                                ),
                                SizedBox(height: 12 * scale),
                                _Game3DButton(
                                  label: 'Sıralamayı Gör',
                                  icon: Icons.leaderboard_rounded,
                                  gradientColors: const [
                                    Color(0xFF9B59B6),
                                    Color(0xFF7B61FF),
                                  ],
                                  shadowColor: const Color(0xFF4A2072),
                                  onTap: () => context.push('/leaderboard'),
                                ),
                                SizedBox(height: 12 * scale),
                              ],
                              _Game3DButton(
                                label: 'Ana Sayfaya Dön',
                                icon: Icons.home_rounded,
                                gradientColors: const [
                                  Color(0xFF3498DB),
                                  Color(0xFF4FC3F7),
                                ],
                                shadowColor: const Color(0xFF1A5A8A),
                                onTap: () {
                                  debugPrint('🔙 Going to dashboard');
                                  context.go('/dashboard');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Confetti
              if (_confettiController != null)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController!,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).shortestSide >= 600 ? 1.2 : 1.0;
    return Column(
      children: [
        Icon(icon, size: 32 * scale, color: color),
        SizedBox(height: 8 * scale),
        Text(
          value,
          style: GoogleFonts.luckiestGuy(
            fontSize: 28 * scale,
            color: Colors.white,
            shadows: const [
              Shadow(
                blurRadius: 0,
                color: Color(0xFF3D35CC),
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13 * scale,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _RewardCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).shortestSide >= 600 ? 1.2 : 1.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 16 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28 * scale, color: color),
          SizedBox(height: 6 * scale),
          Text(
            value,
            style: GoogleFonts.luckiestGuy(
              fontSize: 22 * scale,
              color: Colors.white,
              shadows: const [
                Shadow(
                  blurRadius: 0,
                  color: Color(0xFF3D35CC),
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              fontSize: 12 * scale,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CertificateDialog extends StatefulWidget {
  final CertificateData certificate;

  const _CertificateDialog({required this.certificate});

  @override
  State<_CertificateDialog> createState() => _CertificateDialogState();
}

class _CertificateDialogState extends State<_CertificateDialog> {
  final GlobalKey _certificateKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _share(BuildContext buttonContext) async {
    if (_isSharing) return;
    final buttonBox = buttonContext.findRenderObject() as RenderBox?;
    final origin = buttonBox == null
        ? null
        : buttonBox.localToGlobal(Offset.zero) & buttonBox.size;
    setState(() => _isSharing = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _certificateKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Sertifika hazırlanamadı.');

      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('Sertifika görseli oluşturulamadı.');

      final safeTopic = widget.certificate.topicName.replaceAll(
        RegExp(r'[^a-zA-Z0-9ğüşöçıİĞÜŞÖÇ]+'),
        '_',
      );
      final file = File(
        '${Directory.systemTemp.path}/minibilge_sertifika_$safeTopic.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text:
            '${widget.certificate.studentName}, ${widget.certificate.subjectName} • '
            '${widget.certificate.topicName} quizini '
            '${widget.certificate.correctCount}/${widget.certificate.totalQuestions} '
            'sonuçla tamamladı.',
        subject: 'MiniBilge Başarı Sertifikası',
        sharePositionOrigin: origin,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sertifika paylaşılamadı. Lütfen tekrar dene.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.contain,
                child: RepaintBoundary(
                  key: _certificateKey,
                  child: AchievementCertificate(data: widget.certificate),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSharing ? null : () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (buttonContext) => FilledButton.icon(
                      onPressed: _isSharing
                          ? null
                          : () => _share(buttonContext),
                      icon: _isSharing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share_rounded),
                      label: Text(_isSharing ? 'Hazırlanıyor...' : 'Paylaş'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Game3DButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _Game3DButton({
    required this.label,
    this.icon,
    required this.gradientColors,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).shortestSide >= 600 ? 1.2 : 1.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 62 * scale,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(20 * scale),
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 5 * scale),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(20 * scale),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 22 * scale),
                  SizedBox(width: 8 * scale),
                ],
                Text(
                  label,
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 18 * scale,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 0,
                        color: shadowColor,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardEarnedBanner extends StatelessWidget {
  final CardDropResult drop;
  const _CardEarnedBanner({required this.drop});

  Color get _rarityColor {
    switch (drop.rarity.toLowerCase()) {
      case 'legendary':
        return const Color(0xFFFFB300);
      case 'epic':
        return const Color(0xFF9B59B6);
      case 'rare':
        return const Color(0xFF3498DB);
      default:
        return const Color(0xFF27AE60);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor;
    final scale = MediaQuery.sizeOf(context).shortestSide >= 600 ? 1.2 : 1.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12 * scale),
            child: Image.asset(
              drop.imageAsset,
              width: 58 * scale,
              height: 58 * scale,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 58 * scale,
                height: 58 * scale,
                color: Colors.white.withValues(alpha: 0.16),
                alignment: Alignment.center,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: color,
                  size: 28 * scale,
                ),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeni Kart Kazandın!',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 14 * scale,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        blurRadius: 0,
                        color: Color(0xFF3D35CC),
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  drop.cardName,
                  style: GoogleFonts.nunito(
                    fontSize: 12 * scale,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8 * scale,
              vertical: 3 * scale,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Text(
              drop.rarity.toUpperCase(),
              style: GoogleFonts.nunito(
                fontSize: 10 * scale,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeEarnedBanner extends StatelessWidget {
  final int badgeCount;
  const _BadgeEarnedBanner({required this.badgeCount});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).shortestSide >= 600 ? 1.2 : 1.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF7B61FF).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(
          color: const Color(0xFF7B61FF).withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: Colors.amberAccent,
            size: 28 * scale,
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              badgeCount == 1
                  ? 'Yeni Rozet Kazandın!'
                  : '$badgeCount Yeni Rozet Kazandın!',
              style: GoogleFonts.luckiestGuy(
                fontSize: 14 * scale,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 0,
                    color: Color(0xFF3D35CC),
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.auto_awesome_rounded,
            color: Colors.amberAccent,
            size: 20 * scale,
          ),
        ],
      ),
    );
  }
}

// ─── Konu Anlatımı Bottom Sheet ───────────────────────────────────────────────

class _TopicExplanationSheet extends StatefulWidget {
  final String subjectName;
  final dynamic explanation; // TopicExplanation

  const _TopicExplanationSheet({
    required this.subjectName,
    required this.explanation,
  });

  @override
  State<_TopicExplanationSheet> createState() => _TopicExplanationSheetState();
}

class _TopicExplanationSheetState extends State<_TopicExplanationSheet> {
  static const _bg = Color(0xFF0D1B2A);
  static const _accent = Color(0xFF26A69A);

  bool _showTurkish = false;

  @override
  Widget build(BuildContext context) {
    final expl = widget.explanation;
    final rule = _showTurkish && (expl.ruleTr as String).isNotEmpty
        ? expl.ruleTr as String
        : expl.rule as String;
    final mistakes = _showTurkish && (expl.commonMistakesTr as List).isNotEmpty
        ? expl.commonMistakesTr as List<String>
        : expl.commonMistakes as List<String>;
    final tip = _showTurkish && (expl.tipTr as String).isNotEmpty
        ? expl.tipTr as String
        : expl.tip as String;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Başlık + toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.subjectName,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  // EN/TR pill toggle
                  GestureDetector(
                    onTap: () => setState(() => _showTurkish = !_showTurkish),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _showTurkish
                            ? _accent.withValues(alpha: 0.2)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _showTurkish ? _accent : Colors.white24,
                        ),
                      ),
                      child: Text(
                        _showTurkish ? '🇹🇷 TR' : '🇬🇧 EN',
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            // İçerik
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Kural
                  _Section(
                    icon: Icons.lightbulb_outline_rounded,
                    title: _showTurkish ? 'Kural' : 'Rule',
                    color: _accent,
                    child: Text(
                      rule,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Örnekler (always English)
                  _Section(
                    icon: Icons.edit_note_rounded,
                    title: _showTurkish ? 'Örnekler' : 'Examples',
                    color: const Color(0xFF7C4DFF),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (expl.examples as List<String>)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '→ ',
                                    style: TextStyle(
                                      color: Color(0xFF7C4DFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      e,
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sık yapılan hatalar
                  _Section(
                    icon: Icons.warning_amber_rounded,
                    title: _showTurkish
                        ? 'Sık Yapılan Hatalar'
                        : 'Common Mistakes',
                    color: Colors.orangeAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: mistakes
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      e,
                                      style: GoogleFonts.nunito(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // İpucu banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF26A69A), Color(0xFF00BFA5)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.tips_and_updates_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.nunito(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

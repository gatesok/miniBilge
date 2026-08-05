import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../education/models/subject.dart';
import '../../education/models/topic.dart';
import '../../education/providers/subject_provider.dart';
import '../../education/providers/topic_provider.dart';
import '../../education/providers/level_provider.dart';
import '../providers/challenge_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';
import '../../premium/providers/premium_provider.dart';
import '../../usage/services/daily_usage_service.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/widgets/competition_pickers.dart';

/// `AdultCompetitionType.EnglishVocabWordGame` (backend) — Kelime Oyunu
/// meydan okuması; hem çocuk hem yetişkin profillerinde kullanılabilir.
const int kEnglishVocabWordGameType = 7;

/// Arkadaşa meydan okuma göndermek için diyalog.
/// Akış: Ders → Seviye → Konu → (ünite otomatik seçilir) → Gönder
Future<void> showChallengeSendDialog(
  BuildContext context, {
  required String challengeeId,
  required String challengeeName,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => _ChallengeSendSheet(
        challengeeId: challengeeId,
        challengeeName: challengeeName,
        scrollController: scrollController,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChallengeSendSheet extends ConsumerStatefulWidget {
  final String challengeeId;
  final String challengeeName;
  final ScrollController scrollController;

  const _ChallengeSendSheet({
    required this.challengeeId,
    required this.challengeeName,
    required this.scrollController,
  });

  @override
  ConsumerState<_ChallengeSendSheet> createState() =>
      _ChallengeSendSheetState();
}

class _ChallengeSendSheetState extends ConsumerState<_ChallengeSendSheet> {
  Subject? _subject;
  int? _gradeFilter;
  Topic? _topic;
  String? _levelId;
  bool _levelLoading = false;
  bool _sending = false;
  String? _errorMessage; // hata mesajı inline gösterilir
  int? _competitionType;
  String? _competitionTopicKey;
  String? _competitionDifficulty;
  /// Çocuk profillerinde "Ders Bazlı" yerine "Kelime Oyunu" modu seçildi mi.
  bool _wordGameMode = false;

  // Hangi adım doldu
  int get _step {
    if (_subject == null) return 0;
    if (_gradeFilter == null) return 1;
    if (_topic == null) return 2;
    return 3;
  }

  bool _isEnglish(Subject? s) {
    final n = s?.name.toLowerCase() ?? '';
    return n.contains('ngilizce') || n.contains('english');
  }

  String _gradeLabel(int g) {
    if (_isEnglish(_subject)) {
      const map = {1: 'A1', 2: 'A2', 3: 'B1', 4: 'B2', 5: 'C1', 6: 'C2'};
      return map[g] ?? 'Seviye $g';
    }
    return '$g. Sınıf';
  }

  /// Bir topic için geçerli seviye (gradeLevel veya englishLevel).
  int _topicLevel(Topic t) =>
      _isEnglish(_subject) ? (t.englishLevel ?? t.gradeLevel) : t.gradeLevel;

  /// Konu seçilince ilk üniteyi otomatik al.
  Future<void> _selectTopic(Topic t) async {
    setState(() {
      _topic = t;
      _levelId = null;
      _levelLoading = true;
    });
    try {
      final levels = await ref.read(levelListProvider(t.id).future);
      final active = levels.where((l) => l.isActive).toList();
      if (mounted && active.isNotEmpty) {
        setState(() => _levelId = active.first.id);
      }
    } catch (_) {
      // Seviye bulunamazsa butonu göstermiyoruz
    } finally {
      if (mounted) setState(() => _levelLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(selectedChildProvider)?.isAdultProfile == true) {
      return _buildAdultSheet();
    }
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F0FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Drag handle ──────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Başlık ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A5ACD), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.challengeeName}'a Meydan Oku",
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF2D2060),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Ders ve seviye seç, sonra konu belirle.',
                        style: GoogleFonts.nunito(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Mod seçici: Ders Bazlı vs Kelime Oyunu ───────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: CompetitionModeCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Ders Bazlı',
                    selected: !_wordGameMode,
                    onTap: () => setState(() {
                      _wordGameMode = false;
                      _competitionDifficulty = null;
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CompetitionModeCard(
                    icon: Icons.sports_esports_rounded,
                    label: 'Kelime Oyunu',
                    selected: _wordGameMode,
                    onTap: () => setState(() {
                      _wordGameMode = true;
                      _subject = null;
                      _gradeFilter = null;
                      _topic = null;
                      _levelId = null;
                    }),
                  ),
                ),
              ],
            ),
          ),

          if (!_wordGameMode) ...[
            // ── Step bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _StepBar(step: _step),
            ),

            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade200, height: 1),
          ] else
            const SizedBox(height: 14),

          // ── İçerik ──────────────────────────────────────────
          Expanded(
            child: _wordGameMode
                ? SingleChildScrollView(
                    controller: widget.scrollController,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      20 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        competitionSectionLabel(1, 'İngilizce seviyesi seç'),
                        const SizedBox(height: 10),
                        Text(
                          'Arkadaşınla aynı 10 kelimeden oluşan bir kelime '
                          'yarışması oynarsınız.',
                          style: GoogleFonts.nunito(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
                              .map(
                                (value) => CompetitionPill(
                                  label: value,
                                  selected: _competitionDifficulty == value,
                                  onTap: () => setState(
                                    () => _competitionDifficulty = value,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
              controller: widget.scrollController,
              padding: EdgeInsets.fromLTRB(
                0,
                8,
                0,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Adım 1: Ders ───────────────────────────
                  _StepSection(
                    number: 1,
                    title: 'Ders seç',
                    subtitle: _subject?.name,
                    isDone: _subject != null,
                    child: ref
                        .watch(subjectListProvider)
                        .when(
                          data: (subjects) => _SubjectToggle(
                            subjects: subjects
                                .where((s) => s.isActive)
                                .toList(),
                            selected: _subject,
                            onTap: (s) => setState(() {
                              _subject = s;
                              _gradeFilter = null;
                              _topic = null;
                              _levelId = null;
                            }),
                          ),
                          loading: () => const _Loading(),
                          error: (e, _) => _ErrorText('$e'),
                        ),
                  ),

                  // ── Adım 2: Seviye ─────────────────────────
                  if (_subject != null) ...[
                    Divider(color: Colors.grey.shade200, height: 1),
                    _StepSection(
                      number: 2,
                      title: _isEnglish(_subject)
                          ? 'Dil seviyesi seç'
                          : 'Sınıf seç',
                      subtitle: _gradeFilter != null
                          ? _gradeLabel(_gradeFilter!)
                          : null,
                      isDone: _gradeFilter != null,
                      child: ref
                          .watch(topicListProvider(_subject!.id))
                          .when(
                            data: (topics) {
                              // Benzersiz grade level'ları çıkar
                              final grades =
                                  topics
                                      .where((t) => t.isActive)
                                      .map(_topicLevel)
                                      .toSet()
                                      .toList()
                                    ..sort();
                              if (grades.isEmpty) {
                                return _ErrorText(
                                  'Bu derse ait içerik bulunamadı.',
                                );
                              }
                              return Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: grades
                                    .map(
                                      (g) => CompetitionPill(
                                        label: _gradeLabel(g),
                                        selected: _gradeFilter == g,
                                        onTap: () => setState(() {
                                          _gradeFilter = g;
                                          _topic = null;
                                          _levelId = null;
                                        }),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                            loading: () => const _Loading(),
                            error: (e, _) => _ErrorText('$e'),
                          ),
                    ),
                  ],

                  // ── Adım 3: Konu ───────────────────────────
                  if (_gradeFilter != null) ...[
                    Divider(color: Colors.grey.shade200, height: 1),
                    _StepSection(
                      number: 3,
                      title: 'Konu seç',
                      subtitle: _topic?.name,
                      isDone: _topic != null,
                      child: ref
                          .watch(topicListProvider(_subject!.id))
                          .when(
                            data: (topics) {
                              final filtered = topics
                                  .where(
                                    (t) =>
                                        t.isActive &&
                                        _topicLevel(t) == _gradeFilter,
                                  )
                                  .toList();
                              if (filtered.isEmpty) {
                                return _ErrorText(
                                  'Bu seviyede konu bulunamadı.',
                                );
                              }
                              return _TopicList(
                                topics: filtered,
                                selected: _topic,
                                onTap: _selectTopic,
                                levelLoading: _levelLoading,
                              );
                            },
                            loading: () => const _Loading(),
                            error: (e, _) => _ErrorText('$e'),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Gönder butonu ────────────────────────────────────
          if (_wordGameMode ? _competitionDifficulty != null : _topic != null) ...[
            // Hata varsa inline göster
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.nunito(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            _SendButton(
              sending: _sending,
              ready: _wordGameMode ? _competitionDifficulty != null : _levelId != null,
              loading: _wordGameMode ? false : _levelLoading,
              onTap: _send,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdultSheet() {
    const modes = <(int, IconData, String, String)>[
      (0, Icons.public_rounded, 'Genel Kültür Düellosu', 'genel_kultur'),
      (2, Icons.language_rounded, 'İngilizce Quiz', 'ingilizce'),
      (
        kEnglishVocabWordGameType,
        Icons.sports_esports_rounded,
        'Kelime Oyunu',
        'english_vocab',
      ),
    ];
    final isEnglish = _competitionType == 2;
    final isWordGame = _competitionType == kEnglishVocabWordGameType;
    final subjects =
        ref.watch(subjectListProvider).valueOrNull ?? const <Subject>[];
    Subject? englishSubject;
    for (final subject in subjects) {
      if (_isEnglish(subject)) {
        englishSubject = subject;
        break;
      }
    }
    final englishTopicState = isEnglish && englishSubject != null
        ? ref.watch(topicListProvider(englishSubject.id))
        : null;
    final selectedEnglishLevel = const {
      'A1': 1,
      'A2': 2,
      'B1': 3,
      'B2': 4,
      'C1': 5,
      'C2': 6,
    }[_competitionDifficulty];
    final englishTopics =
        englishTopicState?.valueOrNull
            ?.where(
              (topic) =>
                  topic.isActive &&
                  (topic.englishLevel ?? topic.gradeLevel) ==
                      selectedEnglishLevel,
            )
            .toList() ??
        const <Topic>[];
    const generalTopics = <String, String>{
      'Genel Kültür': 'genel_kultur',
      'Spor': 'spor',
      'Müzik': 'muzik',
      'Sinema & Dizi': 'sinema',
      'Teknoloji': 'teknoloji',
      'Sanat': 'sanat',
    };
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F0FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.challengeeName}'a Meydan Oku",
                  style: GoogleFonts.nunito(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D2060),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'İkinizin de aynı soruları oynayacağı yarışma türünü seç.',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                _buildRemainingBadge(),
                _buildRankedBadge(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  competitionSectionLabel(1, 'Yarışma türü'),
                  const SizedBox(height: 10),
                  ...modes.indexed.map((entry) {
                    final index = entry.$1;
                    final mode = entry.$2;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == modes.length - 1 ? 0 : 10,
                      ),
                      child: CompetitionModeCard(
                        icon: mode.$2,
                        label: mode.$3,
                        selected: _competitionType == mode.$1,
                        onTap: () => setState(() {
                          _competitionType = mode.$1;
                          _competitionTopicKey = null;
                          _competitionDifficulty = null;
                        }),
                      ),
                    );
                  }),
                  if (_competitionType != null) ...[
                    const SizedBox(height: 18),
                    competitionSectionLabel(
                      2,
                      isEnglish || isWordGame
                          ? 'İngilizce seviyesi'
                          : 'Zorluk seviyesi',
                    ),
                    const SizedBox(height: 10),
                    if (isEnglish || isWordGame)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
                            .map(
                              (value) => CompetitionPill(
                                label: value,
                                selected: _competitionDifficulty == value,
                                onTap: () => setState(() {
                                  _competitionDifficulty = value;
                                  _competitionTopicKey = null;
                                }),
                              ),
                            )
                            .toList(),
                      )
                    else
                      DifficultyPills(
                        selected: _competitionDifficulty,
                        onSelect: (value) => setState(() {
                          _competitionDifficulty = value;
                          _competitionTopicKey = null;
                        }),
                      ),
                  ],
                  if (_competitionDifficulty != null && !isWordGame) ...[
                    const SizedBox(height: 18),
                    competitionSectionLabel(3, 'Konu seç'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (isEnglish
                                  ? englishTopics.map((topic) => topic.name)
                                  : generalTopics.keys)
                              .map((label) {
                                final key = isEnglish
                                    ? 'ingilizce:$label'
                                    : generalTopics[label]!;
                                return CompetitionPill(
                                  label: label,
                                  selected: _competitionTopicKey == key,
                                  onTap: () => setState(
                                    () => _competitionTopicKey = key,
                                  ),
                                );
                              })
                              .toList(),
                    ),
                  ],
                  if (isEnglish &&
                      _competitionDifficulty != null &&
                      englishTopicState?.isLoading == true)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (isEnglish &&
                      _competitionDifficulty != null &&
                      englishTopicState?.hasValue == true &&
                      englishTopics.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Bu seviyede aktif İngilizce konusu bulunamadı.',
                        style: GoogleFonts.nunito(color: Colors.red.shade700),
                      ),
                    ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _SendButton(
            sending: _sending,
            ready:
                _competitionType != null &&
                _competitionDifficulty != null &&
                (isWordGame || _competitionTopicKey != null),
            loading: false,
            onTap: _send,
            notReadyLabel: 'Seçimleri tamamla',
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final levelId = _wordGameMode ? null : _levelId;
    final isAdult = ref.read(selectedChildProvider)?.isAdultProfile == true;
    if (!isAdult && !_wordGameMode && levelId == null) {
      setState(
        () => _errorMessage = 'Ünite henüz yüklenmedi, lütfen bekleyin.',
      );
      return;
    }
    if (!isAdult && _wordGameMode && _competitionDifficulty == null) {
      setState(
        () => _errorMessage = 'Bir İngilizce seviyesi seçmelisin.',
      );
      return;
    }
    setState(() {
      _sending = true;
      _errorMessage = null;
    });

    if (isAdult) {
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.challengeCreateStarted,
          parameters: {
            'feature_key': adultChallengeUsageKey,
            'competition_type': _competitionType,
          },
        ),
      );
    }

    // Root scaffold messenger'ı ÖNCEDEN al (pop sonrası context geçersiz olur)
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await ref
          .read(challengeNotifierProvider.notifier)
          .sendChallenge(
            challengeeId: widget.challengeeId,
            levelId: levelId,
            competitionType: isAdult
                ? _competitionType
                : (_wordGameMode ? kEnglishVocabWordGameType : null),
            competitionTopicKey: isAdult ? _competitionTopicKey : null,
            competitionDifficulty: isAdult
                ? (_competitionDifficulty ?? 'Orta')
                : (_wordGameMode ? (_competitionDifficulty ?? 'A1') : 'Orta'),
          );
      if (isAdult) {
        final ranked = ref
            .read(adultRankedStatusProvider(widget.challengeeId))
            .valueOrNull
            ?.nextGameRanked;
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.challengeCreated,
            parameters: {
              'feature_key': adultChallengeUsageKey,
              'competition_type': _competitionType,
            },
          ),
        );
        if (ranked != null) {
          unawaited(
            AnalyticsService.logEvent(
              AnalyticsEvents.challengeRankedEligible,
              parameters: {'ranked': ranked},
            ),
          );
        }
        ref.invalidate(adultChallengeRemainingProvider);
      }
      if (mounted) Navigator.of(context).pop();
      messenger?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.challengeeName}\'a meydan okuma gönderildi!',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Yetişkin günlük kota doldu (429): jenerik hata yerine bağlamsal limit
      // ekranını göster (reklamla ek hak / Premium).
      final limitReached =
          e is DioException && e.response?.statusCode == 429;
      if (mounted && isAdult && limitReached) {
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.attemptLimitReached,
            parameters: {'feature': adultChallengeUsageKey},
          ),
        );
        setState(() => _sending = false);
        await _showAdultLimitSheet();
        return;
      }
      // Hatayi inline göster — SnackBar context sorununu atla
      if (mounted) {
        setState(() {
          _sending = false;
          _errorMessage = _friendlyError(e);
        });
      }
    } finally {
      if (mounted && _sending) setState(() => _sending = false);
    }
  }

  /// Bu karşılaşmanın sıralama (turnuva) puanı üretip üretmeyeceğini gösterir.
  Widget _buildRankedBadge() {
    final status = ref
        .watch(adultRankedStatusProvider(widget.challengeeId))
        .valueOrNull;
    if (status == null) return const SizedBox.shrink();
    final ranked = status.nextGameRanked;
    final String label;
    if (ranked) {
      label = 'Bu karşılaşma sıralamana puan katacak';
    } else if (status.vsOpponentEligible == false) {
      label = 'Bu rakiple bugün oynadın — sıralamaya saymaz';
    } else {
      label = 'Günlük sıralama hakkın doldu — sıralamaya saymaz';
    }
    final color = ranked ? const Color(0xFF1E7A3D) : Colors.grey.shade600;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ranked ? Icons.emoji_events_rounded : Icons.leaderboard_outlined,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Yetişkin sheet başlığında kalan günlük hakkı gösterir (sunucu authoritative).
  Widget _buildRemainingBadge() {
    final remaining = ref.watch(adultChallengeRemainingProvider).valueOrNull;
    if (remaining == null || remaining < 0) return const SizedBox.shrink();
    final full = remaining == 0;
    final label = full
        ? 'Bugünlük meydan okuma hakkın doldu'
        : 'Bugün $remaining meydan okuma hakkın kaldı';
    final color = full ? const Color(0xFFB3261E) : const Color(0xFF2D2060);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            full ? Icons.hourglass_bottom_rounded : Icons.bolt_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Günlük kota dolduğunda bağlamsal Premium/ödüllü reklam ekranı.
  Future<void> _showAdultLimitSheet() async {
    final challengerId = ref.read(selectedChildProvider)?.id;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF4F0FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Consumer(
        builder: (ctx, sheetRef, _) {
          final isPremium = sheetRef.watch(premiumProvider).isPremium;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⏳', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 12),
                Text(
                  'Günlük meydan okuma hakkın doldu',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D2060),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPremium
                      ? 'Bugünkü yüksek kullanım hakkını kullandın. Hakların yarın yenilenir.'
                      : 'Her gün 3 meydan okuma başlatabilirsin. Reklam izleyerek +1 hak kazanabilir ya da Premium ile günde 20 hakka geçebilirsin.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                if (!isPremium) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A5ACD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        RewardedAdService.showRewardedAd(
                          placement: AdPlacements.adultChallengeExtraAttempt,
                          onRewarded: () async {
                            if (challengerId != null) {
                              try {
                                await sheetRef
                                    .read(dailyUsageServiceProvider)
                                    .grantRewardedBonus(
                                      childId: challengerId,
                                      featureKey: adultChallengeUsageKey,
                                    );
                              } on DioException {
                                // Bonus verilemezse sessizce yut.
                              }
                            }
                            sheetRef.invalidate(adultChallengeRemainingProvider);
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                        );
                      },
                      child: Text(
                        '📺 Reklam İzle (+1 Hak)',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        unawaited(
                          AnalyticsService.logEvent(
                            AnalyticsEvents.premiumIntent,
                            parameters: {
                              'trigger': 'adult_challenge_limit',
                              'feature_key': adultChallengeUsageKey,
                            },
                          ),
                        );
                        Navigator.of(sheetContext).pop();
                        context.push('/premium');
                      },
                      child: Text(
                        '✨ Premium\'a Geç',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A5ACD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        'Tamam',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _friendlyError(Object e) {
    // Dio response body'sindeki backend mesajını önce dene
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }
    // Fallback: genel keyword kontrolü
    final msg = e.toString().toLowerCase();
    if (msg.contains('arkadaş') || msg.contains('friendship')) {
      return 'Bu kişiyle arkadaş değilsiniz.';
    }
    if (msg.contains('aktif') || msg.contains('active')) {
      return 'Bu kişiyle zaten aktif bir meydan okuman var. Meydan Okumalar ekranından görebilirsin.';
    }
    if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'Oturum süresi dolmuş, uygulamayı yeniden başlatın.';
    }
    if (msg.contains('connection') || msg.contains('bağlan')) {
      return 'Sunucuya bağlanılamadı, internet bağlantınızı kontrol edin.';
    }
    return 'Beklenmeyen hata (${e.runtimeType})';
  }
}

// ── StepBar ──────────────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int step;
  const _StepBar({required this.step});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _StepDot(n: 1, active: step >= 1, label: 'Ders'),
      _StepLine(done: step >= 2),
      _StepDot(n: 2, active: step >= 2, label: 'Seviye'),
      _StepLine(done: step >= 3),
      _StepDot(n: 3, active: step >= 3, label: 'Konu'),
    ],
  );
}

class _StepDot extends StatelessWidget {
  final int n;
  final bool active;
  final String label;
  const _StepDot({required this.n, required this.active, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0xFF6A5ACD) : Colors.grey.shade200,
        ),
        child: Center(
          child: active
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
              : Text(
                  '$n',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade400,
                  ),
                ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF6A5ACD) : Colors.grey.shade400,
        ),
      ),
    ],
  );
}

class _StepLine extends StatelessWidget {
  final bool done;
  const _StepLine({required this.done});

  @override
  Widget build(BuildContext context) => Expanded(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 3,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: done ? const Color(0xFF6A5ACD) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

// ── StepSection ──────────────────────────────────────────────────────────────

class _StepSection extends StatelessWidget {
  final int number;
  final String title;
  final String? subtitle; // seçilen değeri göster
  final bool isDone;
  final Widget child;

  const _StepSection({
    required this.number,
    required this.title,
    this.subtitle,
    required this.isDone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$number. $title',
              style: GoogleFonts.nunito(
                color: const Color(0xFF2D2060),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (isDone && subtitle != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A5ACD).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF6A5ACD),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        subtitle!,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF6A5ACD),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

// ── SubjectToggle ─────────────────────────────────────────────────────────────

class _SubjectToggle extends StatelessWidget {
  final List<Subject> subjects;
  final Subject? selected;
  final ValueChanged<Subject> onTap;

  const _SubjectToggle({
    required this.subjects,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 8,
    children: subjects
        .map(
          (s) => CompetitionPill(
            label: s.name,
            selected: selected == s,
            onTap: () => onTap(s),
          ),
        )
        .toList(),
  );
}

// ── TopicList ─────────────────────────────────────────────────────────────────

class _TopicList extends StatelessWidget {
  final List<Topic> topics;
  final Topic? selected;
  final Future<void> Function(Topic) onTap;
  final bool levelLoading;

  const _TopicList({
    required this.topics,
    required this.selected,
    required this.onTap,
    required this.levelLoading,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: topics
        .map(
          (t) => GestureDetector(
            onTap: () => onTap(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected == t
                    ? const Color(0xFF6A5ACD).withValues(alpha: 0.10)
                    : const Color(0xFFEDE7FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected == t
                      ? const Color(0xFF6A5ACD)
                      : const Color(0xFFDED4F6),
                  width: selected == t ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.name,
                      style: GoogleFonts.nunito(
                        color: selected == t
                            ? const Color(0xFF6A5ACD)
                            : const Color(0xFF4A3B8A),
                        fontWeight: selected == t
                            ? FontWeight.w800
                            : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (selected == t && levelLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6A5ACD),
                      ),
                    )
                  else if (selected == t)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF6A5ACD),
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        )
        .toList(),
  );
}

// ── SendButton ────────────────────────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final bool sending;
  final bool ready;
  final bool loading;
  final VoidCallback onTap;
  final String notReadyLabel;

  const _SendButton({
    required this.sending,
    required this.ready,
    required this.loading,
    required this.onTap,
    this.notReadyLabel = 'Ünite yükleniyor...',
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ready
                ? const Color(0xFF6A5ACD)
                : Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: ready ? 4 : 0,
          ),
          onPressed: (sending || !ready || loading) ? null : onTap,
          child: (sending || loading)
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (ready) ...[
                      const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      ready ? 'Meydan Okumayı Gönder' : notReadyLabel,
                      style: GoogleFonts.nunito(
                        color: ready ? Colors.white : Colors.grey.shade500,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}

// ── Yardımcılar ───────────────────────────────────────────────────────────────

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: CircularProgressIndicator(
        color: Color(0xFF6A5ACD),
        strokeWidth: 2,
      ),
    ),
  );
}

class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: GoogleFonts.nunito(color: Colors.red, fontSize: 13),
    ),
  );
}

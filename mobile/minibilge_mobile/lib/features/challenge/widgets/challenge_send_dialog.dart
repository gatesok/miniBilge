import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../education/models/subject.dart';
import '../../education/models/topic.dart';
import '../../education/providers/subject_provider.dart';
import '../../education/providers/topic_provider.dart';
import '../../education/providers/level_provider.dart';
import '../providers/challenge_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';

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
                  child: const Center(
                    child: Text('⚔️', style: TextStyle(fontSize: 22)),
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

          // ── Step bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: _StepBar(step: _step),
          ),

          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200, height: 1),

          // ── İçerik ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
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
                                      (g) => _GradeChip(
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
          if (_topic != null) ...[
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
              ready: _levelId != null,
              loading: _levelLoading,
              onTap: _send,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdultSheet() {
    const modes = <(int, String, String, String)>[
      (0, '🌍', 'Genel Kültür Düellosu', 'genel_kultur'),
      (2, '🇬🇧', 'İngilizce Quiz', 'ingilizce'),
    ];
    final isEnglish = _competitionType == 2;
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
                  ...modes.indexed.map((entry) {
                    final index = entry.$1;
                    final mode = entry.$2;
                    final selected = _competitionType == mode.$1;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == modes.length - 1 ? 0 : 9,
                      ),
                      child: InkWell(
                        onTap: () => setState(() {
                          _competitionType = mode.$1;
                          _competitionTopicKey = null;
                          _competitionDifficulty = null;
                        }),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFE7D9FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF7B61FF)
                                  : Colors.grey.shade200,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                mode.$2,
                                style: const TextStyle(fontSize: 25),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  mode.$3,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2D2060),
                                  ),
                                ),
                              ),
                              Icon(
                                selected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: selected
                                    ? const Color(0xFF7B61FF)
                                    : Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_competitionType != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      isEnglish
                          ? '2. İngilizce seviyesi'
                          : '2. Zorluk seviyesi',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D2060),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children:
                          (isEnglish
                                  ? ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
                                  : ['Kolay', 'Orta', 'Zor'])
                              .map(
                                (value) => ChoiceChip(
                                  label: Text(value),
                                  selected: _competitionDifficulty == value,
                                  onSelected: (_) => setState(() {
                                    _competitionDifficulty = value;
                                    _competitionTopicKey = null;
                                  }),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                  if (_competitionDifficulty != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '3. Konu seç',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D2060),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children:
                          (isEnglish
                                  ? englishTopics.map((topic) => topic.name)
                                  : generalTopics.keys)
                              .map((label) {
                                final key = isEnglish
                                    ? 'ingilizce:$label'
                                    : generalTopics[label]!;
                                return ChoiceChip(
                                  label: Text(label),
                                  selected: _competitionTopicKey == key,
                                  onSelected: (_) => setState(
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
                _competitionTopicKey != null,
            loading: false,
            onTap: _send,
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final levelId = _levelId;
    final isAdult = ref.read(selectedChildProvider)?.isAdultProfile == true;
    if (!isAdult && levelId == null) {
      setState(
        () => _errorMessage = 'Ünite henüz yüklenmedi, lütfen bekleyin.',
      );
      return;
    }
    setState(() {
      _sending = true;
      _errorMessage = null;
    });

    // Root scaffold messenger'ı ÖNCEDEN al (pop sonrası context geçersiz olur)
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await ref
          .read(challengeNotifierProvider.notifier)
          .sendChallenge(
            challengeeId: widget.challengeeId,
            levelId: levelId,
            competitionType: isAdult ? _competitionType : null,
            competitionTopicKey: isAdult ? _competitionTopicKey : null,
            competitionDifficulty: isAdult
                ? (_competitionDifficulty ?? 'Orta')
                : 'Orta',
          );
      if (mounted) Navigator.of(context).pop();
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${widget.challengeeName}\'a meydan okuma gönderildi!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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
                  color: const Color(0xFF6A5ACD).withOpacity(0.12),
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
          (s) => GestureDetector(
            onTap: () => onTap(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: selected == s
                    ? const Color(0xFF6A5ACD)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected == s
                      ? const Color(0xFF6A5ACD)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                s.name,
                style: GoogleFonts.nunito(
                  color: selected == s ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
}

// ── GradeChip ─────────────────────────────────────────────────────────────────

class _GradeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GradeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF6A5ACD) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? const Color(0xFF6A5ACD) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: selected ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
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
                    ? const Color(0xFF6A5ACD).withOpacity(0.08)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected == t
                      ? const Color(0xFF6A5ACD)
                      : Colors.grey.shade200,
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
                            : Colors.grey.shade800,
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

  const _SendButton({
    required this.sending,
    required this.ready,
    required this.loading,
    required this.onTap,
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
              : Text(
                  ready ? '⚔️  Meydan Okumayı Gönder' : 'Ünite yükleniyor...',
                  style: GoogleFonts.nunito(
                    color: ready ? Colors.white : Colors.grey.shade500,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
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

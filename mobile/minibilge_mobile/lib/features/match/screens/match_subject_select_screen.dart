import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../education/providers/subject_provider.dart';
import '../../education/providers/topic_provider.dart';
import '../../education/providers/level_provider.dart';
import '../../education/models/subject.dart';
import '../../education/models/topic.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';
import '../../../core/widgets/competition_pickers.dart';
import '../widgets/live_match_quota_banner.dart';
import '../widgets/live_match_ranked_badge.dart';

class MatchSubjectSelectScreen extends ConsumerStatefulWidget {
  const MatchSubjectSelectScreen({super.key});

  @override
  ConsumerState<MatchSubjectSelectScreen> createState() =>
      _MatchSubjectSelectScreenState();
}

class _MatchSubjectSelectScreenState
    extends ConsumerState<MatchSubjectSelectScreen> {
  int? _competitionType;
  String? _difficulty;
  String? _topicKey;
  Subject? _childSubject;
  int? _childLevel;
  Topic? _childTopic;
  String? _childLevelId;
  bool _childLevelLoading = false;

  bool _isEnglish(Subject? subject) =>
      subject?.name.toLowerCase().replaceAll('i̇', 'i') == 'ingilizce';

  int _topicLevel(Topic topic) => _isEnglish(_childSubject)
      ? (topic.englishLevel ?? topic.gradeLevel)
      : topic.gradeLevel;

  String _levelLabel(int value) {
    if (_isEnglish(_childSubject)) {
      return const {
            1: 'A1',
            2: 'A2',
            3: 'B1',
            4: 'B2',
            5: 'C1',
            6: 'C2',
          }[value] ??
          '$value';
    }
    return value == 0 ? 'Okul Öncesi' : '$value. Sınıf';
  }

  Future<void> _selectChildTopic(Topic topic) async {
    setState(() {
      _childTopic = topic;
      _childLevelId = null;
      _childLevelLoading = true;
    });
    try {
      final levels = await ref.read(levelListProvider(topic.id).future);
      final active = levels.where((level) => level.isActive).toList();
      if (mounted && active.isNotEmpty) {
        setState(() => _childLevelId = active.first.id);
      }
    } finally {
      if (mounted) setState(() => _childLevelLoading = false);
    }
  }

  (IconData, List<Color>, Color) _subjectConfig(String name) {
    switch (name.toLowerCase()) {
      case 'matematik':
        return (
          Icons.calculate_rounded,
          const [Color(0xFF29B6F6), Color(0xFF0277BD)],
          const Color(0xFF01579B),
        );
      case 'i̇ngilizce':
      case 'ingilizce':
        return (
          Icons.language_rounded,
          const [Color(0xFF26A69A), Color(0xFF00695C)],
          const Color(0xFF004D40),
        );
      default:
        return (
          Icons.menu_book_rounded,
          const [Color(0xFF7E57C2), Color(0xFF4527A0)],
          const Color(0xFF311B92),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(selectedChildProvider)?.isAdultProfile == true) {
      return _buildAdult(context, ref);
    }
    final subjectsAsync = ref.watch(subjectListProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Ders Seç',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 28,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(2, 2),
                            ),
                            Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(-1, -1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hangi derste rakip bulmak istiyorsun?',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 12),
              const LiveMatchQuotaBanner(),
              const SizedBox(height: 8),
              const LiveMatchRankedBadge(),
              const SizedBox(height: 32),
              // Subject buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: subjectsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (_, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Dersler yüklenemedi',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => ref.refresh(subjectListProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                    data: (subjects) {
                      final active = subjects.where((s) => s.isActive).toList();
                      final topicState = _childSubject == null
                          ? null
                          : ref.watch(topicListProvider(_childSubject!.id));
                      final topics = topicState?.valueOrNull ?? const <Topic>[];
                      final levels =
                          topics
                              .where((topic) => topic.isActive)
                              .map(_topicLevel)
                              .toSet()
                              .toList()
                            ..sort();
                      final filteredTopics = _childLevel == null
                          ? const <Topic>[]
                          : topics
                                .where(
                                  (topic) =>
                                      topic.isActive &&
                                      _topicLevel(topic) == _childLevel,
                                )
                                .toList();
                      return ListView(
                        children: [
                          Text('1. Ders seç', style: _adultTitleStyle()),
                          const SizedBox(height: 10),
                          ...active.map((subject) {
                            final config = _subjectConfig(subject.name);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _SubjectButton(
                                label: subject.name.toUpperCase(),
                                icon: config.$1,
                                gradientColors: config.$2,
                                shadowColor: config.$3,
                                selected: _childSubject?.id == subject.id,
                                onTap: () => setState(() {
                                  _childSubject = subject;
                                  _childLevel = null;
                                  _childTopic = null;
                                  _childLevelId = null;
                                }),
                              ),
                            );
                          }),
                          if (_childSubject != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _isEnglish(_childSubject)
                                  ? '2. İngilizce seviyesi'
                                  : '2. Sınıf seviyesi',
                              style: _adultTitleStyle(),
                            ),
                            const SizedBox(height: 8),
                            if (topicState?.isLoading == true)
                              const Center(child: CircularProgressIndicator())
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: levels
                                    .map(
                                      (value) => ChoiceChip(
                                        label: Text(_levelLabel(value)),
                                        selected: _childLevel == value,
                                        onSelected: (_) => setState(() {
                                          _childLevel = value;
                                          _childTopic = null;
                                          _childLevelId = null;
                                        }),
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                          if (_childLevel != null) ...[
                            const SizedBox(height: 16),
                            Text('3. Konu seç', style: _adultTitleStyle()),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: filteredTopics
                                  .map(
                                    (topic) => ChoiceChip(
                                      label: Text(topic.name),
                                      selected: _childTopic?.id == topic.id,
                                      onSelected: (_) =>
                                          _selectChildTopic(topic),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _childLevelId != null && !_childLevelLoading
                                    ? () => context.go(
                                        '/match/request?subjectId=${_childSubject!.id}'
                                        '&subjectName=${Uri.encodeComponent(_childSubject!.name)}'
                                        '&levelId=$_childLevelId',
                                      )
                                    : null,
                                child: _childLevelLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Rakip Bul'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdult(BuildContext context, WidgetRef ref) {
    final subjects =
        ref.watch(subjectListProvider).valueOrNull ?? const <Subject>[];
    Subject? englishSubject;
    for (final subject in subjects) {
      final normalized = subject.name.toLowerCase().replaceAll('i̇', 'i');
      if (normalized == 'ingilizce') {
        englishSubject = subject;
        break;
      }
    }
    final isEnglish = _competitionType == 2;
    final topicsState = isEnglish && englishSubject != null
        ? ref.watch(topicListProvider(englishSubject.id))
        : null;
    final englishLevel = const {
      'A1': 1,
      'A2': 2,
      'B1': 3,
      'B2': 4,
      'C1': 5,
      'C2': 6,
    }[_difficulty];
    final englishTopics =
        topicsState?.valueOrNull
            ?.where(
              (topic) =>
                  topic.isActive &&
                  (topic.englishLevel ?? topic.gradeLevel) == englishLevel,
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
    const modes = <(int, IconData, String)>[
      (0, Icons.public_rounded, 'Genel Kültür Düellosu'),
      (2, Icons.language_rounded, 'İngilizce Quiz'),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Canlı Yarış',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 28,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Color(0xFF3D35CC),
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const LiveMatchQuotaBanner(),
              const SizedBox(height: 6),
              const LiveMatchRankedBadge(),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F0FF),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              competitionSectionLabel(1, 'Yarışma türü'),
                              const SizedBox(height: 10),
                              ...modes.map(
                                (mode) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CompetitionModeCard(
                                    icon: mode.$2,
                                    label: mode.$3,
                                    selected: _competitionType == mode.$1,
                                    onTap: () => setState(() {
                                      _competitionType = mode.$1;
                                      _difficulty = null;
                                      _topicKey = null;
                                    }),
                                  ),
                                ),
                              ),
                              if (_competitionType != null) ...[
                                const SizedBox(height: 14),
                                competitionSectionLabel(
                                  2,
                                  isEnglish
                                      ? 'İngilizce seviyesi'
                                      : 'Zorluk seviyesi',
                                ),
                                const SizedBox(height: 10),
                                if (isEnglish)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
                                            .map(
                                              (value) => CompetitionPill(
                                                label: value,
                                                selected: _difficulty == value,
                                                onTap: () => setState(() {
                                                  _difficulty = value;
                                                  _topicKey = null;
                                                }),
                                              ),
                                            )
                                            .toList(),
                                  )
                                else
                                  DifficultyPills(
                                    selected: _difficulty,
                                    onSelect: (value) => setState(() {
                                      _difficulty = value;
                                      _topicKey = null;
                                    }),
                                  ),
                              ],
                              if (_difficulty != null) ...[
                                const SizedBox(height: 16),
                                competitionSectionLabel(3, 'Konu seç'),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      (isEnglish
                                              ? englishTopics.map(
                                                  (topic) => topic.name,
                                                )
                                              : generalTopics.keys)
                                          .map((label) {
                                            final key = isEnglish
                                                ? 'ingilizce:$label'
                                                : generalTopics[label]!;
                                            return CompetitionPill(
                                              label: label,
                                              selected: _topicKey == key,
                                              onTap: () => setState(
                                                () => _topicKey = key,
                                              ),
                                            );
                                          })
                                          .toList(),
                                ),
                              ],
                              if (isEnglish &&
                                  _difficulty != null &&
                                  topicsState?.isLoading == true)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (isEnglish &&
                                  _difficulty != null &&
                                  topicsState?.hasValue == true &&
                                  englishTopics.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'Bu seviyede aktif İngilizce konusu bulunamadı.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _competitionType != null &&
                                  _difficulty != null &&
                                  _topicKey != null
                              ? () => context.go(
                                  '/match/request?competitionType=$_competitionType'
                                  '&competitionTopicKey=${Uri.encodeComponent(_topicKey!)}'
                                  '&competitionDifficulty=${Uri.encodeComponent(_difficulty!)}',
                                )
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF7B61FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            'Rakip Bul',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
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

  TextStyle _adultTitleStyle() => GoogleFonts.nunito(
    fontWeight: FontWeight.w900,
    fontSize: 17,
    color: const Color(0xFF2D2060),
  );
}

class _SubjectButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final Color shadowColor;
  final bool selected;
  final VoidCallback onTap;

  const _SubjectButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.shadowColor,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.18),
                offset: const Offset(0, -3),
                blurRadius: 6,
              ),
            ],
            border: selected ? Border.all(color: Colors.white, width: 3) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, color: Colors.white, size: 26)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        offset: const Offset(1, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.75),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

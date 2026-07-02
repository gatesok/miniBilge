import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/classroom_provider.dart';
import '../models/classroom_models.dart';
import '../../education/models/subject.dart';
import '../../education/models/topic.dart';
import '../../education/models/level.dart';
import '../../education/providers/subject_provider.dart';
import '../../education/providers/topic_provider.dart';
import '../../education/providers/level_provider.dart';

// ── Tasarım sabitleri ────────────────────────────────────────────────────────

const _kGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF4FACFE), Color(0xFF9B8FE8), Color(0xFFC4A8E2)],
);

BoxDecoration _glassCard({double radius = 16}) => BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.45)),
);

// ── Sınıf Detay Ekranı ────────────────────────────────────────────────────────

class ClassroomDetailScreen extends ConsumerStatefulWidget {
  final String classroomId;
  const ClassroomDetailScreen({super.key, required this.classroomId});

  @override
  ConsumerState<ClassroomDetailScreen> createState() =>
      _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends ConsumerState<ClassroomDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(classroomNotifierProvider.notifier)
          .loadDetail(widget.classroomId);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(classroomNotifierProvider);
    final detail  = state.currentDetail;
    final isOwner = detail?.isOwner ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _kGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        detail?.name ?? '🏫 Sınıf',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOwner)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
                            onPressed: () => ref.read(classroomNotifierProvider.notifier).loadDetail(widget.classroomId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_task_rounded, color: Colors.white),
                            onPressed: () => _showAssignmentDialog(context, detail!),
                          ),
                        ],
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
                        onPressed: () => ref.read(classroomNotifierProvider.notifier).loadDetail(widget.classroomId),
                      ),
                  ],
                ),
              ),

              // ── Davet Kodu (sadece owner) ─────────────────────────
              if (isOwner && detail != null && detail.inviteCode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: detail.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Davet kodu kopyalandı: ${detail.inviteCode}',
                              style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                          backgroundColor: const Color(0xFF4A3ACD),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.key_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Davet Kodu: ${detail.inviteCode}',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_rounded, color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Tab Bar ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: const Color(0xFF4A3ACD),
                    unselectedLabelColor: Colors.white,
                    labelStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 13),
                    unselectedLabelStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: '📋 Ödevler'),
                      Tab(text: '🏆 Sıralama'),
                      Tab(text: '👥 Üyeler'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── İçerik ────────────────────────────────────────────
              Expanded(
                child: state.isLoading || detail == null
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(classroomNotifierProvider.notifier)
                            .loadDetail(widget.classroomId),
                        color: const Color(0xFF4A3ACD),
                        child: TabBarView(
                          controller: _tabs,
                          children: [
                            _AssignmentsTab(detail: detail),
                            _LeaderboardTab(members: detail.members),
                            _MembersTab(
                                members: detail.members,
                                isOwner: isOwner,
                                classroomId: detail.id),
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

  void _showAssignmentDialog(BuildContext context, ClassroomDetailDto detail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, sc) => _CreateAssignmentSheet(
          classroomId: detail.id,
          scrollController: sc,
        ),
      ),
    );
  }
}

// ── Tab: Ödevler ──────────────────────────────────────────────────────────────

class _AssignmentsTab extends StatelessWidget {
  final ClassroomDetailDto detail;
  const _AssignmentsTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    final assignments = detail.assignments;

    if (assignments.isEmpty) {
      return Center(
        child: Text(
          detail.isOwner
              ? 'Henüz ödev atanmadı.\nSağ üstteki + butonuna bas.'
              : 'Henüz ödev yok.',
          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: assignments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _AssignmentCard(
        assignment: assignments[i],
        isOwner: detail.isOwner,
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentSummaryDto assignment;
  final bool isOwner;
  const _AssignmentCard({required this.assignment, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final progress = assignment.minQuestions > 0
        ? (assignment.myProgress / assignment.minQuestions).clamp(0.0, 1.0)
        : 0.0;
    final isOverdue = assignment.dueDate != null &&
        assignment.dueDate!.isBefore(DateTime.now()) &&
        !assignment.isCompleted;

    return GestureDetector(
      onTap: assignment.levelId.isNotEmpty
          ? () => context.push(
                '/education/quiz/${assignment.levelId}',
                extra: {
                  'levelName': assignment.title,
                  'topicName': assignment.topicName,
                  'subjectName': assignment.subjectName,
                },
              )
          : null,
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: _glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment.title,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (assignment.isCompleted)
                _Chip('✅ Tamamlandı', const Color(0xFF43A047))
              else if (isOverdue)
                _Chip('⏰ Süresi Geçti', Colors.redAccent)
              else if (isOwner)
                _Chip(
                  '${assignment.completedBy}/${assignment.memberCount}'
                  '${assignment.completedBy > 0 ? " · ort. ${assignment.averageCorrectCount} ✓" : ""}',
                  const Color(0xFF6A5ACD),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${assignment.subjectName} · ${assignment.topicName}',
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12),
          ),
          if (assignment.dueDate != null) ...[
            const SizedBox(height: 2),
            Text(
              'Son: ${DateFormat('d MMM', 'tr').format(assignment.dueDate!)}',
              style: GoogleFonts.nunito(
                color: isOverdue ? Colors.redAccent : Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(
                assignment.isCompleted
                    ? const Color(0xFF43A047)
                    : const Color(0xFF6A5ACD),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${assignment.myProgress} / ${assignment.minQuestions} soru',
            style: GoogleFonts.nunito(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );
}

// ── Tab: Sıralama ─────────────────────────────────────────────────────────────

class _LeaderboardTab extends StatelessWidget {
  final List<ClassroomMemberDto> members;
  const _LeaderboardTab({required this.members});

  @override
  Widget build(BuildContext context) {
    final sorted = [...members]
      ..sort((a, b) =>
          b.completedAssignments.compareTo(a.completedAssignments));

    if (sorted.isEmpty) {
      return Center(
        child: Text('Henüz tamamlanan ödev yok.',
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final m = sorted[i];
        final medal = i == 0
            ? '🥇'
            : i == 1
                ? '🥈'
                : i == 2
                    ? '🥉'
                    : '${i + 1}.';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: _glassCard(radius: 14),
          child: Row(
            children: [
              Text(medal, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(m.name,
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
              Text('${m.completedAssignments} ödev',
                  style: GoogleFonts.nunito(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

// ── Tab: Üyeler ───────────────────────────────────────────────────────────────

class _MembersTab extends ConsumerWidget {
  final List<ClassroomMemberDto> members;
  final bool isOwner;
  final String classroomId;

  const _MembersTab({
    required this.members,
    required this.isOwner,
    required this.classroomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (members.isEmpty) {
      return Center(
        child: Text('Henüz üye yok.',
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final m = members[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: _glassCard(radius: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF6A5ACD).withOpacity(0.4),
                backgroundImage: m.avatarUrl != null
                    ? NetworkImage(m.avatarUrl!)
                    : null,
                child: m.avatarUrl == null
                    ? Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name,
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text('${m.completedAssignments} ödev tamamladı',
                        style: GoogleFonts.nunito(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Ödev Oluştur Sheet ────────────────────────────────────────────────────────

class _CreateAssignmentSheet extends ConsumerStatefulWidget {
  final String classroomId;
  final ScrollController scrollController;

  const _CreateAssignmentSheet({
    required this.classroomId,
    required this.scrollController,
  });

  @override
  ConsumerState<_CreateAssignmentSheet> createState() =>
      _CreateAssignmentSheetState();
}

class _CreateAssignmentSheetState
    extends ConsumerState<_CreateAssignmentSheet> {
  final _titleCtrl = TextEditingController();
  Subject? _selectedSubject;
  int?     _gradeFilter;
  Topic?   _selectedTopic;
  List<Level>? _availableLevels;
  bool     _levelLoading = false;
  String?  _selectedLevelId;
  DateTime? _dueDate;
  int _minQuestions = 10;
  bool _loading = false;
  String? _error;

  bool _isEnglish(Subject? s) {
    final n = s?.name.toLowerCase() ?? '';
    return n.contains('ngilizce') || n.contains('english');
  }

  String _gradeLabel(int g) {
    if (_isEnglish(_selectedSubject)) {
      const map = {1: 'A1', 2: 'A2', 3: 'B1', 4: 'B2', 5: 'C1', 6: 'C2'};
      return map[g] ?? 'Seviye $g';
    }
    return '$g. Sınıf';
  }

  int _topicLevel(Topic t) =>
      _isEnglish(_selectedSubject) ? (t.englishLevel ?? t.gradeLevel) : t.gradeLevel;

  Future<void> _selectTopic(Topic t) async {
    setState(() {
      _selectedTopic   = t;
      _selectedLevelId = null;
      _availableLevels = null;
      _levelLoading    = true;
    });
    try {
      final levels = await ref.read(levelListProvider(t.id).future);
      final active = levels.where((l) => l.isActive).toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      if (mounted) {
        setState(() {
          _availableLevels = active;
          // Tek ünite varsa otomatik seç (İngilizce gibi)
          if (active.length == 1) _selectedLevelId = active.first.id;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _levelLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _send() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Ödev başlığı boş olamaz.');
      return;
    }
    if (_selectedLevelId == null) {
      setState(() => _error = 'Lütfen bir konu seçin.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final ok = await ref.read(classroomNotifierProvider.notifier).createAssignment(
      classroomId:  widget.classroomId,
      levelId:      _selectedLevelId!,
      title:        title,
      dueDate:      _dueDate,
      minQuestions: _minQuestions,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _loading = false;
        _error = ref.read(classroomNotifierProvider).error ?? 'Bir hata oluştu.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectListProvider).value ?? [];
    final allTopics = _selectedSubject != null
        ? (ref.watch(topicListProvider(_selectedSubject!.id)).value ?? [])
        : <Topic>[];
    final grades = allTopics
        .where((t) => t.isActive)
        .map(_topicLevel)
        .toSet()
        .toList()
      ..sort();
    final filteredTopics = _gradeFilter != null
        ? allTopics.where((t) => t.isActive && _topicLevel(t) == _gradeFilter).toList()
        : <Topic>[];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D2060),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text('Ödev Ata',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),

                // Başlık
                _SectionLabel('Ödev Başlığı'),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('örn. Present Perfect alıştırması'),
                ),
                const SizedBox(height: 16),

                // Adım 1: Ders
                _SectionLabel('1. Ders'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: subjects
                      .map((s) => _SelectChip(
                            label: s.name,
                            selected: _selectedSubject?.id == s.id,
                            onTap: () => setState(() {
                              _selectedSubject = s;
                              _gradeFilter     = null;
                              _selectedTopic   = null;
                              _selectedLevelId = null;
                            }),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Adım 2: Seviye
                if (_selectedSubject != null) ...[
                  _SectionLabel(_isEnglish(_selectedSubject) ? '2. Dil Seviyesi' : '2. Sınıf'),
                  const SizedBox(height: 6),
                  if (grades.isEmpty)
                    const Text('Yükleniyor...', style: TextStyle(color: Colors.white54))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: grades
                          .map((g) => _SelectChip(
                                label: _gradeLabel(g),
                                selected: _gradeFilter == g,
                                onTap: () => setState(() {
                                  _gradeFilter     = g;
                                  _selectedTopic   = null;
                                  _selectedLevelId = null;
                                }),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                ],

                // Adım 3: Konu
                if (_gradeFilter != null) ...[
                  _SectionLabel('3. Konu'),
                  const SizedBox(height: 6),
                  if (filteredTopics.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Bu seviyede konu bulunamadı.',
                          style: TextStyle(color: Colors.white54)),
                    )
                  else
                    ...filteredTopics.map((t) => GestureDetector(
                          onTap: () => _selectTopic(t),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedTopic?.id == t.id
                                  ? const Color(0xFF6A5ACD)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedTopic?.id == t.id
                                    ? Colors.white
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(t.name,
                                      style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontWeight: _selectedTopic?.id == t.id
                                              ? FontWeight.w800
                                              : FontWeight.w600)),
                                ),
                                if (_selectedTopic?.id == t.id && _levelLoading)
                                  const SizedBox(
                                    width: 16, height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                else if (_selectedTopic?.id == t.id)
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        )),
                  const SizedBox(height: 8),
                ],

                // Adım 4: Ünite (birden fazla level varsa göster)
                if (_selectedTopic != null) ...[
                  if (_levelLoading && _availableLevels == null)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Center(child: SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))),
                    )
                  else if (_availableLevels != null && _availableLevels!.length > 1) ...[
                    _SectionLabel('4. Ünite'),
                    const SizedBox(height: 6),
                    ..._availableLevels!.map((l) => GestureDetector(
                          onTap: () => setState(() => _selectedLevelId = l.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedLevelId == l.id
                                  ? const Color(0xFF6A5ACD)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedLevelId == l.id
                                    ? Colors.white
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(l.name,
                                      style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontWeight: _selectedLevelId == l.id
                                              ? FontWeight.w800
                                              : FontWeight.w600)),
                                ),
                                if (_selectedLevelId == l.id)
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],
                ],

                // Minimum soru sayısı
                _SectionLabel('Minimum Soru Sayısı'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final q in [5, 10, 15, 20])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _SelectChip(
                          label: '$q',
                          selected: _minQuestions == q,
                          onTap: () => setState(() => _minQuestions = q),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Son tarih
                _SectionLabel('Son Tarih (opsiyonel)'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _dueDate != null
                              ? DateFormat('d MMMM yyyy', 'tr')
                                  .format(_dueDate!)
                              : 'Tarih seç',
                          style: GoogleFonts.nunito(
                              color: _dueDate != null
                                  ? Colors.white
                                  : Colors.white54),
                        ),
                        if (_dueDate != null) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _dueDate = null),
                            child: const Icon(Icons.close,
                                color: Colors.white54, size: 18),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A5ACD),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Ödevi Gönder',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.nunito(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5),
      );
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF6A5ACD)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.white : Colors.white30,
            ),
          ),
          child: Text(label,
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w600)),
        ),
      );
}

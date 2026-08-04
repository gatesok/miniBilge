import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../tournament/models/tournament_models.dart';
import '../../tournament/providers/tournament_provider.dart';
import '../models/weak_topic.dart';
import '../models/weekly_goal.dart';
import '../providers/parent_report_service_provider.dart';
import '../providers/weekly_goal_provider.dart';

/// P6-M02: Ebeveynin çocuk için haftalık hedef (çalışma dakikası + odak konu)
/// belirlediği/düzenlediği ekran. Yalnızca premium.
class WeeklyGoalScreen extends ConsumerStatefulWidget {
  const WeeklyGoalScreen({super.key});

  @override
  ConsumerState<WeeklyGoalScreen> createState() => _WeeklyGoalScreenState();
}

class _WeeklyGoalScreenState extends ConsumerState<WeeklyGoalScreen> {
  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  final _minutesController = TextEditingController();
  // Odak seçimi kodlanmış değer: 'topic:<id>' | 'cat:<key>' | null.
  String? _focusSelection;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _initFromGoal(WeeklyGoal goal) {
    if (_initialized) return;
    _initialized = true;
    if (goal.weeklyStudyMinutesGoal != null) {
      _minutesController.text = goal.weeklyStudyMinutesGoal.toString();
    }
    _focusSelection = goal.focusCategoryKey != null
        ? 'cat:${goal.focusCategoryKey}'
        : (goal.focusTopicId != null ? 'topic:${goal.focusTopicId}' : null);
  }

  Future<void> _save(String childId) async {
    final minutesText = _minutesController.text.trim();
    final minutes = minutesText.isEmpty ? null : int.tryParse(minutesText);

    if (minutesText.isNotEmpty && (minutes == null || minutes < 0 || minutes > 10080)) {
      _showSnack('Geçerli bir dakika değeri girin (0-10080).', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final api = ref.read(parentReportApiServiceProvider);
      String? topicId;
      String? categoryKey;
      final sel = _focusSelection;
      if (sel != null && sel.startsWith('cat:')) {
        categoryKey = sel.substring(4);
      } else if (sel != null && sel.startsWith('topic:')) {
        topicId = sel.substring(6);
      }
      await api.setWeeklyGoal(
        childId,
        weeklyStudyMinutesGoal: minutes,
        focusTopicId: topicId,
        focusCategoryKey: categoryKey,
      );
      ref.invalidate(weeklyGoalProvider(childId));
      if (!mounted) return;
      _showSnack('Haftalık hedef kaydedildi.');
    } catch (_) {
      _showSnack('Hedef kaydedilemedi. Lütfen tekrar deneyin.', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedChild = ref.watch(selectedChildProvider);

    if (selectedChild == null) {
      return _scaffold(
        child: Center(
          child: Text(
            'Lütfen bir çocuk profili seçin',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final isPremium = ref.watch(authProvider).maybeWhen(
          authenticated: (user) => user.isPremium,
          orElse: () => false,
        );

    if (!isPremium) {
      return _scaffold(
        childName: selectedChild.name,
        child: _premiumTeaser(),
      );
    }

    final childId = selectedChild.id.toString();
    final goalAsync = ref.watch(weeklyGoalProvider(childId));

    return _scaffold(
      childName: selectedChild.name,
      child: goalAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                'Hedef bilgisi yüklenemedi',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _pillButton(
                'Tekrar Dene',
                () => ref.invalidate(weeklyGoalProvider(childId)),
              ),
            ],
          ),
        ),
        data: (goal) {
          _initFromGoal(goal);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _progressCard(goal),
                const SizedBox(height: 16),
                _minutesCard(),
                const SizedBox(height: 16),
                _focusTopicCard(childId, selectedChild.isAdultProfile),
                const SizedBox(height: 24),
                _saveButton(childId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _scaffold({required Widget child, String? childName}) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        childName != null ? '$childName – Haftalık Hedef' : 'Haftalık Hedef',
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 20,
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
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumTeaser() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                size: 72, color: Color(0xFFFFB300)),
            const SizedBox(height: 16),
            Text(
              'Kişisel Hedefler',
              style: GoogleFonts.luckiestGuy(
                color: Colors.white,
                fontSize: 24,
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
            const SizedBox(height: 10),
            Text(
              'Haftalık çalışma hedefi ve odak konu belirleme Premium üyelere özeldir.',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/premium'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B61FF), Color(0xFFAA9FE8)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  "Premium'a Geç",
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _progressCard(WeeklyGoal goal) {
    final goalMinutes = goal.weeklyStudyMinutesGoal;
    final progress = (goalMinutes != null && goalMinutes > 0)
        ? (goal.studyMinutesThisWeek / goalMinutes).clamp(0.0, 1.0)
        : null;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.insights_rounded, 'Bu Hafta'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  '${goal.studyMinutesThisWeek} dk',
                  'Çalışma süresi',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statTile(
                  '${goal.questionsThisWeek}',
                  'Çözülen soru',
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: const Color(0xFFEDEBFF),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${goal.studyMinutesThisWeek} / $goalMinutes dk hedef',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
          if (goal.focusTopicName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.center_focus_strong_rounded,
                      size: 20, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Odak: ${goal.focusTopicName}',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        if (goal.focusTopicSuccessRate != null)
                          Text(
                            'Bu haftaki başarı: %${(goal.focusTopicSuccessRate! * 100).round()}',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statTile(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.luckiestGuy(
              fontSize: 22,
              color: const Color(0xFF3D35CC),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _minutesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.timer_rounded, 'Haftalık Çalışma Hedefi'),
          const SizedBox(height: 6),
          Text(
            'Çocuğunuzun bu hafta ulaşmasını istediğiniz toplam çalışma dakikası.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Örn. 120',
              suffixText: 'dakika',
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [60, 120, 180, 240]
                .map((m) => _presetChip(m))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _presetChip(int minutes) {
    return ActionChip(
      label: Text('$minutes dk'),
      labelStyle: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF3D35CC),
      ),
      backgroundColor: const Color(0xFFF3F1FF),
      side: BorderSide.none,
      onPressed: () => setState(() => _minutesController.text = minutes.toString()),
    );
  }

  Widget _focusTopicCard(String childId, bool isAdult) {
    final optionsAsync = ref.watch(focusTopicOptionsProvider(childId));
    // Yetişkin profilinde odak olarak eğlence kategorileri de seçilebilir.
    final categories = isAdult
        ? ref.watch(tournamentCategoriesProvider).maybeWhen(
            data: (c) => c,
            orElse: () => const <TournamentCategory>[],
          )
        : const <TournamentCategory>[];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.center_focus_strong_rounded, 'Odak Konu'),
          const SizedBox(height: 6),
          Text(
            isAdult
                ? 'Bu hafta odaklanmak istediğin alanı seç: İngilizce konusu ya da Eğlence Quiz kategorisi (opsiyonel).'
                : 'Bu hafta özellikle pekiştirmek istediğiniz konuyu seçin (opsiyonel).',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          optionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
            error: (_, _) => Text(
              'Konu listesi yüklenemedi.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
            data: (topics) => _focusDropdown(topics, categories, isAdult),
          ),
        ],
      ),
    );
  }

  Widget _focusDropdown(
    List<WeakTopic> topics,
    List<TournamentCategory> categories,
    bool isAdult,
  ) {
    bool isEnglish(String s) {
      final n = s.toLowerCase();
      return n.contains('ngiliz') || n.contains('english');
    }

    bool isMath(String s) => s.trim().toLowerCase().startsWith('mat');

    // Yetişkin: yalnızca İngilizce konuları. Çocuk: İngilizce + Matematik.
    // Konular karışık gelmesin: İngilizce grubu üstte, Matematik grubu altta.
    // Grup içi sıra (en zayıf ilk) korunur.
    final englishTopics = topics.where((t) => isEnglish(t.subjectName)).toList();
    final mathTopics = topics
        .where((t) => !isAdult && isMath(t.subjectName))
        .toList();
    final filteredTopics = [...englishTopics, ...mathTopics];

    // Kayıtlı seçim listede yoksa dropdown hata vermesin diye doğrula.
    final validValues = <String>{
      ...filteredTopics.map((t) => 'topic:${t.topicId}'),
      ...categories.map((c) => 'cat:${c.key}'),
    };
    final value = (_focusSelection != null && validValues.contains(_focusSelection))
        ? _focusSelection
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: value,
          hint: Text(
            'Odak konu yok',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'Odak konu yok',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            ...filteredTopics.map(
              (t) => DropdownMenuItem<String?>(
                value: 'topic:${t.topicId}',
                child: Text(
                  '${t.subjectName} · ${t.topicName}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            ...categories.map(
              (c) => DropdownMenuItem<String?>(
                value: 'cat:${c.key}',
                child: Text(
                  '${c.emoji} ${c.label}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _focusSelection = v),
        ),
      ),
    );
  }

  Widget _saveButton(String childId) {
    return GestureDetector(
      onTap: _saving ? null : () => _save(childId),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B61FF), Color(0xFFAA9FE8)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B61FF).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _saving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Hedefi Kaydet',
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _pillButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3FCC),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          text,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

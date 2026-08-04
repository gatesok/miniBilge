import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../models/challenge_history.dart';
import '../models/entertainment_stats.dart';
import '../providers/parent_report_provider.dart';
import '../providers/parent_report_state.dart';
import '../providers/progress_dashboard_provider.dart';
import '../services/report_export_service.dart';
import '../widgets/activity_summary_widget.dart';
import '../widgets/daily_summary_widget.dart';
import '../widgets/weekly_summary_widget.dart';
import '../widgets/progress_dashboard_widget.dart';

class ParentReportScreen extends ConsumerStatefulWidget {
  const ParentReportScreen({super.key});

  @override
  ConsumerState<ParentReportScreen> createState() => _ParentReportScreenState();
}

class _ParentReportScreenState extends ConsumerState<ParentReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReport() {
    final child = ref.read(selectedChildProvider);
    if (child != null) {
      ref.read(parentReportProvider.notifier).loadReport(child.id);
    }
  }

  Future<void> _shareReport(
    String childName,
    ParentReportState state,
    Rect origin,
  ) async {
    final isPremium = ref.read(authProvider).maybeWhen(
      authenticated: (user) => user.isPremium,
      orElse: () => false,
    );
    if (!isPremium) {
      context.push('/premium');
      return;
    }
    final loaded = state.mapOrNull(
      loaded: (s) => (weekly: s.weeklySummary, weak: s.weakTopics),
    );
    if (loaded == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapor henüz hazır değil, biraz bekleyin.')),
      );
      return;
    }
    final childId = loaded.weekly.childId;
    // Eğlence quizi ve meydan okuma özetleri premium panelde ayrı endpoint'ten
    // geliyor; paylaşıma da eklemek için burada çekiyoruz (hata paylaşımı bloklamasın).
    EntertainmentStats? entertainment;
    ChallengeHistory? challenge;
    try {
      entertainment = await ref.read(entertainmentStatsProvider(childId).future);
    } catch (_) {}
    try {
      challenge = await ref.read(challengeHistoryProvider(childId).future);
    } catch (_) {}
    if (!mounted) return;
    await const ReportExportService().shareReport(
      childName: childName,
      weekly: loaded.weekly,
      weakTopics: loaded.weak,
      entertainment: entertainment,
      challenge: challenge,
      sharePositionOrigin: origin,
    );
  }

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  Widget build(BuildContext context) {
    final selectedChild = ref.watch(selectedChildProvider);
    final reportState = ref.watch(parentReportProvider);

    if (selectedChild == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _gradient),
          child: SafeArea(
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
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icon/dashboard_report.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${selectedChild.name} – Rapor',
                                style: GoogleFonts.luckiestGuy(
                                  fontSize: 22,
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ShareReportButton(
                      onTap: (origin) =>
                          _shareReport(selectedChild.name, reportState, origin),
                    ),
                    const SizedBox(width: 8),
                    _WeeklyGoalButton(
                      onTap: () => context.push('/weekly-goal'),
                    ),
                  ],
                ),
              ),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B61FF), Color(0xFFAA9FE8)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 3),
                    tabs: const [
                      _ReportTab(icon: Icons.today_rounded, label: 'Günlük'),
                      _ReportTab(
                        icon: Icons.calendar_view_week_rounded,
                        label: 'Haftalık',
                      ),
                      _ReportTab(
                        icon: Icons.trending_down_rounded,
                        label: 'Gelişim',
                      ),
                      _ReportTab(
                        icon: Icons.insights_rounded,
                        label: 'Etkinlik',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Content
              Expanded(
                child: reportState.when(
                  initial: () => Center(
                    child: Text(
                      'Veri bekleniyor...',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _loadReport,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A3FCC),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                'Tekrar Dene',
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
                  ),
                  loaded: (dailySummary, weeklySummary, weakTopics) =>
                      TabBarView(
                        controller: _tabController,
                        children: [
                          DailySummaryWidget(summary: dailySummary),
                          WeeklySummaryWidget(summary: weeklySummary),
                          ProgressDashboardWidget(
                            childId: selectedChild.id.toString(),
                            weakTopics: weakTopics,
                          ),
                          ActivitySummaryWidget(
                            childId: selectedChild.id.toString(),
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
}

class _ReportTab extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ReportTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyGoalButton extends StatelessWidget {
  final VoidCallback onTap;

  const _WeeklyGoalButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          'assets/images/personal_goal_report_icon.png',
          width: 34,
          height: 34,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _ShareReportButton extends StatelessWidget {
  final void Function(Rect origin) onTap;

  const _ShareReportButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final box = context.findRenderObject() as RenderBox?;
        final origin = (box != null && box.hasSize)
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 1, 1);
        onTap(origin);
      },
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
          Icons.ios_share_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

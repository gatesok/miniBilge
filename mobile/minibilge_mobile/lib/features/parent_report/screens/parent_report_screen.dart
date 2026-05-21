import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../providers/parent_report_provider.dart';
import '../widgets/daily_summary_widget.dart';
import '../widgets/weekly_summary_widget.dart';
import '../widgets/weak_topics_widget.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5), width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${selectedChild.name} – Rapor',
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 22,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(2, 2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.45), width: 1.5),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF7B61FF), Color(0xFFAA9FE8)]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    tabs: [
                      Tab(
                          child: Text('📅 Günlük',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800, fontSize: 13))),
                      Tab(
                          child: Text('📆 Haftalık',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800, fontSize: 13))),
                      Tab(
                          child: Text('⚠️ Zayıf',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800, fontSize: 13))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Content
              Expanded(
                child: reportState.when(
                  initial: () => Center(
                    child: Text('Veri bekleniyor...',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.white),
                          const SizedBox(height: 16),
                          Text(message,
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _loadReport,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A3FCC),
                                borderRadius: BorderRadius.circular(24),
                              ),
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
                  loaded: (dailySummary, weeklySummary, weakTopics) => TabBarView(
                    controller: _tabController,
                    children: [
                      DailySummaryWidget(summary: dailySummary),
                      WeeklySummaryWidget(summary: weeklySummary),
                      WeakTopicsWidget(topics: weakTopics),
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

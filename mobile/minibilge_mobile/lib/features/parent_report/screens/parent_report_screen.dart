import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedChild = ref.watch(selectedChildProvider);
    final reportState = ref.watch(parentReportProvider);

    if (selectedChild == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('İlerleme Raporu')),
        body: const Center(child: Text('Lütfen bir çocuk profili seçin')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedChild.name} – Rapor'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Günlük'),
            Tab(icon: Icon(Icons.date_range), text: 'Haftalık'),
            Tab(icon: Icon(Icons.warning_amber), text: 'Zayıf Konular'),
          ],
        ),
      ),
      body: reportState.when(
        initial: () => const Center(child: Text('Veri bekleniyor...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(message, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadReport,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
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
    );
  }
}

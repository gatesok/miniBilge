import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/parent_report_api_service.dart';
import 'parent_report_service_provider.dart';
import 'parent_report_state.dart';

class ParentReportNotifier extends StateNotifier<ParentReportState> {
  final ParentReportApiService _apiService;

  ParentReportNotifier(this._apiService) : super(const ParentReportState.initial());

  /// Günlük + haftalık + zayıf konuları tek seferde yükler
  Future<void> loadReport(String childId, {DateTime? date, DateTime? weekStart}) async {
    state = const ParentReportState.loading();
    try {
      final results = await Future.wait([
        _apiService.getDailySummary(childId, date: date),
        _apiService.getWeeklySummary(childId, weekStart: weekStart),
        _apiService.getWeakTopics(childId),
      ]);

      state = ParentReportState.loaded(
        dailySummary: results[0] as dynamic,
        weeklySummary: results[1] as dynamic,
        weakTopics: results[2] as dynamic,
      );
    } on DioException catch (e) {
      state = ParentReportState.error(_extractMessage(e));
    } catch (e) {
      state = ParentReportState.error('Rapor yüklenirken bir hata oluştu');
    }
  }

  /// Sadece günlük özeti yenile (tarih değişince)
  Future<void> refreshDaily(String childId, DateTime date) async {
    final current = state;
    try {
      final daily = await _apiService.getDailySummary(childId, date: date);
      current.maybeWhen(
        loaded: (_, weekly, weak) {
          state = ParentReportState.loaded(
            dailySummary: daily,
            weeklySummary: weekly,
            weakTopics: weak,
          );
        },
        orElse: () {},
      );
    } on DioException catch (e) {
      state = ParentReportState.error(_extractMessage(e));
    }
  }

  /// Sadece haftalık özeti yenile (hafta değişince)
  Future<void> refreshWeekly(String childId, DateTime weekStart) async {
    final current = state;
    try {
      final weekly = await _apiService.getWeeklySummary(childId, weekStart: weekStart);
      current.maybeWhen(
        loaded: (daily, _, weak) {
          state = ParentReportState.loaded(
            dailySummary: daily,
            weeklySummary: weekly,
            weakTopics: weak,
          );
        },
        orElse: () {},
      );
    } on DioException catch (e) {
      state = ParentReportState.error(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return 'Sunucuya ulaşılamadı';
  }
}

final parentReportProvider =
    StateNotifierProvider<ParentReportNotifier, ParentReportState>((ref) {
  final service = ref.watch(parentReportApiServiceProvider);
  return ParentReportNotifier(service);
});

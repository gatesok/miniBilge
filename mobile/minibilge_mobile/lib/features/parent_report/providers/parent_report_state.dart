import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/daily_summary.dart';
import '../models/weekly_summary.dart';
import '../models/weak_topic.dart';

part 'parent_report_state.freezed.dart';

@freezed
class ParentReportState with _$ParentReportState {
  const factory ParentReportState.initial() = _Initial;
  const factory ParentReportState.loading() = _Loading;
  const factory ParentReportState.loaded({
    required DailySummary dailySummary,
    required WeeklySummary weeklySummary,
    @Default([]) List<WeakTopic> weakTopics,
  }) = _Loaded;
  const factory ParentReportState.error(String message) = _Error;
}

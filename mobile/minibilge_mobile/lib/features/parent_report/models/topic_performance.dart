import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic_performance.freezed.dart';
part 'topic_performance.g.dart';

/// P6-B06: Konu bazlı performans metriği (premium).
@freezed
class TopicPerformance with _$TopicPerformance {
  const factory TopicPerformance({
    @JsonKey(name: 'TopicId') required String topicId,
    @JsonKey(name: 'TopicName') required String topicName,
    @JsonKey(name: 'SubjectName') required String subjectName,
    @JsonKey(name: 'TotalAttempts') required int totalAttempts,
    @JsonKey(name: 'CorrectAttempts') required int correctAttempts,
    @JsonKey(name: 'SuccessRate') required double successRate,
    @JsonKey(name: 'AverageTimeSeconds') double? averageTimeSeconds,
    @JsonKey(name: 'DistinctDaysPracticed') required int distinctDaysPracticed,
    @JsonKey(name: 'LastPracticedAt') required DateTime lastPracticedAt,
  }) = _TopicPerformance;

  factory TopicPerformance.fromJson(Map<String, dynamic> json) =>
      _$TopicPerformanceFromJson(json);
}

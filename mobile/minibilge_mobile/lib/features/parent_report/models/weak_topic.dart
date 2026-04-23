import 'package:freezed_annotation/freezed_annotation.dart';

part 'weak_topic.freezed.dart';
part 'weak_topic.g.dart';

@freezed
class WeakTopic with _$WeakTopic {
  const factory WeakTopic({
    @JsonKey(name: 'TopicId') required String topicId,
    @JsonKey(name: 'TopicName') required String topicName,
    @JsonKey(name: 'SubjectName') required String subjectName,
    @JsonKey(name: 'TotalAttempts') required int totalAttempts,
    @JsonKey(name: 'CorrectAttempts') required int correctAttempts,
    @JsonKey(name: 'SuccessRate') required double successRate,
  }) = _WeakTopic;

  factory WeakTopic.fromJson(Map<String, dynamic> json) =>
      _$WeakTopicFromJson(json);
}

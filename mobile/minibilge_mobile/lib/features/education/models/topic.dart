import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
class Topic with _$Topic {
  const factory Topic({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'SubjectId') required String subjectId,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'Description') required String description,
    @JsonKey(name: 'DisplayOrder') required int displayOrder,
    @JsonKey(name: 'IsActive') required bool isActive,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) =>
      _$TopicFromJson(json);
}

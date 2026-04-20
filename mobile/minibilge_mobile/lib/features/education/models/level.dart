import 'package:freezed_annotation/freezed_annotation.dart';

part 'level.freezed.dart';
part 'level.g.dart';

@freezed
class Level with _$Level {
  const factory Level({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'TopicId') required String topicId,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'Description') String? description,
    @JsonKey(name: 'Difficulty') required int difficulty,
    @JsonKey(name: 'DisplayOrder') required int displayOrder,
    @JsonKey(name: 'MinCorrectToPass') required int minCorrectToPass,
    @JsonKey(name: 'IsActive') required bool isActive,
  }) = _Level;

  factory Level.fromJson(Map<String, dynamic> json) =>
      _$LevelFromJson(json);
}

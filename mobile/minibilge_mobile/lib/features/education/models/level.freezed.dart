// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Level _$LevelFromJson(Map<String, dynamic> json) {
  return _Level.fromJson(json);
}

/// @nodoc
mixin _$Level {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'TopicId')
  String get topicId => throw _privateConstructorUsedError;
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'Description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'Difficulty')
  int get difficulty => throw _privateConstructorUsedError;
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'MinCorrectToPass')
  int get minCorrectToPass => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsActive')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Level to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Level
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelCopyWith<Level> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelCopyWith<$Res> {
  factory $LevelCopyWith(Level value, $Res Function(Level) then) =
      _$LevelCopyWithImpl<$Res, Level>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'TopicId') String topicId,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'Description') String? description,
    @JsonKey(name: 'Difficulty') int difficulty,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'MinCorrectToPass') int minCorrectToPass,
    @JsonKey(name: 'IsActive') bool isActive,
  });
}

/// @nodoc
class _$LevelCopyWithImpl<$Res, $Val extends Level>
    implements $LevelCopyWith<$Res> {
  _$LevelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Level
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? topicId = null,
    Object? name = null,
    Object? description = freezed,
    Object? difficulty = null,
    Object? displayOrder = null,
    Object? minCorrectToPass = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            topicId: null == topicId
                ? _value.topicId
                : topicId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            minCorrectToPass: null == minCorrectToPass
                ? _value.minCorrectToPass
                : minCorrectToPass // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LevelImplCopyWith<$Res> implements $LevelCopyWith<$Res> {
  factory _$$LevelImplCopyWith(
    _$LevelImpl value,
    $Res Function(_$LevelImpl) then,
  ) = __$$LevelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'TopicId') String topicId,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'Description') String? description,
    @JsonKey(name: 'Difficulty') int difficulty,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'MinCorrectToPass') int minCorrectToPass,
    @JsonKey(name: 'IsActive') bool isActive,
  });
}

/// @nodoc
class __$$LevelImplCopyWithImpl<$Res>
    extends _$LevelCopyWithImpl<$Res, _$LevelImpl>
    implements _$$LevelImplCopyWith<$Res> {
  __$$LevelImplCopyWithImpl(
    _$LevelImpl _value,
    $Res Function(_$LevelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Level
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? topicId = null,
    Object? name = null,
    Object? description = freezed,
    Object? difficulty = null,
    Object? displayOrder = null,
    Object? minCorrectToPass = null,
    Object? isActive = null,
  }) {
    return _then(
      _$LevelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        topicId: null == topicId
            ? _value.topicId
            : topicId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        minCorrectToPass: null == minCorrectToPass
            ? _value.minCorrectToPass
            : minCorrectToPass // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelImpl implements _Level {
  const _$LevelImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'TopicId') required this.topicId,
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'Description') this.description,
    @JsonKey(name: 'Difficulty') required this.difficulty,
    @JsonKey(name: 'DisplayOrder') required this.displayOrder,
    @JsonKey(name: 'MinCorrectToPass') required this.minCorrectToPass,
    @JsonKey(name: 'IsActive') required this.isActive,
  });

  factory _$LevelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'TopicId')
  final String topicId;
  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'Description')
  final String? description;
  @override
  @JsonKey(name: 'Difficulty')
  final int difficulty;
  @override
  @JsonKey(name: 'DisplayOrder')
  final int displayOrder;
  @override
  @JsonKey(name: 'MinCorrectToPass')
  final int minCorrectToPass;
  @override
  @JsonKey(name: 'IsActive')
  final bool isActive;

  @override
  String toString() {
    return 'Level(id: $id, topicId: $topicId, name: $name, description: $description, difficulty: $difficulty, displayOrder: $displayOrder, minCorrectToPass: $minCorrectToPass, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.minCorrectToPass, minCorrectToPass) ||
                other.minCorrectToPass == minCorrectToPass) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    topicId,
    name,
    description,
    difficulty,
    displayOrder,
    minCorrectToPass,
    isActive,
  );

  /// Create a copy of Level
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelImplCopyWith<_$LevelImpl> get copyWith =>
      __$$LevelImplCopyWithImpl<_$LevelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelImplToJson(this);
  }
}

abstract class _Level implements Level {
  const factory _Level({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'TopicId') required final String topicId,
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'Description') final String? description,
    @JsonKey(name: 'Difficulty') required final int difficulty,
    @JsonKey(name: 'DisplayOrder') required final int displayOrder,
    @JsonKey(name: 'MinCorrectToPass') required final int minCorrectToPass,
    @JsonKey(name: 'IsActive') required final bool isActive,
  }) = _$LevelImpl;

  factory _Level.fromJson(Map<String, dynamic> json) = _$LevelImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'TopicId')
  String get topicId;
  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'Description')
  String? get description;
  @override
  @JsonKey(name: 'Difficulty')
  int get difficulty;
  @override
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder;
  @override
  @JsonKey(name: 'MinCorrectToPass')
  int get minCorrectToPass;
  @override
  @JsonKey(name: 'IsActive')
  bool get isActive;

  /// Create a copy of Level
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelImplCopyWith<_$LevelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuestionOption _$QuestionOptionFromJson(Map<String, dynamic> json) {
  return _QuestionOption.fromJson(json);
}

/// @nodoc
mixin _$QuestionOption {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'OptionText')
  String get optionText => throw _privateConstructorUsedError;
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'HasLatex')
  bool get hasLatex => throw _privateConstructorUsedError;

  /// Serializes this QuestionOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionOptionCopyWith<QuestionOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionOptionCopyWith<$Res> {
  factory $QuestionOptionCopyWith(
    QuestionOption value,
    $Res Function(QuestionOption) then,
  ) = _$QuestionOptionCopyWithImpl<$Res, QuestionOption>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'OptionText') String optionText,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'HasLatex') bool hasLatex,
  });
}

/// @nodoc
class _$QuestionOptionCopyWithImpl<$Res, $Val extends QuestionOption>
    implements $QuestionOptionCopyWith<$Res> {
  _$QuestionOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? optionText = null,
    Object? displayOrder = null,
    Object? hasLatex = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            optionText: null == optionText
                ? _value.optionText
                : optionText // ignore: cast_nullable_to_non_nullable
                      as String,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            hasLatex: null == hasLatex
                ? _value.hasLatex
                : hasLatex // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionOptionImplCopyWith<$Res>
    implements $QuestionOptionCopyWith<$Res> {
  factory _$$QuestionOptionImplCopyWith(
    _$QuestionOptionImpl value,
    $Res Function(_$QuestionOptionImpl) then,
  ) = __$$QuestionOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'OptionText') String optionText,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'HasLatex') bool hasLatex,
  });
}

/// @nodoc
class __$$QuestionOptionImplCopyWithImpl<$Res>
    extends _$QuestionOptionCopyWithImpl<$Res, _$QuestionOptionImpl>
    implements _$$QuestionOptionImplCopyWith<$Res> {
  __$$QuestionOptionImplCopyWithImpl(
    _$QuestionOptionImpl _value,
    $Res Function(_$QuestionOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? optionText = null,
    Object? displayOrder = null,
    Object? hasLatex = null,
  }) {
    return _then(
      _$QuestionOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        optionText: null == optionText
            ? _value.optionText
            : optionText // ignore: cast_nullable_to_non_nullable
                  as String,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        hasLatex: null == hasLatex
            ? _value.hasLatex
            : hasLatex // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionOptionImpl implements _QuestionOption {
  const _$QuestionOptionImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'OptionText') required this.optionText,
    @JsonKey(name: 'DisplayOrder') required this.displayOrder,
    @JsonKey(name: 'HasLatex') this.hasLatex = false,
  });

  factory _$QuestionOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionOptionImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'OptionText')
  final String optionText;
  @override
  @JsonKey(name: 'DisplayOrder')
  final int displayOrder;
  @override
  @JsonKey(name: 'HasLatex')
  final bool hasLatex;

  @override
  String toString() {
    return 'QuestionOption(id: $id, optionText: $optionText, displayOrder: $displayOrder, hasLatex: $hasLatex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.optionText, optionText) ||
                other.optionText == optionText) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.hasLatex, hasLatex) ||
                other.hasLatex == hasLatex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, optionText, displayOrder, hasLatex);

  /// Create a copy of QuestionOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionOptionImplCopyWith<_$QuestionOptionImpl> get copyWith =>
      __$$QuestionOptionImplCopyWithImpl<_$QuestionOptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionOptionImplToJson(this);
  }
}

abstract class _QuestionOption implements QuestionOption {
  const factory _QuestionOption({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'OptionText') required final String optionText,
    @JsonKey(name: 'DisplayOrder') required final int displayOrder,
    @JsonKey(name: 'HasLatex') final bool hasLatex,
  }) = _$QuestionOptionImpl;

  factory _QuestionOption.fromJson(Map<String, dynamic> json) =
      _$QuestionOptionImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'OptionText')
  String get optionText;
  @override
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder;
  @override
  @JsonKey(name: 'HasLatex')
  bool get hasLatex;

  /// Create a copy of QuestionOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionOptionImplCopyWith<_$QuestionOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

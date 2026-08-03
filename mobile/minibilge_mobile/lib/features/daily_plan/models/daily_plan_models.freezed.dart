// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_plan_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyPlanDto _$DailyPlanDtoFromJson(Map<String, dynamic> json) {
  return _DailyPlanDto.fromJson(json);
}

/// @nodoc
mixin _$DailyPlanDto {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'PlanDate')
  String get planDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'Status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'Source')
  String get source => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsPremiumPersonalized')
  bool get isPremiumPersonalized => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalItems')
  int get totalItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'CompletedItems')
  int get completedItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'CompletedAt')
  DateTime? get completedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'RewardStars')
  int get rewardStars => throw _privateConstructorUsedError;
  @JsonKey(name: 'RewardPoints')
  int get rewardPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'RewardGranted')
  bool get rewardGranted => throw _privateConstructorUsedError;
  @JsonKey(name: 'Items')
  List<DailyPlanItemDto> get items => throw _privateConstructorUsedError;

  /// Serializes this DailyPlanDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlanDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanDtoCopyWith<DailyPlanDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanDtoCopyWith<$Res> {
  factory $DailyPlanDtoCopyWith(
    DailyPlanDto value,
    $Res Function(DailyPlanDto) then,
  ) = _$DailyPlanDtoCopyWithImpl<$Res, DailyPlanDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'PlanDate') String planDate,
    @JsonKey(name: 'Status') String status,
    @JsonKey(name: 'Source') String source,
    @JsonKey(name: 'IsPremiumPersonalized') bool isPremiumPersonalized,
    @JsonKey(name: 'TotalItems') int totalItems,
    @JsonKey(name: 'CompletedItems') int completedItems,
    @JsonKey(name: 'CompletedAt') DateTime? completedAt,
    @JsonKey(name: 'RewardStars') int rewardStars,
    @JsonKey(name: 'RewardPoints') int rewardPoints,
    @JsonKey(name: 'RewardGranted') bool rewardGranted,
    @JsonKey(name: 'Items') List<DailyPlanItemDto> items,
  });
}

/// @nodoc
class _$DailyPlanDtoCopyWithImpl<$Res, $Val extends DailyPlanDto>
    implements $DailyPlanDtoCopyWith<$Res> {
  _$DailyPlanDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlanDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planDate = null,
    Object? status = null,
    Object? source = null,
    Object? isPremiumPersonalized = null,
    Object? totalItems = null,
    Object? completedItems = null,
    Object? completedAt = freezed,
    Object? rewardStars = null,
    Object? rewardPoints = null,
    Object? rewardGranted = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            planDate: null == planDate
                ? _value.planDate
                : planDate // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            isPremiumPersonalized: null == isPremiumPersonalized
                ? _value.isPremiumPersonalized
                : isPremiumPersonalized // ignore: cast_nullable_to_non_nullable
                      as bool,
            totalItems: null == totalItems
                ? _value.totalItems
                : totalItems // ignore: cast_nullable_to_non_nullable
                      as int,
            completedItems: null == completedItems
                ? _value.completedItems
                : completedItems // ignore: cast_nullable_to_non_nullable
                      as int,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            rewardStars: null == rewardStars
                ? _value.rewardStars
                : rewardStars // ignore: cast_nullable_to_non_nullable
                      as int,
            rewardPoints: null == rewardPoints
                ? _value.rewardPoints
                : rewardPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            rewardGranted: null == rewardGranted
                ? _value.rewardGranted
                : rewardGranted // ignore: cast_nullable_to_non_nullable
                      as bool,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<DailyPlanItemDto>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyPlanDtoImplCopyWith<$Res>
    implements $DailyPlanDtoCopyWith<$Res> {
  factory _$$DailyPlanDtoImplCopyWith(
    _$DailyPlanDtoImpl value,
    $Res Function(_$DailyPlanDtoImpl) then,
  ) = __$$DailyPlanDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'PlanDate') String planDate,
    @JsonKey(name: 'Status') String status,
    @JsonKey(name: 'Source') String source,
    @JsonKey(name: 'IsPremiumPersonalized') bool isPremiumPersonalized,
    @JsonKey(name: 'TotalItems') int totalItems,
    @JsonKey(name: 'CompletedItems') int completedItems,
    @JsonKey(name: 'CompletedAt') DateTime? completedAt,
    @JsonKey(name: 'RewardStars') int rewardStars,
    @JsonKey(name: 'RewardPoints') int rewardPoints,
    @JsonKey(name: 'RewardGranted') bool rewardGranted,
    @JsonKey(name: 'Items') List<DailyPlanItemDto> items,
  });
}

/// @nodoc
class __$$DailyPlanDtoImplCopyWithImpl<$Res>
    extends _$DailyPlanDtoCopyWithImpl<$Res, _$DailyPlanDtoImpl>
    implements _$$DailyPlanDtoImplCopyWith<$Res> {
  __$$DailyPlanDtoImplCopyWithImpl(
    _$DailyPlanDtoImpl _value,
    $Res Function(_$DailyPlanDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlanDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planDate = null,
    Object? status = null,
    Object? source = null,
    Object? isPremiumPersonalized = null,
    Object? totalItems = null,
    Object? completedItems = null,
    Object? completedAt = freezed,
    Object? rewardStars = null,
    Object? rewardPoints = null,
    Object? rewardGranted = null,
    Object? items = null,
  }) {
    return _then(
      _$DailyPlanDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        planDate: null == planDate
            ? _value.planDate
            : planDate // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        isPremiumPersonalized: null == isPremiumPersonalized
            ? _value.isPremiumPersonalized
            : isPremiumPersonalized // ignore: cast_nullable_to_non_nullable
                  as bool,
        totalItems: null == totalItems
            ? _value.totalItems
            : totalItems // ignore: cast_nullable_to_non_nullable
                  as int,
        completedItems: null == completedItems
            ? _value.completedItems
            : completedItems // ignore: cast_nullable_to_non_nullable
                  as int,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        rewardStars: null == rewardStars
            ? _value.rewardStars
            : rewardStars // ignore: cast_nullable_to_non_nullable
                  as int,
        rewardPoints: null == rewardPoints
            ? _value.rewardPoints
            : rewardPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        rewardGranted: null == rewardGranted
            ? _value.rewardGranted
            : rewardGranted // ignore: cast_nullable_to_non_nullable
                  as bool,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<DailyPlanItemDto>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanDtoImpl implements _DailyPlanDto {
  const _$DailyPlanDtoImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'PlanDate') required this.planDate,
    @JsonKey(name: 'Status') required this.status,
    @JsonKey(name: 'Source') required this.source,
    @JsonKey(name: 'IsPremiumPersonalized') this.isPremiumPersonalized = false,
    @JsonKey(name: 'TotalItems') this.totalItems = 0,
    @JsonKey(name: 'CompletedItems') this.completedItems = 0,
    @JsonKey(name: 'CompletedAt') this.completedAt,
    @JsonKey(name: 'RewardStars') this.rewardStars = 0,
    @JsonKey(name: 'RewardPoints') this.rewardPoints = 0,
    @JsonKey(name: 'RewardGranted') this.rewardGranted = false,
    @JsonKey(name: 'Items')
    final List<DailyPlanItemDto> items = const <DailyPlanItemDto>[],
  }) : _items = items;

  factory _$DailyPlanDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'PlanDate')
  final String planDate;
  @override
  @JsonKey(name: 'Status')
  final String status;
  @override
  @JsonKey(name: 'Source')
  final String source;
  @override
  @JsonKey(name: 'IsPremiumPersonalized')
  final bool isPremiumPersonalized;
  @override
  @JsonKey(name: 'TotalItems')
  final int totalItems;
  @override
  @JsonKey(name: 'CompletedItems')
  final int completedItems;
  @override
  @JsonKey(name: 'CompletedAt')
  final DateTime? completedAt;
  @override
  @JsonKey(name: 'RewardStars')
  final int rewardStars;
  @override
  @JsonKey(name: 'RewardPoints')
  final int rewardPoints;
  @override
  @JsonKey(name: 'RewardGranted')
  final bool rewardGranted;
  final List<DailyPlanItemDto> _items;
  @override
  @JsonKey(name: 'Items')
  List<DailyPlanItemDto> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'DailyPlanDto(id: $id, planDate: $planDate, status: $status, source: $source, isPremiumPersonalized: $isPremiumPersonalized, totalItems: $totalItems, completedItems: $completedItems, completedAt: $completedAt, rewardStars: $rewardStars, rewardPoints: $rewardPoints, rewardGranted: $rewardGranted, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planDate, planDate) ||
                other.planDate == planDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.isPremiumPersonalized, isPremiumPersonalized) ||
                other.isPremiumPersonalized == isPremiumPersonalized) &&
            (identical(other.totalItems, totalItems) ||
                other.totalItems == totalItems) &&
            (identical(other.completedItems, completedItems) ||
                other.completedItems == completedItems) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.rewardStars, rewardStars) ||
                other.rewardStars == rewardStars) &&
            (identical(other.rewardPoints, rewardPoints) ||
                other.rewardPoints == rewardPoints) &&
            (identical(other.rewardGranted, rewardGranted) ||
                other.rewardGranted == rewardGranted) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    planDate,
    status,
    source,
    isPremiumPersonalized,
    totalItems,
    completedItems,
    completedAt,
    rewardStars,
    rewardPoints,
    rewardGranted,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of DailyPlanDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanDtoImplCopyWith<_$DailyPlanDtoImpl> get copyWith =>
      __$$DailyPlanDtoImplCopyWithImpl<_$DailyPlanDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanDtoImplToJson(this);
  }
}

abstract class _DailyPlanDto implements DailyPlanDto {
  const factory _DailyPlanDto({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'PlanDate') required final String planDate,
    @JsonKey(name: 'Status') required final String status,
    @JsonKey(name: 'Source') required final String source,
    @JsonKey(name: 'IsPremiumPersonalized') final bool isPremiumPersonalized,
    @JsonKey(name: 'TotalItems') final int totalItems,
    @JsonKey(name: 'CompletedItems') final int completedItems,
    @JsonKey(name: 'CompletedAt') final DateTime? completedAt,
    @JsonKey(name: 'RewardStars') final int rewardStars,
    @JsonKey(name: 'RewardPoints') final int rewardPoints,
    @JsonKey(name: 'RewardGranted') final bool rewardGranted,
    @JsonKey(name: 'Items') final List<DailyPlanItemDto> items,
  }) = _$DailyPlanDtoImpl;

  factory _DailyPlanDto.fromJson(Map<String, dynamic> json) =
      _$DailyPlanDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'PlanDate')
  String get planDate;
  @override
  @JsonKey(name: 'Status')
  String get status;
  @override
  @JsonKey(name: 'Source')
  String get source;
  @override
  @JsonKey(name: 'IsPremiumPersonalized')
  bool get isPremiumPersonalized;
  @override
  @JsonKey(name: 'TotalItems')
  int get totalItems;
  @override
  @JsonKey(name: 'CompletedItems')
  int get completedItems;
  @override
  @JsonKey(name: 'CompletedAt')
  DateTime? get completedAt;
  @override
  @JsonKey(name: 'RewardStars')
  int get rewardStars;
  @override
  @JsonKey(name: 'RewardPoints')
  int get rewardPoints;
  @override
  @JsonKey(name: 'RewardGranted')
  bool get rewardGranted;
  @override
  @JsonKey(name: 'Items')
  List<DailyPlanItemDto> get items;

  /// Create a copy of DailyPlanDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanDtoImplCopyWith<_$DailyPlanDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyPlanItemDto _$DailyPlanItemDtoFromJson(Map<String, dynamic> json) {
  return _DailyPlanItemDto.fromJson(json);
}

/// @nodoc
mixin _$DailyPlanItemDto {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Order')
  int get order => throw _privateConstructorUsedError;
  @JsonKey(name: 'ActivityType')
  String get activityType => throw _privateConstructorUsedError;
  @JsonKey(name: 'Title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'RouteKey')
  String? get routeKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'TargetCount')
  int get targetCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsCompleted')
  bool get isCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'CompletedAt')
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this DailyPlanItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyPlanItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyPlanItemDtoCopyWith<DailyPlanItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyPlanItemDtoCopyWith<$Res> {
  factory $DailyPlanItemDtoCopyWith(
    DailyPlanItemDto value,
    $Res Function(DailyPlanItemDto) then,
  ) = _$DailyPlanItemDtoCopyWithImpl<$Res, DailyPlanItemDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Order') int order,
    @JsonKey(name: 'ActivityType') String activityType,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'RouteKey') String? routeKey,
    @JsonKey(name: 'TargetCount') int targetCount,
    @JsonKey(name: 'IsCompleted') bool isCompleted,
    @JsonKey(name: 'CompletedAt') DateTime? completedAt,
  });
}

/// @nodoc
class _$DailyPlanItemDtoCopyWithImpl<$Res, $Val extends DailyPlanItemDto>
    implements $DailyPlanItemDtoCopyWith<$Res> {
  _$DailyPlanItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyPlanItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = null,
    Object? activityType = null,
    Object? title = null,
    Object? routeKey = freezed,
    Object? targetCount = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            activityType: null == activityType
                ? _value.activityType
                : activityType // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            routeKey: freezed == routeKey
                ? _value.routeKey
                : routeKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetCount: null == targetCount
                ? _value.targetCount
                : targetCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyPlanItemDtoImplCopyWith<$Res>
    implements $DailyPlanItemDtoCopyWith<$Res> {
  factory _$$DailyPlanItemDtoImplCopyWith(
    _$DailyPlanItemDtoImpl value,
    $Res Function(_$DailyPlanItemDtoImpl) then,
  ) = __$$DailyPlanItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Order') int order,
    @JsonKey(name: 'ActivityType') String activityType,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'RouteKey') String? routeKey,
    @JsonKey(name: 'TargetCount') int targetCount,
    @JsonKey(name: 'IsCompleted') bool isCompleted,
    @JsonKey(name: 'CompletedAt') DateTime? completedAt,
  });
}

/// @nodoc
class __$$DailyPlanItemDtoImplCopyWithImpl<$Res>
    extends _$DailyPlanItemDtoCopyWithImpl<$Res, _$DailyPlanItemDtoImpl>
    implements _$$DailyPlanItemDtoImplCopyWith<$Res> {
  __$$DailyPlanItemDtoImplCopyWithImpl(
    _$DailyPlanItemDtoImpl _value,
    $Res Function(_$DailyPlanItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyPlanItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = null,
    Object? activityType = null,
    Object? title = null,
    Object? routeKey = freezed,
    Object? targetCount = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$DailyPlanItemDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        activityType: null == activityType
            ? _value.activityType
            : activityType // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        routeKey: freezed == routeKey
            ? _value.routeKey
            : routeKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetCount: null == targetCount
            ? _value.targetCount
            : targetCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyPlanItemDtoImpl implements _DailyPlanItemDto {
  const _$DailyPlanItemDtoImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'Order') required this.order,
    @JsonKey(name: 'ActivityType') required this.activityType,
    @JsonKey(name: 'Title') required this.title,
    @JsonKey(name: 'RouteKey') this.routeKey,
    @JsonKey(name: 'TargetCount') this.targetCount = 0,
    @JsonKey(name: 'IsCompleted') this.isCompleted = false,
    @JsonKey(name: 'CompletedAt') this.completedAt,
  });

  factory _$DailyPlanItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyPlanItemDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'Order')
  final int order;
  @override
  @JsonKey(name: 'ActivityType')
  final String activityType;
  @override
  @JsonKey(name: 'Title')
  final String title;
  @override
  @JsonKey(name: 'RouteKey')
  final String? routeKey;
  @override
  @JsonKey(name: 'TargetCount')
  final int targetCount;
  @override
  @JsonKey(name: 'IsCompleted')
  final bool isCompleted;
  @override
  @JsonKey(name: 'CompletedAt')
  final DateTime? completedAt;

  @override
  String toString() {
    return 'DailyPlanItemDto(id: $id, order: $order, activityType: $activityType, title: $title, routeKey: $routeKey, targetCount: $targetCount, isCompleted: $isCompleted, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyPlanItemDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.routeKey, routeKey) ||
                other.routeKey == routeKey) &&
            (identical(other.targetCount, targetCount) ||
                other.targetCount == targetCount) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    order,
    activityType,
    title,
    routeKey,
    targetCount,
    isCompleted,
    completedAt,
  );

  /// Create a copy of DailyPlanItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyPlanItemDtoImplCopyWith<_$DailyPlanItemDtoImpl> get copyWith =>
      __$$DailyPlanItemDtoImplCopyWithImpl<_$DailyPlanItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyPlanItemDtoImplToJson(this);
  }
}

abstract class _DailyPlanItemDto implements DailyPlanItemDto {
  const factory _DailyPlanItemDto({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'Order') required final int order,
    @JsonKey(name: 'ActivityType') required final String activityType,
    @JsonKey(name: 'Title') required final String title,
    @JsonKey(name: 'RouteKey') final String? routeKey,
    @JsonKey(name: 'TargetCount') final int targetCount,
    @JsonKey(name: 'IsCompleted') final bool isCompleted,
    @JsonKey(name: 'CompletedAt') final DateTime? completedAt,
  }) = _$DailyPlanItemDtoImpl;

  factory _DailyPlanItemDto.fromJson(Map<String, dynamic> json) =
      _$DailyPlanItemDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'Order')
  int get order;
  @override
  @JsonKey(name: 'ActivityType')
  String get activityType;
  @override
  @JsonKey(name: 'Title')
  String get title;
  @override
  @JsonKey(name: 'RouteKey')
  String? get routeKey;
  @override
  @JsonKey(name: 'TargetCount')
  int get targetCount;
  @override
  @JsonKey(name: 'IsCompleted')
  bool get isCompleted;
  @override
  @JsonKey(name: 'CompletedAt')
  DateTime? get completedAt;

  /// Create a copy of DailyPlanItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyPlanItemDtoImplCopyWith<_$DailyPlanItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

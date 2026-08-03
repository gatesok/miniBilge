// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entertainment_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EntertainmentStats _$EntertainmentStatsFromJson(Map<String, dynamic> json) {
  return _EntertainmentStats.fromJson(json);
}

/// @nodoc
mixin _$EntertainmentStats {
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalPlayed')
  int get totalPlayed => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalWon')
  int get totalWon => throw _privateConstructorUsedError;
  @JsonKey(name: 'PerfectWins')
  int get perfectWins => throw _privateConstructorUsedError;
  @JsonKey(name: 'AverageSuccessRate')
  double get averageSuccessRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'Categories')
  List<EntertainmentCategoryStat> get categories =>
      throw _privateConstructorUsedError;

  /// Serializes this EntertainmentStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EntertainmentStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntertainmentStatsCopyWith<EntertainmentStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntertainmentStatsCopyWith<$Res> {
  factory $EntertainmentStatsCopyWith(
    EntertainmentStats value,
    $Res Function(EntertainmentStats) then,
  ) = _$EntertainmentStatsCopyWithImpl<$Res, EntertainmentStats>;
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'TotalPlayed') int totalPlayed,
    @JsonKey(name: 'TotalWon') int totalWon,
    @JsonKey(name: 'PerfectWins') int perfectWins,
    @JsonKey(name: 'AverageSuccessRate') double averageSuccessRate,
    @JsonKey(name: 'Categories') List<EntertainmentCategoryStat> categories,
  });
}

/// @nodoc
class _$EntertainmentStatsCopyWithImpl<$Res, $Val extends EntertainmentStats>
    implements $EntertainmentStatsCopyWith<$Res> {
  _$EntertainmentStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EntertainmentStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? totalPlayed = null,
    Object? totalWon = null,
    Object? perfectWins = null,
    Object? averageSuccessRate = null,
    Object? categories = null,
  }) {
    return _then(
      _value.copyWith(
            childId: null == childId
                ? _value.childId
                : childId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalPlayed: null == totalPlayed
                ? _value.totalPlayed
                : totalPlayed // ignore: cast_nullable_to_non_nullable
                      as int,
            totalWon: null == totalWon
                ? _value.totalWon
                : totalWon // ignore: cast_nullable_to_non_nullable
                      as int,
            perfectWins: null == perfectWins
                ? _value.perfectWins
                : perfectWins // ignore: cast_nullable_to_non_nullable
                      as int,
            averageSuccessRate: null == averageSuccessRate
                ? _value.averageSuccessRate
                : averageSuccessRate // ignore: cast_nullable_to_non_nullable
                      as double,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<EntertainmentCategoryStat>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EntertainmentStatsImplCopyWith<$Res>
    implements $EntertainmentStatsCopyWith<$Res> {
  factory _$$EntertainmentStatsImplCopyWith(
    _$EntertainmentStatsImpl value,
    $Res Function(_$EntertainmentStatsImpl) then,
  ) = __$$EntertainmentStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'TotalPlayed') int totalPlayed,
    @JsonKey(name: 'TotalWon') int totalWon,
    @JsonKey(name: 'PerfectWins') int perfectWins,
    @JsonKey(name: 'AverageSuccessRate') double averageSuccessRate,
    @JsonKey(name: 'Categories') List<EntertainmentCategoryStat> categories,
  });
}

/// @nodoc
class __$$EntertainmentStatsImplCopyWithImpl<$Res>
    extends _$EntertainmentStatsCopyWithImpl<$Res, _$EntertainmentStatsImpl>
    implements _$$EntertainmentStatsImplCopyWith<$Res> {
  __$$EntertainmentStatsImplCopyWithImpl(
    _$EntertainmentStatsImpl _value,
    $Res Function(_$EntertainmentStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EntertainmentStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? totalPlayed = null,
    Object? totalWon = null,
    Object? perfectWins = null,
    Object? averageSuccessRate = null,
    Object? categories = null,
  }) {
    return _then(
      _$EntertainmentStatsImpl(
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalPlayed: null == totalPlayed
            ? _value.totalPlayed
            : totalPlayed // ignore: cast_nullable_to_non_nullable
                  as int,
        totalWon: null == totalWon
            ? _value.totalWon
            : totalWon // ignore: cast_nullable_to_non_nullable
                  as int,
        perfectWins: null == perfectWins
            ? _value.perfectWins
            : perfectWins // ignore: cast_nullable_to_non_nullable
                  as int,
        averageSuccessRate: null == averageSuccessRate
            ? _value.averageSuccessRate
            : averageSuccessRate // ignore: cast_nullable_to_non_nullable
                  as double,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<EntertainmentCategoryStat>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EntertainmentStatsImpl implements _EntertainmentStats {
  const _$EntertainmentStatsImpl({
    @JsonKey(name: 'ChildId') required this.childId,
    @JsonKey(name: 'TotalPlayed') required this.totalPlayed,
    @JsonKey(name: 'TotalWon') required this.totalWon,
    @JsonKey(name: 'PerfectWins') required this.perfectWins,
    @JsonKey(name: 'AverageSuccessRate') required this.averageSuccessRate,
    @JsonKey(name: 'Categories')
    final List<EntertainmentCategoryStat> categories =
        const <EntertainmentCategoryStat>[],
  }) : _categories = categories;

  factory _$EntertainmentStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntertainmentStatsImplFromJson(json);

  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'TotalPlayed')
  final int totalPlayed;
  @override
  @JsonKey(name: 'TotalWon')
  final int totalWon;
  @override
  @JsonKey(name: 'PerfectWins')
  final int perfectWins;
  @override
  @JsonKey(name: 'AverageSuccessRate')
  final double averageSuccessRate;
  final List<EntertainmentCategoryStat> _categories;
  @override
  @JsonKey(name: 'Categories')
  List<EntertainmentCategoryStat> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  String toString() {
    return 'EntertainmentStats(childId: $childId, totalPlayed: $totalPlayed, totalWon: $totalWon, perfectWins: $perfectWins, averageSuccessRate: $averageSuccessRate, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntertainmentStatsImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.totalPlayed, totalPlayed) ||
                other.totalPlayed == totalPlayed) &&
            (identical(other.totalWon, totalWon) ||
                other.totalWon == totalWon) &&
            (identical(other.perfectWins, perfectWins) ||
                other.perfectWins == perfectWins) &&
            (identical(other.averageSuccessRate, averageSuccessRate) ||
                other.averageSuccessRate == averageSuccessRate) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    childId,
    totalPlayed,
    totalWon,
    perfectWins,
    averageSuccessRate,
    const DeepCollectionEquality().hash(_categories),
  );

  /// Create a copy of EntertainmentStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntertainmentStatsImplCopyWith<_$EntertainmentStatsImpl> get copyWith =>
      __$$EntertainmentStatsImplCopyWithImpl<_$EntertainmentStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EntertainmentStatsImplToJson(this);
  }
}

abstract class _EntertainmentStats implements EntertainmentStats {
  const factory _EntertainmentStats({
    @JsonKey(name: 'ChildId') required final String childId,
    @JsonKey(name: 'TotalPlayed') required final int totalPlayed,
    @JsonKey(name: 'TotalWon') required final int totalWon,
    @JsonKey(name: 'PerfectWins') required final int perfectWins,
    @JsonKey(name: 'AverageSuccessRate')
    required final double averageSuccessRate,
    @JsonKey(name: 'Categories')
    final List<EntertainmentCategoryStat> categories,
  }) = _$EntertainmentStatsImpl;

  factory _EntertainmentStats.fromJson(Map<String, dynamic> json) =
      _$EntertainmentStatsImpl.fromJson;

  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'TotalPlayed')
  int get totalPlayed;
  @override
  @JsonKey(name: 'TotalWon')
  int get totalWon;
  @override
  @JsonKey(name: 'PerfectWins')
  int get perfectWins;
  @override
  @JsonKey(name: 'AverageSuccessRate')
  double get averageSuccessRate;
  @override
  @JsonKey(name: 'Categories')
  List<EntertainmentCategoryStat> get categories;

  /// Create a copy of EntertainmentStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntertainmentStatsImplCopyWith<_$EntertainmentStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EntertainmentCategoryStat _$EntertainmentCategoryStatFromJson(
  Map<String, dynamic> json,
) {
  return _EntertainmentCategoryStat.fromJson(json);
}

/// @nodoc
mixin _$EntertainmentCategoryStat {
  @JsonKey(name: 'CategoryKey')
  String get categoryKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'CategoryName')
  String get categoryName => throw _privateConstructorUsedError;
  @JsonKey(name: 'Played')
  int get played => throw _privateConstructorUsedError;
  @JsonKey(name: 'Won')
  int get won => throw _privateConstructorUsedError;
  @JsonKey(name: 'AverageSuccessRate')
  double get averageSuccessRate => throw _privateConstructorUsedError;

  /// Serializes this EntertainmentCategoryStat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EntertainmentCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntertainmentCategoryStatCopyWith<EntertainmentCategoryStat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntertainmentCategoryStatCopyWith<$Res> {
  factory $EntertainmentCategoryStatCopyWith(
    EntertainmentCategoryStat value,
    $Res Function(EntertainmentCategoryStat) then,
  ) = _$EntertainmentCategoryStatCopyWithImpl<$Res, EntertainmentCategoryStat>;
  @useResult
  $Res call({
    @JsonKey(name: 'CategoryKey') String categoryKey,
    @JsonKey(name: 'CategoryName') String categoryName,
    @JsonKey(name: 'Played') int played,
    @JsonKey(name: 'Won') int won,
    @JsonKey(name: 'AverageSuccessRate') double averageSuccessRate,
  });
}

/// @nodoc
class _$EntertainmentCategoryStatCopyWithImpl<
  $Res,
  $Val extends EntertainmentCategoryStat
>
    implements $EntertainmentCategoryStatCopyWith<$Res> {
  _$EntertainmentCategoryStatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EntertainmentCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryKey = null,
    Object? categoryName = null,
    Object? played = null,
    Object? won = null,
    Object? averageSuccessRate = null,
  }) {
    return _then(
      _value.copyWith(
            categoryKey: null == categoryKey
                ? _value.categoryKey
                : categoryKey // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            played: null == played
                ? _value.played
                : played // ignore: cast_nullable_to_non_nullable
                      as int,
            won: null == won
                ? _value.won
                : won // ignore: cast_nullable_to_non_nullable
                      as int,
            averageSuccessRate: null == averageSuccessRate
                ? _value.averageSuccessRate
                : averageSuccessRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EntertainmentCategoryStatImplCopyWith<$Res>
    implements $EntertainmentCategoryStatCopyWith<$Res> {
  factory _$$EntertainmentCategoryStatImplCopyWith(
    _$EntertainmentCategoryStatImpl value,
    $Res Function(_$EntertainmentCategoryStatImpl) then,
  ) = __$$EntertainmentCategoryStatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'CategoryKey') String categoryKey,
    @JsonKey(name: 'CategoryName') String categoryName,
    @JsonKey(name: 'Played') int played,
    @JsonKey(name: 'Won') int won,
    @JsonKey(name: 'AverageSuccessRate') double averageSuccessRate,
  });
}

/// @nodoc
class __$$EntertainmentCategoryStatImplCopyWithImpl<$Res>
    extends
        _$EntertainmentCategoryStatCopyWithImpl<
          $Res,
          _$EntertainmentCategoryStatImpl
        >
    implements _$$EntertainmentCategoryStatImplCopyWith<$Res> {
  __$$EntertainmentCategoryStatImplCopyWithImpl(
    _$EntertainmentCategoryStatImpl _value,
    $Res Function(_$EntertainmentCategoryStatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EntertainmentCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryKey = null,
    Object? categoryName = null,
    Object? played = null,
    Object? won = null,
    Object? averageSuccessRate = null,
  }) {
    return _then(
      _$EntertainmentCategoryStatImpl(
        categoryKey: null == categoryKey
            ? _value.categoryKey
            : categoryKey // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        played: null == played
            ? _value.played
            : played // ignore: cast_nullable_to_non_nullable
                  as int,
        won: null == won
            ? _value.won
            : won // ignore: cast_nullable_to_non_nullable
                  as int,
        averageSuccessRate: null == averageSuccessRate
            ? _value.averageSuccessRate
            : averageSuccessRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EntertainmentCategoryStatImpl implements _EntertainmentCategoryStat {
  const _$EntertainmentCategoryStatImpl({
    @JsonKey(name: 'CategoryKey') required this.categoryKey,
    @JsonKey(name: 'CategoryName') required this.categoryName,
    @JsonKey(name: 'Played') required this.played,
    @JsonKey(name: 'Won') required this.won,
    @JsonKey(name: 'AverageSuccessRate') required this.averageSuccessRate,
  });

  factory _$EntertainmentCategoryStatImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntertainmentCategoryStatImplFromJson(json);

  @override
  @JsonKey(name: 'CategoryKey')
  final String categoryKey;
  @override
  @JsonKey(name: 'CategoryName')
  final String categoryName;
  @override
  @JsonKey(name: 'Played')
  final int played;
  @override
  @JsonKey(name: 'Won')
  final int won;
  @override
  @JsonKey(name: 'AverageSuccessRate')
  final double averageSuccessRate;

  @override
  String toString() {
    return 'EntertainmentCategoryStat(categoryKey: $categoryKey, categoryName: $categoryName, played: $played, won: $won, averageSuccessRate: $averageSuccessRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntertainmentCategoryStatImpl &&
            (identical(other.categoryKey, categoryKey) ||
                other.categoryKey == categoryKey) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.played, played) || other.played == played) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.averageSuccessRate, averageSuccessRate) ||
                other.averageSuccessRate == averageSuccessRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryKey,
    categoryName,
    played,
    won,
    averageSuccessRate,
  );

  /// Create a copy of EntertainmentCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntertainmentCategoryStatImplCopyWith<_$EntertainmentCategoryStatImpl>
  get copyWith =>
      __$$EntertainmentCategoryStatImplCopyWithImpl<
        _$EntertainmentCategoryStatImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntertainmentCategoryStatImplToJson(this);
  }
}

abstract class _EntertainmentCategoryStat implements EntertainmentCategoryStat {
  const factory _EntertainmentCategoryStat({
    @JsonKey(name: 'CategoryKey') required final String categoryKey,
    @JsonKey(name: 'CategoryName') required final String categoryName,
    @JsonKey(name: 'Played') required final int played,
    @JsonKey(name: 'Won') required final int won,
    @JsonKey(name: 'AverageSuccessRate')
    required final double averageSuccessRate,
  }) = _$EntertainmentCategoryStatImpl;

  factory _EntertainmentCategoryStat.fromJson(Map<String, dynamic> json) =
      _$EntertainmentCategoryStatImpl.fromJson;

  @override
  @JsonKey(name: 'CategoryKey')
  String get categoryKey;
  @override
  @JsonKey(name: 'CategoryName')
  String get categoryName;
  @override
  @JsonKey(name: 'Played')
  int get played;
  @override
  @JsonKey(name: 'Won')
  int get won;
  @override
  @JsonKey(name: 'AverageSuccessRate')
  double get averageSuccessRate;

  /// Create a copy of EntertainmentCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntertainmentCategoryStatImplCopyWith<_$EntertainmentCategoryStatImpl>
  get copyWith => throw _privateConstructorUsedError;
}

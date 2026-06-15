// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatchRequest _$MatchRequestFromJson(Map<String, dynamic> json) {
  return _MatchRequest.fromJson(json);
}

/// @nodoc
mixin _$MatchRequest {
  String get id => throw _privateConstructorUsedError;
  String get childProfileId => throw _privateConstructorUsedError;
  MatchRequestStatus get status => throw _privateConstructorUsedError;
  DateTime get requestedAt => throw _privateConstructorUsedError;
  DateTime? get matchedAt => throw _privateConstructorUsedError;
  String? get matchSessionId => throw _privateConstructorUsedError;

  /// Serializes this MatchRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchRequestCopyWith<MatchRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchRequestCopyWith<$Res> {
  factory $MatchRequestCopyWith(
    MatchRequest value,
    $Res Function(MatchRequest) then,
  ) = _$MatchRequestCopyWithImpl<$Res, MatchRequest>;
  @useResult
  $Res call({
    String id,
    String childProfileId,
    MatchRequestStatus status,
    DateTime requestedAt,
    DateTime? matchedAt,
    String? matchSessionId,
  });
}

/// @nodoc
class _$MatchRequestCopyWithImpl<$Res, $Val extends MatchRequest>
    implements $MatchRequestCopyWith<$Res> {
  _$MatchRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childProfileId = null,
    Object? status = null,
    Object? requestedAt = null,
    Object? matchedAt = freezed,
    Object? matchSessionId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            childProfileId: null == childProfileId
                ? _value.childProfileId
                : childProfileId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MatchRequestStatus,
            requestedAt: null == requestedAt
                ? _value.requestedAt
                : requestedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            matchedAt: freezed == matchedAt
                ? _value.matchedAt
                : matchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            matchSessionId: freezed == matchSessionId
                ? _value.matchSessionId
                : matchSessionId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchRequestImplCopyWith<$Res>
    implements $MatchRequestCopyWith<$Res> {
  factory _$$MatchRequestImplCopyWith(
    _$MatchRequestImpl value,
    $Res Function(_$MatchRequestImpl) then,
  ) = __$$MatchRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String childProfileId,
    MatchRequestStatus status,
    DateTime requestedAt,
    DateTime? matchedAt,
    String? matchSessionId,
  });
}

/// @nodoc
class __$$MatchRequestImplCopyWithImpl<$Res>
    extends _$MatchRequestCopyWithImpl<$Res, _$MatchRequestImpl>
    implements _$$MatchRequestImplCopyWith<$Res> {
  __$$MatchRequestImplCopyWithImpl(
    _$MatchRequestImpl _value,
    $Res Function(_$MatchRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childProfileId = null,
    Object? status = null,
    Object? requestedAt = null,
    Object? matchedAt = freezed,
    Object? matchSessionId = freezed,
  }) {
    return _then(
      _$MatchRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        childProfileId: null == childProfileId
            ? _value.childProfileId
            : childProfileId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MatchRequestStatus,
        requestedAt: null == requestedAt
            ? _value.requestedAt
            : requestedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        matchedAt: freezed == matchedAt
            ? _value.matchedAt
            : matchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        matchSessionId: freezed == matchSessionId
            ? _value.matchSessionId
            : matchSessionId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchRequestImpl implements _MatchRequest {
  const _$MatchRequestImpl({
    required this.id,
    required this.childProfileId,
    required this.status,
    required this.requestedAt,
    this.matchedAt,
    this.matchSessionId,
  });

  factory _$MatchRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String childProfileId;
  @override
  final MatchRequestStatus status;
  @override
  final DateTime requestedAt;
  @override
  final DateTime? matchedAt;
  @override
  final String? matchSessionId;

  @override
  String toString() {
    return 'MatchRequest(id: $id, childProfileId: $childProfileId, status: $status, requestedAt: $requestedAt, matchedAt: $matchedAt, matchSessionId: $matchSessionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childProfileId, childProfileId) ||
                other.childProfileId == childProfileId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.matchedAt, matchedAt) ||
                other.matchedAt == matchedAt) &&
            (identical(other.matchSessionId, matchSessionId) ||
                other.matchSessionId == matchSessionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    childProfileId,
    status,
    requestedAt,
    matchedAt,
    matchSessionId,
  );

  /// Create a copy of MatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchRequestImplCopyWith<_$MatchRequestImpl> get copyWith =>
      __$$MatchRequestImplCopyWithImpl<_$MatchRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchRequestImplToJson(this);
  }
}

abstract class _MatchRequest implements MatchRequest {
  const factory _MatchRequest({
    required final String id,
    required final String childProfileId,
    required final MatchRequestStatus status,
    required final DateTime requestedAt,
    final DateTime? matchedAt,
    final String? matchSessionId,
  }) = _$MatchRequestImpl;

  factory _MatchRequest.fromJson(Map<String, dynamic> json) =
      _$MatchRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get childProfileId;
  @override
  MatchRequestStatus get status;
  @override
  DateTime get requestedAt;
  @override
  DateTime? get matchedAt;
  @override
  String? get matchSessionId;

  /// Create a copy of MatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchRequestImplCopyWith<_$MatchRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchSession _$MatchSessionFromJson(Map<String, dynamic> json) {
  return _MatchSession.fromJson(json);
}

/// @nodoc
mixin _$MatchSession {
  String get id => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  MatchSessionStatus get status => throw _privateConstructorUsedError;
  String? get winnerId => throw _privateConstructorUsedError;
  List<MatchParticipant> get participants => throw _privateConstructorUsedError;
  List<MatchQuestion> get questions => throw _privateConstructorUsedError;

  /// Serializes this MatchSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchSessionCopyWith<MatchSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchSessionCopyWith<$Res> {
  factory $MatchSessionCopyWith(
    MatchSession value,
    $Res Function(MatchSession) then,
  ) = _$MatchSessionCopyWithImpl<$Res, MatchSession>;
  @useResult
  $Res call({
    String id,
    DateTime startedAt,
    DateTime? endedAt,
    MatchSessionStatus status,
    String? winnerId,
    List<MatchParticipant> participants,
    List<MatchQuestion> questions,
  });
}

/// @nodoc
class _$MatchSessionCopyWithImpl<$Res, $Val extends MatchSession>
    implements $MatchSessionCopyWith<$Res> {
  _$MatchSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? status = null,
    Object? winnerId = freezed,
    Object? participants = null,
    Object? questions = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MatchSessionStatus,
            winnerId: freezed == winnerId
                ? _value.winnerId
                : winnerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            participants: null == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as List<MatchParticipant>,
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<MatchQuestion>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchSessionImplCopyWith<$Res>
    implements $MatchSessionCopyWith<$Res> {
  factory _$$MatchSessionImplCopyWith(
    _$MatchSessionImpl value,
    $Res Function(_$MatchSessionImpl) then,
  ) = __$$MatchSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime startedAt,
    DateTime? endedAt,
    MatchSessionStatus status,
    String? winnerId,
    List<MatchParticipant> participants,
    List<MatchQuestion> questions,
  });
}

/// @nodoc
class __$$MatchSessionImplCopyWithImpl<$Res>
    extends _$MatchSessionCopyWithImpl<$Res, _$MatchSessionImpl>
    implements _$$MatchSessionImplCopyWith<$Res> {
  __$$MatchSessionImplCopyWithImpl(
    _$MatchSessionImpl _value,
    $Res Function(_$MatchSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? status = null,
    Object? winnerId = freezed,
    Object? participants = null,
    Object? questions = null,
  }) {
    return _then(
      _$MatchSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MatchSessionStatus,
        winnerId: freezed == winnerId
            ? _value.winnerId
            : winnerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        participants: null == participants
            ? _value._participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as List<MatchParticipant>,
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<MatchQuestion>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchSessionImpl implements _MatchSession {
  const _$MatchSessionImpl({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.winnerId,
    required final List<MatchParticipant> participants,
    required final List<MatchQuestion> questions,
  }) : _participants = participants,
       _questions = questions;

  factory _$MatchSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchSessionImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final MatchSessionStatus status;
  @override
  final String? winnerId;
  final List<MatchParticipant> _participants;
  @override
  List<MatchParticipant> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  final List<MatchQuestion> _questions;
  @override
  List<MatchQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  String toString() {
    return 'MatchSession(id: $id, startedAt: $startedAt, endedAt: $endedAt, status: $status, winnerId: $winnerId, participants: $participants, questions: $questions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    startedAt,
    endedAt,
    status,
    winnerId,
    const DeepCollectionEquality().hash(_participants),
    const DeepCollectionEquality().hash(_questions),
  );

  /// Create a copy of MatchSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchSessionImplCopyWith<_$MatchSessionImpl> get copyWith =>
      __$$MatchSessionImplCopyWithImpl<_$MatchSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchSessionImplToJson(this);
  }
}

abstract class _MatchSession implements MatchSession {
  const factory _MatchSession({
    required final String id,
    required final DateTime startedAt,
    final DateTime? endedAt,
    required final MatchSessionStatus status,
    final String? winnerId,
    required final List<MatchParticipant> participants,
    required final List<MatchQuestion> questions,
  }) = _$MatchSessionImpl;

  factory _MatchSession.fromJson(Map<String, dynamic> json) =
      _$MatchSessionImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  MatchSessionStatus get status;
  @override
  String? get winnerId;
  @override
  List<MatchParticipant> get participants;
  @override
  List<MatchQuestion> get questions;

  /// Create a copy of MatchSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchSessionImplCopyWith<_$MatchSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchParticipant _$MatchParticipantFromJson(Map<String, dynamic> json) {
  return _MatchParticipant.fromJson(json);
}

/// @nodoc
mixin _$MatchParticipant {
  String get id => throw _privateConstructorUsedError;
  String get matchSessionId => throw _privateConstructorUsedError;
  String get childProfileId => throw _privateConstructorUsedError;
  String get childName => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  bool get isReady => throw _privateConstructorUsedError;
  int? get avatarId => throw _privateConstructorUsedError;

  /// Serializes this MatchParticipant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchParticipantCopyWith<MatchParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchParticipantCopyWith<$Res> {
  factory $MatchParticipantCopyWith(
    MatchParticipant value,
    $Res Function(MatchParticipant) then,
  ) = _$MatchParticipantCopyWithImpl<$Res, MatchParticipant>;
  @useResult
  $Res call({
    String id,
    String matchSessionId,
    String childProfileId,
    String childName,
    int score,
    DateTime joinedAt,
    bool isReady,
    int? avatarId,
  });
}

/// @nodoc
class _$MatchParticipantCopyWithImpl<$Res, $Val extends MatchParticipant>
    implements $MatchParticipantCopyWith<$Res> {
  _$MatchParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchSessionId = null,
    Object? childProfileId = null,
    Object? childName = null,
    Object? score = null,
    Object? joinedAt = null,
    Object? isReady = null,
    Object? avatarId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            matchSessionId: null == matchSessionId
                ? _value.matchSessionId
                : matchSessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            childProfileId: null == childProfileId
                ? _value.childProfileId
                : childProfileId // ignore: cast_nullable_to_non_nullable
                      as String,
            childName: null == childName
                ? _value.childName
                : childName // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isReady: null == isReady
                ? _value.isReady
                : isReady // ignore: cast_nullable_to_non_nullable
                      as bool,
            avatarId: freezed == avatarId
                ? _value.avatarId
                : avatarId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchParticipantImplCopyWith<$Res>
    implements $MatchParticipantCopyWith<$Res> {
  factory _$$MatchParticipantImplCopyWith(
    _$MatchParticipantImpl value,
    $Res Function(_$MatchParticipantImpl) then,
  ) = __$$MatchParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String matchSessionId,
    String childProfileId,
    String childName,
    int score,
    DateTime joinedAt,
    bool isReady,
    int? avatarId,
  });
}

/// @nodoc
class __$$MatchParticipantImplCopyWithImpl<$Res>
    extends _$MatchParticipantCopyWithImpl<$Res, _$MatchParticipantImpl>
    implements _$$MatchParticipantImplCopyWith<$Res> {
  __$$MatchParticipantImplCopyWithImpl(
    _$MatchParticipantImpl _value,
    $Res Function(_$MatchParticipantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchSessionId = null,
    Object? childProfileId = null,
    Object? childName = null,
    Object? score = null,
    Object? joinedAt = null,
    Object? isReady = null,
    Object? avatarId = freezed,
  }) {
    return _then(
      _$MatchParticipantImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        matchSessionId: null == matchSessionId
            ? _value.matchSessionId
            : matchSessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        childProfileId: null == childProfileId
            ? _value.childProfileId
            : childProfileId // ignore: cast_nullable_to_non_nullable
                  as String,
        childName: null == childName
            ? _value.childName
            : childName // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isReady: null == isReady
            ? _value.isReady
            : isReady // ignore: cast_nullable_to_non_nullable
                  as bool,
        avatarId: freezed == avatarId
            ? _value.avatarId
            : avatarId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchParticipantImpl implements _MatchParticipant {
  const _$MatchParticipantImpl({
    required this.id,
    required this.matchSessionId,
    required this.childProfileId,
    required this.childName,
    required this.score,
    required this.joinedAt,
    required this.isReady,
    this.avatarId,
  });

  factory _$MatchParticipantImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchParticipantImplFromJson(json);

  @override
  final String id;
  @override
  final String matchSessionId;
  @override
  final String childProfileId;
  @override
  final String childName;
  @override
  final int score;
  @override
  final DateTime joinedAt;
  @override
  final bool isReady;
  @override
  final int? avatarId;

  @override
  String toString() {
    return 'MatchParticipant(id: $id, matchSessionId: $matchSessionId, childProfileId: $childProfileId, childName: $childName, score: $score, joinedAt: $joinedAt, isReady: $isReady, avatarId: $avatarId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchParticipantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchSessionId, matchSessionId) ||
                other.matchSessionId == matchSessionId) &&
            (identical(other.childProfileId, childProfileId) ||
                other.childProfileId == childProfileId) &&
            (identical(other.childName, childName) ||
                other.childName == childName) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.avatarId, avatarId) ||
                other.avatarId == avatarId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    matchSessionId,
    childProfileId,
    childName,
    score,
    joinedAt,
    isReady,
    avatarId,
  );

  /// Create a copy of MatchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchParticipantImplCopyWith<_$MatchParticipantImpl> get copyWith =>
      __$$MatchParticipantImplCopyWithImpl<_$MatchParticipantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchParticipantImplToJson(this);
  }
}

abstract class _MatchParticipant implements MatchParticipant {
  const factory _MatchParticipant({
    required final String id,
    required final String matchSessionId,
    required final String childProfileId,
    required final String childName,
    required final int score,
    required final DateTime joinedAt,
    required final bool isReady,
    final int? avatarId,
  }) = _$MatchParticipantImpl;

  factory _MatchParticipant.fromJson(Map<String, dynamic> json) =
      _$MatchParticipantImpl.fromJson;

  @override
  String get id;
  @override
  String get matchSessionId;
  @override
  String get childProfileId;
  @override
  String get childName;
  @override
  int get score;
  @override
  DateTime get joinedAt;
  @override
  bool get isReady;
  @override
  int? get avatarId;

  /// Create a copy of MatchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchParticipantImplCopyWith<_$MatchParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchQuestion _$MatchQuestionFromJson(Map<String, dynamic> json) {
  return _MatchQuestion.fromJson(json);
}

/// @nodoc
mixin _$MatchQuestion {
  String get id => throw _privateConstructorUsedError;
  String get matchSessionId => throw _privateConstructorUsedError;
  String get questionId => throw _privateConstructorUsedError;
  int get questionOrder => throw _privateConstructorUsedError;
  String get questionText => throw _privateConstructorUsedError;
  String get correctAnswer => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;

  /// Serializes this MatchQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchQuestionCopyWith<MatchQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchQuestionCopyWith<$Res> {
  factory $MatchQuestionCopyWith(
    MatchQuestion value,
    $Res Function(MatchQuestion) then,
  ) = _$MatchQuestionCopyWithImpl<$Res, MatchQuestion>;
  @useResult
  $Res call({
    String id,
    String matchSessionId,
    String questionId,
    int questionOrder,
    String questionText,
    String correctAnswer,
    List<String> options,
  });
}

/// @nodoc
class _$MatchQuestionCopyWithImpl<$Res, $Val extends MatchQuestion>
    implements $MatchQuestionCopyWith<$Res> {
  _$MatchQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchSessionId = null,
    Object? questionId = null,
    Object? questionOrder = null,
    Object? questionText = null,
    Object? correctAnswer = null,
    Object? options = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            matchSessionId: null == matchSessionId
                ? _value.matchSessionId
                : matchSessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            questionId: null == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as String,
            questionOrder: null == questionOrder
                ? _value.questionOrder
                : questionOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            questionText: null == questionText
                ? _value.questionText
                : questionText // ignore: cast_nullable_to_non_nullable
                      as String,
            correctAnswer: null == correctAnswer
                ? _value.correctAnswer
                : correctAnswer // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchQuestionImplCopyWith<$Res>
    implements $MatchQuestionCopyWith<$Res> {
  factory _$$MatchQuestionImplCopyWith(
    _$MatchQuestionImpl value,
    $Res Function(_$MatchQuestionImpl) then,
  ) = __$$MatchQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String matchSessionId,
    String questionId,
    int questionOrder,
    String questionText,
    String correctAnswer,
    List<String> options,
  });
}

/// @nodoc
class __$$MatchQuestionImplCopyWithImpl<$Res>
    extends _$MatchQuestionCopyWithImpl<$Res, _$MatchQuestionImpl>
    implements _$$MatchQuestionImplCopyWith<$Res> {
  __$$MatchQuestionImplCopyWithImpl(
    _$MatchQuestionImpl _value,
    $Res Function(_$MatchQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchSessionId = null,
    Object? questionId = null,
    Object? questionOrder = null,
    Object? questionText = null,
    Object? correctAnswer = null,
    Object? options = null,
  }) {
    return _then(
      _$MatchQuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        matchSessionId: null == matchSessionId
            ? _value.matchSessionId
            : matchSessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        questionId: null == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as String,
        questionOrder: null == questionOrder
            ? _value.questionOrder
            : questionOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        questionText: null == questionText
            ? _value.questionText
            : questionText // ignore: cast_nullable_to_non_nullable
                  as String,
        correctAnswer: null == correctAnswer
            ? _value.correctAnswer
            : correctAnswer // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchQuestionImpl implements _MatchQuestion {
  const _$MatchQuestionImpl({
    required this.id,
    required this.matchSessionId,
    required this.questionId,
    required this.questionOrder,
    required this.questionText,
    required this.correctAnswer,
    required final List<String> options,
  }) : _options = options;

  factory _$MatchQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchQuestionImplFromJson(json);

  @override
  final String id;
  @override
  final String matchSessionId;
  @override
  final String questionId;
  @override
  final int questionOrder;
  @override
  final String questionText;
  @override
  final String correctAnswer;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'MatchQuestion(id: $id, matchSessionId: $matchSessionId, questionId: $questionId, questionOrder: $questionOrder, questionText: $questionText, correctAnswer: $correctAnswer, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchSessionId, matchSessionId) ||
                other.matchSessionId == matchSessionId) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.questionOrder, questionOrder) ||
                other.questionOrder == questionOrder) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    matchSessionId,
    questionId,
    questionOrder,
    questionText,
    correctAnswer,
    const DeepCollectionEquality().hash(_options),
  );

  /// Create a copy of MatchQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchQuestionImplCopyWith<_$MatchQuestionImpl> get copyWith =>
      __$$MatchQuestionImplCopyWithImpl<_$MatchQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchQuestionImplToJson(this);
  }
}

abstract class _MatchQuestion implements MatchQuestion {
  const factory _MatchQuestion({
    required final String id,
    required final String matchSessionId,
    required final String questionId,
    required final int questionOrder,
    required final String questionText,
    required final String correctAnswer,
    required final List<String> options,
  }) = _$MatchQuestionImpl;

  factory _MatchQuestion.fromJson(Map<String, dynamic> json) =
      _$MatchQuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get matchSessionId;
  @override
  String get questionId;
  @override
  int get questionOrder;
  @override
  String get questionText;
  @override
  String get correctAnswer;
  @override
  List<String> get options;

  /// Create a copy of MatchQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchQuestionImplCopyWith<_$MatchQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchAnswer _$MatchAnswerFromJson(Map<String, dynamic> json) {
  return _MatchAnswer.fromJson(json);
}

/// @nodoc
mixin _$MatchAnswer {
  String get id => throw _privateConstructorUsedError;
  String get matchSessionId => throw _privateConstructorUsedError;
  String get participantId => throw _privateConstructorUsedError;
  String get questionId => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  DateTime get answeredAt => throw _privateConstructorUsedError;
  int get pointsEarned => throw _privateConstructorUsedError;

  /// Serializes this MatchAnswer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchAnswerCopyWith<MatchAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchAnswerCopyWith<$Res> {
  factory $MatchAnswerCopyWith(
    MatchAnswer value,
    $Res Function(MatchAnswer) then,
  ) = _$MatchAnswerCopyWithImpl<$Res, MatchAnswer>;
  @useResult
  $Res call({
    String id,
    String matchSessionId,
    String participantId,
    String questionId,
    String answer,
    bool isCorrect,
    DateTime answeredAt,
    int pointsEarned,
  });
}

/// @nodoc
class _$MatchAnswerCopyWithImpl<$Res, $Val extends MatchAnswer>
    implements $MatchAnswerCopyWith<$Res> {
  _$MatchAnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchSessionId = null,
    Object? participantId = null,
    Object? questionId = null,
    Object? answer = null,
    Object? isCorrect = null,
    Object? answeredAt = null,
    Object? pointsEarned = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            matchSessionId: null == matchSessionId
                ? _value.matchSessionId
                : matchSessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            participantId: null == participantId
                ? _value.participantId
                : participantId // ignore: cast_nullable_to_non_nullable
                      as String,
            questionId: null == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as String,
            answer: null == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as String,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            answeredAt: null == answeredAt
                ? _value.answeredAt
                : answeredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            pointsEarned: null == pointsEarned
                ? _value.pointsEarned
                : pointsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchAnswerImplCopyWith<$Res>
    implements $MatchAnswerCopyWith<$Res> {
  factory _$$MatchAnswerImplCopyWith(
    _$MatchAnswerImpl value,
    $Res Function(_$MatchAnswerImpl) then,
  ) = __$$MatchAnswerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String matchSessionId,
    String participantId,
    String questionId,
    String answer,
    bool isCorrect,
    DateTime answeredAt,
    int pointsEarned,
  });
}

/// @nodoc
class __$$MatchAnswerImplCopyWithImpl<$Res>
    extends _$MatchAnswerCopyWithImpl<$Res, _$MatchAnswerImpl>
    implements _$$MatchAnswerImplCopyWith<$Res> {
  __$$MatchAnswerImplCopyWithImpl(
    _$MatchAnswerImpl _value,
    $Res Function(_$MatchAnswerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchSessionId = null,
    Object? participantId = null,
    Object? questionId = null,
    Object? answer = null,
    Object? isCorrect = null,
    Object? answeredAt = null,
    Object? pointsEarned = null,
  }) {
    return _then(
      _$MatchAnswerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        matchSessionId: null == matchSessionId
            ? _value.matchSessionId
            : matchSessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as String,
        questionId: null == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as String,
        answer: null == answer
            ? _value.answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as String,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        answeredAt: null == answeredAt
            ? _value.answeredAt
            : answeredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        pointsEarned: null == pointsEarned
            ? _value.pointsEarned
            : pointsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchAnswerImpl implements _MatchAnswer {
  const _$MatchAnswerImpl({
    required this.id,
    required this.matchSessionId,
    required this.participantId,
    required this.questionId,
    required this.answer,
    required this.isCorrect,
    required this.answeredAt,
    required this.pointsEarned,
  });

  factory _$MatchAnswerImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchAnswerImplFromJson(json);

  @override
  final String id;
  @override
  final String matchSessionId;
  @override
  final String participantId;
  @override
  final String questionId;
  @override
  final String answer;
  @override
  final bool isCorrect;
  @override
  final DateTime answeredAt;
  @override
  final int pointsEarned;

  @override
  String toString() {
    return 'MatchAnswer(id: $id, matchSessionId: $matchSessionId, participantId: $participantId, questionId: $questionId, answer: $answer, isCorrect: $isCorrect, answeredAt: $answeredAt, pointsEarned: $pointsEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchAnswerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchSessionId, matchSessionId) ||
                other.matchSessionId == matchSessionId) &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.answeredAt, answeredAt) ||
                other.answeredAt == answeredAt) &&
            (identical(other.pointsEarned, pointsEarned) ||
                other.pointsEarned == pointsEarned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    matchSessionId,
    participantId,
    questionId,
    answer,
    isCorrect,
    answeredAt,
    pointsEarned,
  );

  /// Create a copy of MatchAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchAnswerImplCopyWith<_$MatchAnswerImpl> get copyWith =>
      __$$MatchAnswerImplCopyWithImpl<_$MatchAnswerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchAnswerImplToJson(this);
  }
}

abstract class _MatchAnswer implements MatchAnswer {
  const factory _MatchAnswer({
    required final String id,
    required final String matchSessionId,
    required final String participantId,
    required final String questionId,
    required final String answer,
    required final bool isCorrect,
    required final DateTime answeredAt,
    required final int pointsEarned,
  }) = _$MatchAnswerImpl;

  factory _MatchAnswer.fromJson(Map<String, dynamic> json) =
      _$MatchAnswerImpl.fromJson;

  @override
  String get id;
  @override
  String get matchSessionId;
  @override
  String get participantId;
  @override
  String get questionId;
  @override
  String get answer;
  @override
  bool get isCorrect;
  @override
  DateTime get answeredAt;
  @override
  int get pointsEarned;

  /// Create a copy of MatchAnswer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchAnswerImplCopyWith<_$MatchAnswerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchStats _$MatchStatsFromJson(Map<String, dynamic> json) {
  return _MatchStats.fromJson(json);
}

/// @nodoc
mixin _$MatchStats {
  String get childId => throw _privateConstructorUsedError;
  int get gamesPlayed => throw _privateConstructorUsedError;
  int get gamesWon => throw _privateConstructorUsedError;
  int get gamesLost => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  double get averageScore => throw _privateConstructorUsedError;
  double get winRate => throw _privateConstructorUsedError;

  /// Serializes this MatchStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchStatsCopyWith<MatchStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchStatsCopyWith<$Res> {
  factory $MatchStatsCopyWith(
    MatchStats value,
    $Res Function(MatchStats) then,
  ) = _$MatchStatsCopyWithImpl<$Res, MatchStats>;
  @useResult
  $Res call({
    String childId,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    int totalScore,
    double averageScore,
    double winRate,
  });
}

/// @nodoc
class _$MatchStatsCopyWithImpl<$Res, $Val extends MatchStats>
    implements $MatchStatsCopyWith<$Res> {
  _$MatchStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? totalScore = null,
    Object? averageScore = null,
    Object? winRate = null,
  }) {
    return _then(
      _value.copyWith(
            childId: null == childId
                ? _value.childId
                : childId // ignore: cast_nullable_to_non_nullable
                      as String,
            gamesPlayed: null == gamesPlayed
                ? _value.gamesPlayed
                : gamesPlayed // ignore: cast_nullable_to_non_nullable
                      as int,
            gamesWon: null == gamesWon
                ? _value.gamesWon
                : gamesWon // ignore: cast_nullable_to_non_nullable
                      as int,
            gamesLost: null == gamesLost
                ? _value.gamesLost
                : gamesLost // ignore: cast_nullable_to_non_nullable
                      as int,
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            averageScore: null == averageScore
                ? _value.averageScore
                : averageScore // ignore: cast_nullable_to_non_nullable
                      as double,
            winRate: null == winRate
                ? _value.winRate
                : winRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchStatsImplCopyWith<$Res>
    implements $MatchStatsCopyWith<$Res> {
  factory _$$MatchStatsImplCopyWith(
    _$MatchStatsImpl value,
    $Res Function(_$MatchStatsImpl) then,
  ) = __$$MatchStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String childId,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    int totalScore,
    double averageScore,
    double winRate,
  });
}

/// @nodoc
class __$$MatchStatsImplCopyWithImpl<$Res>
    extends _$MatchStatsCopyWithImpl<$Res, _$MatchStatsImpl>
    implements _$$MatchStatsImplCopyWith<$Res> {
  __$$MatchStatsImplCopyWithImpl(
    _$MatchStatsImpl _value,
    $Res Function(_$MatchStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? totalScore = null,
    Object? averageScore = null,
    Object? winRate = null,
  }) {
    return _then(
      _$MatchStatsImpl(
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        gamesPlayed: null == gamesPlayed
            ? _value.gamesPlayed
            : gamesPlayed // ignore: cast_nullable_to_non_nullable
                  as int,
        gamesWon: null == gamesWon
            ? _value.gamesWon
            : gamesWon // ignore: cast_nullable_to_non_nullable
                  as int,
        gamesLost: null == gamesLost
            ? _value.gamesLost
            : gamesLost // ignore: cast_nullable_to_non_nullable
                  as int,
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        averageScore: null == averageScore
            ? _value.averageScore
            : averageScore // ignore: cast_nullable_to_non_nullable
                  as double,
        winRate: null == winRate
            ? _value.winRate
            : winRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchStatsImpl implements _MatchStats {
  const _$MatchStatsImpl({
    required this.childId,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.gamesLost,
    required this.totalScore,
    required this.averageScore,
    required this.winRate,
  });

  factory _$MatchStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchStatsImplFromJson(json);

  @override
  final String childId;
  @override
  final int gamesPlayed;
  @override
  final int gamesWon;
  @override
  final int gamesLost;
  @override
  final int totalScore;
  @override
  final double averageScore;
  @override
  final double winRate;

  @override
  String toString() {
    return 'MatchStats(childId: $childId, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, gamesLost: $gamesLost, totalScore: $totalScore, averageScore: $averageScore, winRate: $winRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchStatsImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.gamesPlayed, gamesPlayed) ||
                other.gamesPlayed == gamesPlayed) &&
            (identical(other.gamesWon, gamesWon) ||
                other.gamesWon == gamesWon) &&
            (identical(other.gamesLost, gamesLost) ||
                other.gamesLost == gamesLost) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.averageScore, averageScore) ||
                other.averageScore == averageScore) &&
            (identical(other.winRate, winRate) || other.winRate == winRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    childId,
    gamesPlayed,
    gamesWon,
    gamesLost,
    totalScore,
    averageScore,
    winRate,
  );

  /// Create a copy of MatchStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchStatsImplCopyWith<_$MatchStatsImpl> get copyWith =>
      __$$MatchStatsImplCopyWithImpl<_$MatchStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchStatsImplToJson(this);
  }
}

abstract class _MatchStats implements MatchStats {
  const factory _MatchStats({
    required final String childId,
    required final int gamesPlayed,
    required final int gamesWon,
    required final int gamesLost,
    required final int totalScore,
    required final double averageScore,
    required final double winRate,
  }) = _$MatchStatsImpl;

  factory _MatchStats.fromJson(Map<String, dynamic> json) =
      _$MatchStatsImpl.fromJson;

  @override
  String get childId;
  @override
  int get gamesPlayed;
  @override
  int get gamesWon;
  @override
  int get gamesLost;
  @override
  int get totalScore;
  @override
  double get averageScore;
  @override
  double get winRate;

  /// Create a copy of MatchStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchStatsImplCopyWith<_$MatchStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchHistoryItem _$MatchHistoryItemFromJson(Map<String, dynamic> json) {
  return _MatchHistoryItem.fromJson(json);
}

/// @nodoc
mixin _$MatchHistoryItem {
  String get matchSessionId => throw _privateConstructorUsedError;
  DateTime get playedAt => throw _privateConstructorUsedError;
  String get opponentName => throw _privateConstructorUsedError;
  int? get opponentAvatarId => throw _privateConstructorUsedError;
  int get myScore => throw _privateConstructorUsedError;
  int get opponentScore => throw _privateConstructorUsedError;
  bool get isWinner => throw _privateConstructorUsedError;
  bool get isDraw => throw _privateConstructorUsedError;

  /// Serializes this MatchHistoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchHistoryItemCopyWith<MatchHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchHistoryItemCopyWith<$Res> {
  factory $MatchHistoryItemCopyWith(
    MatchHistoryItem value,
    $Res Function(MatchHistoryItem) then,
  ) = _$MatchHistoryItemCopyWithImpl<$Res, MatchHistoryItem>;
  @useResult
  $Res call({
    String matchSessionId,
    DateTime playedAt,
    String opponentName,
    int? opponentAvatarId,
    int myScore,
    int opponentScore,
    bool isWinner,
    bool isDraw,
  });
}

/// @nodoc
class _$MatchHistoryItemCopyWithImpl<$Res, $Val extends MatchHistoryItem>
    implements $MatchHistoryItemCopyWith<$Res> {
  _$MatchHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchSessionId = null,
    Object? playedAt = null,
    Object? opponentName = null,
    Object? opponentAvatarId = freezed,
    Object? myScore = null,
    Object? opponentScore = null,
    Object? isWinner = null,
    Object? isDraw = null,
  }) {
    return _then(
      _value.copyWith(
            matchSessionId: null == matchSessionId
                ? _value.matchSessionId
                : matchSessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            playedAt: null == playedAt
                ? _value.playedAt
                : playedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            opponentName: null == opponentName
                ? _value.opponentName
                : opponentName // ignore: cast_nullable_to_non_nullable
                      as String,
            opponentAvatarId: freezed == opponentAvatarId
                ? _value.opponentAvatarId
                : opponentAvatarId // ignore: cast_nullable_to_non_nullable
                      as int?,
            myScore: null == myScore
                ? _value.myScore
                : myScore // ignore: cast_nullable_to_non_nullable
                      as int,
            opponentScore: null == opponentScore
                ? _value.opponentScore
                : opponentScore // ignore: cast_nullable_to_non_nullable
                      as int,
            isWinner: null == isWinner
                ? _value.isWinner
                : isWinner // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDraw: null == isDraw
                ? _value.isDraw
                : isDraw // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchHistoryItemImplCopyWith<$Res>
    implements $MatchHistoryItemCopyWith<$Res> {
  factory _$$MatchHistoryItemImplCopyWith(
    _$MatchHistoryItemImpl value,
    $Res Function(_$MatchHistoryItemImpl) then,
  ) = __$$MatchHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String matchSessionId,
    DateTime playedAt,
    String opponentName,
    int? opponentAvatarId,
    int myScore,
    int opponentScore,
    bool isWinner,
    bool isDraw,
  });
}

/// @nodoc
class __$$MatchHistoryItemImplCopyWithImpl<$Res>
    extends _$MatchHistoryItemCopyWithImpl<$Res, _$MatchHistoryItemImpl>
    implements _$$MatchHistoryItemImplCopyWith<$Res> {
  __$$MatchHistoryItemImplCopyWithImpl(
    _$MatchHistoryItemImpl _value,
    $Res Function(_$MatchHistoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchSessionId = null,
    Object? playedAt = null,
    Object? opponentName = null,
    Object? opponentAvatarId = freezed,
    Object? myScore = null,
    Object? opponentScore = null,
    Object? isWinner = null,
    Object? isDraw = null,
  }) {
    return _then(
      _$MatchHistoryItemImpl(
        matchSessionId: null == matchSessionId
            ? _value.matchSessionId
            : matchSessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        playedAt: null == playedAt
            ? _value.playedAt
            : playedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        opponentName: null == opponentName
            ? _value.opponentName
            : opponentName // ignore: cast_nullable_to_non_nullable
                  as String,
        opponentAvatarId: freezed == opponentAvatarId
            ? _value.opponentAvatarId
            : opponentAvatarId // ignore: cast_nullable_to_non_nullable
                  as int?,
        myScore: null == myScore
            ? _value.myScore
            : myScore // ignore: cast_nullable_to_non_nullable
                  as int,
        opponentScore: null == opponentScore
            ? _value.opponentScore
            : opponentScore // ignore: cast_nullable_to_non_nullable
                  as int,
        isWinner: null == isWinner
            ? _value.isWinner
            : isWinner // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDraw: null == isDraw
            ? _value.isDraw
            : isDraw // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchHistoryItemImpl implements _MatchHistoryItem {
  const _$MatchHistoryItemImpl({
    required this.matchSessionId,
    required this.playedAt,
    required this.opponentName,
    this.opponentAvatarId,
    required this.myScore,
    required this.opponentScore,
    required this.isWinner,
    this.isDraw = false,
  });

  factory _$MatchHistoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchHistoryItemImplFromJson(json);

  @override
  final String matchSessionId;
  @override
  final DateTime playedAt;
  @override
  final String opponentName;
  @override
  final int? opponentAvatarId;
  @override
  final int myScore;
  @override
  final int opponentScore;
  @override
  final bool isWinner;
  @override
  @JsonKey()
  final bool isDraw;

  @override
  String toString() {
    return 'MatchHistoryItem(matchSessionId: $matchSessionId, playedAt: $playedAt, opponentName: $opponentName, opponentAvatarId: $opponentAvatarId, myScore: $myScore, opponentScore: $opponentScore, isWinner: $isWinner, isDraw: $isDraw)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchHistoryItemImpl &&
            (identical(other.matchSessionId, matchSessionId) ||
                other.matchSessionId == matchSessionId) &&
            (identical(other.playedAt, playedAt) ||
                other.playedAt == playedAt) &&
            (identical(other.opponentName, opponentName) ||
                other.opponentName == opponentName) &&
            (identical(other.opponentAvatarId, opponentAvatarId) ||
                other.opponentAvatarId == opponentAvatarId) &&
            (identical(other.myScore, myScore) || other.myScore == myScore) &&
            (identical(other.opponentScore, opponentScore) ||
                other.opponentScore == opponentScore) &&
            (identical(other.isWinner, isWinner) ||
                other.isWinner == isWinner) &&
            (identical(other.isDraw, isDraw) || other.isDraw == isDraw));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    matchSessionId,
    playedAt,
    opponentName,
    opponentAvatarId,
    myScore,
    opponentScore,
    isWinner,
    isDraw,
  );

  /// Create a copy of MatchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchHistoryItemImplCopyWith<_$MatchHistoryItemImpl> get copyWith =>
      __$$MatchHistoryItemImplCopyWithImpl<_$MatchHistoryItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchHistoryItemImplToJson(this);
  }
}

abstract class _MatchHistoryItem implements MatchHistoryItem {
  const factory _MatchHistoryItem({
    required final String matchSessionId,
    required final DateTime playedAt,
    required final String opponentName,
    final int? opponentAvatarId,
    required final int myScore,
    required final int opponentScore,
    required final bool isWinner,
    final bool isDraw,
  }) = _$MatchHistoryItemImpl;

  factory _MatchHistoryItem.fromJson(Map<String, dynamic> json) =
      _$MatchHistoryItemImpl.fromJson;

  @override
  String get matchSessionId;
  @override
  DateTime get playedAt;
  @override
  String get opponentName;
  @override
  int? get opponentAvatarId;
  @override
  int get myScore;
  @override
  int get opponentScore;
  @override
  bool get isWinner;
  @override
  bool get isDraw;

  /// Create a copy of MatchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchHistoryItemImplCopyWith<_$MatchHistoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/classroom_models.dart';
import '../services/classroom_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';

// ── State ────────────────────────────────────────────────────────────────────

class ClassroomState {
  final List<ClassroomDto> classrooms;
  final ClassroomDetailDto? currentDetail;
  final bool isLoading;
  final String? error;

  const ClassroomState({
    this.classrooms = const [],
    this.currentDetail,
    this.isLoading = false,
    this.error,
  });

  ClassroomState copyWith({
    List<ClassroomDto>? classrooms,
    ClassroomDetailDto? currentDetail,
    bool clearDetail = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      ClassroomState(
        classrooms:    classrooms    ?? this.classrooms,
        currentDetail: clearDetail   ? null : (currentDetail ?? this.currentDetail),
        isLoading:     isLoading     ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class ClassroomNotifier extends StateNotifier<ClassroomState> {
  final ClassroomService _service;
  final Ref _ref;

  ClassroomNotifier(this._service, this._ref) : super(const ClassroomState());

  String? get _childId => _ref.read(selectedChildProvider)?.id;

  // ── Listele ───────────────────────────────────────────────────────────────

  Future<void> loadMine() async {
    final childId = _childId;
    if (childId == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _service.getMine(childId);
      state = state.copyWith(classrooms: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Detay ─────────────────────────────────────────────────────────────────

  Future<void> loadDetail(String classroomId) async {
    final childId = _childId;
    if (childId == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _service.getDetail(classroomId, childId);
      state = state.copyWith(currentDetail: detail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Oluştur ───────────────────────────────────────────────────────────────

  Future<ClassroomDto?> createClassroom(String name) async {
    final childId = _childId;
    if (childId == null) return null;
    try {
      final created = await _service.createClassroom(name, childId);
      state = state.copyWith(classrooms: [created, ...state.classrooms]);
      return created;
    } catch (e) {
      state = state.copyWith(error: _parseError(e));
      return null;
    }
  }

  // ── Katıl ─────────────────────────────────────────────────────────────────

  Future<ClassroomDto?> joinByCode(String inviteCode) async {
    final childId = _childId;
    if (childId == null) return null;
    try {
      final joined = await _service.joinByCode(inviteCode, childId);
      if (state.classrooms.every((c) => c.id != joined.id)) {
        state = state.copyWith(classrooms: [...state.classrooms, joined]);
      }
      return joined;
    } catch (e) {
      state = state.copyWith(error: _parseError(e));
      return null;
    }
  }

  // ── Ayrıl ─────────────────────────────────────────────────────────────────

  Future<bool> leave(String classroomId) async {
    final childId = _childId;
    if (childId == null) return false;
    try {
      await _service.leave(classroomId, childId);
      state = state.copyWith(
        classrooms: state.classrooms.where((c) => c.id != classroomId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: _parseError(e));
      return false;
    }
  }

  // ── Ödev Oluştur ─────────────────────────────────────────────────────────

  Future<bool> createAssignment({
    required String classroomId,
    required String levelId,
    required String title,
    DateTime? dueDate,
    int minQuestions = 10,
  }) async {
    try {
      final assignment = await _service.createAssignment(
        classroomId:  classroomId,
        levelId:      levelId,
        title:        title,
        dueDate:      dueDate,
        minQuestions: minQuestions,
      );
      // Detayı yenile
      if (state.currentDetail?.id == classroomId) {
        final updatedAssignments = [
          assignment,
          ...state.currentDetail!.assignments,
        ];
        state = state.copyWith(
          currentDetail: ClassroomDetailDto(
            id:          state.currentDetail!.id,
            name:        state.currentDetail!.name,
            inviteCode:  state.currentDetail!.inviteCode,
            memberCount: state.currentDetail!.memberCount,
            myRole:      state.currentDetail!.myRole,
            assignments: updatedAssignments,
            members:     state.currentDetail!.members,
          ),
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: _parseError(e));
      return false;
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final classroomNotifierProvider =
    StateNotifierProvider<ClassroomNotifier, ClassroomState>(
  (ref) => ClassroomNotifier(ref.watch(classroomServiceProvider), ref),
);

// ── Hata çözümleme ────────────────────────────────────────────────────────────

String _parseError(Object e) {
  if (e is DioException) {
    final msg = e.response?.data;
    if (msg is Map) return msg['message'] as String? ?? e.message ?? e.toString();
    if (msg is String && msg.isNotEmpty) return msg;
    return e.message ?? e.toString();
  }
  return e.toString();
}

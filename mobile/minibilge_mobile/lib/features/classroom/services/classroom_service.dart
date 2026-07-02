import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/classroom_models.dart';

class ClassroomService {
  final Dio _dio;
  ClassroomService(this._dio);

  Future<ClassroomDto> createClassroom(String name) async {
    final r = await _dio.post('/classrooms', data: {'name': name});
    return ClassroomDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<ClassroomDto> joinByCode(String inviteCode, String childId) async {
    final r = await _dio.post(
      '/classrooms/join',
      data: {'inviteCode': inviteCode},
      queryParameters: {'childId': childId},
    );
    return ClassroomDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> leave(String classroomId, String childId) async {
    await _dio.delete('/classrooms/$classroomId/leave',
        queryParameters: {'childId': childId});
  }

  Future<List<ClassroomDto>> getMine(String childId) async {
    final r = await _dio.get('/classrooms/mine',
        queryParameters: {'childId': childId});
    return (r.data as List)
        .map((e) => ClassroomDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ClassroomDetailDto> getDetail(String classroomId, String childId) async {
    final r = await _dio.get('/classrooms/$classroomId',
        queryParameters: {'childId': childId});
    return ClassroomDetailDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<AssignmentSummaryDto> createAssignment({
    required String classroomId,
    required String levelId,
    required String title,
    DateTime? dueDate,
    int minQuestions = 10,
  }) async {
    final r = await _dio.post('/classrooms/$classroomId/assignments', data: {
      'levelId':      levelId,
      'title':        title,
      'dueDate':      dueDate?.toUtc().toIso8601String(),
      'minQuestions': minQuestions,
    });
    return AssignmentSummaryDto.fromJson(r.data as Map<String, dynamic>);
  }
}

final classroomServiceProvider = Provider<ClassroomService>(
  (ref) => ClassroomService(ref.watch(dioProvider)),
);

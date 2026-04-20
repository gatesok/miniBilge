import 'package:dio/dio.dart';
import '../../../core/network/dio_provider.dart';
import '../models/child_profile_dto.dart';
import '../models/create_child_profile_request.dart';
import '../models/update_child_profile_request.dart';

class ChildProfileApiService {
  final Dio _dio;

  ChildProfileApiService(this._dio);

  /// Get all child profiles for the authenticated parent
  Future<List<ChildProfileDto>> getChildProfiles() async {
    try {
      final response = await _dio.get('/childprofile');
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => ChildProfileDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific child profile by ID
  Future<ChildProfileDto> getChildProfile(String id) async {
    try {
      final response = await _dio.get('/childprofile/$id');
      return ChildProfileDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new child profile
  Future<ChildProfileDto> createChildProfile(CreateChildProfileRequest request) async {
    try {
      final response = await _dio.post(
        '/childprofile',
        data: request.toJson(),
      );
      return ChildProfileDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing child profile
  Future<ChildProfileDto> updateChildProfile(
    String id,
    UpdateChildProfileRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/childprofile/$id',
        data: request.toJson(),
      );
      return ChildProfileDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a child profile
  Future<void> deleteChildProfile(String id) async {
    try {
      await _dio.delete('/childprofile/$id');
    } catch (e) {
      rethrow;
    }
  }
}

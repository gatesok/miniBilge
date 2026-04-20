import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child_profile_dto.dart';
import '../models/create_child_profile_request.dart';
import '../models/update_child_profile_request.dart';
import '../services/child_profile_api_service.dart';
import 'child_profile_service_provider.dart';
import 'child_profile_state.dart';

class ChildProfileNotifier extends StateNotifier<ChildProfileState> {
  final ChildProfileApiService _apiService;

  ChildProfileNotifier(this._apiService) : super(const ChildProfileState.initial());

  /// Load all child profiles
  Future<void> loadProfiles() async {
    state = const ChildProfileState.loading();
    
    try {
      final profiles = await _apiService.getChildProfiles();
      state = ChildProfileState.loaded(profiles);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = ChildProfileState.error(message);
    } catch (e) {
      state = ChildProfileState.error('Profiller yüklenirken bir hata oluştu');
    }
  }

  /// Create a new child profile
  Future<bool> createProfile(CreateChildProfileRequest request) async {
    try {
      final newProfile = await _apiService.createChildProfile(request);
      
      // Add to existing list
      state.maybeWhen(
        loaded: (profiles) {
          state = ChildProfileState.loaded([...profiles, newProfile]);
        },
        orElse: () {
          state = ChildProfileState.loaded([newProfile]);
        },
      );
      
      return true;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = ChildProfileState.error(message);
      return false;
    } catch (e) {
      state = ChildProfileState.error('Profil oluşturulurken bir hata oluştu');
      return false;
    }
  }

  /// Update an existing child profile
  Future<bool> updateProfile(String id, UpdateChildProfileRequest request) async {
    try {
      final updatedProfile = await _apiService.updateChildProfile(id, request);
      
      // Update in list
      state.maybeWhen(
        loaded: (profiles) {
          final updatedList = profiles.map((p) {
            return p.id == id ? updatedProfile : p;
          }).toList();
          state = ChildProfileState.loaded(updatedList);
        },
        orElse: () {},
      );
      
      return true;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = ChildProfileState.error(message);
      return false;
    } catch (e) {
      state = ChildProfileState.error('Profil güncellenirken bir hata oluştu');
      return false;
    }
  }

  /// Delete a child profile
  Future<bool> deleteProfile(String id) async {
    try {
      await _apiService.deleteChildProfile(id);
      
      // Remove from list
      state.maybeWhen(
        loaded: (profiles) {
          final updatedList = profiles.where((p) => p.id != id).toList();
          state = ChildProfileState.loaded(updatedList);
        },
        orElse: () {},
      );
      
      return true;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = ChildProfileState.error(message);
      return false;
    } catch (e) {
      state = ChildProfileState.error('Profil silinirken bir hata oluştu');
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state.maybeWhen(
      error: (_) => state = const ChildProfileState.initial(),
      orElse: () {},
    );
  }

  /// Extract error message from DioException
  String _extractErrorMessage(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      
      // Backend'den gelen hata mesajı
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          return data['message'] as String;
        }
        if (data.containsKey('title')) {
          return data['title'] as String;
        }
      }
      
      // String olarak gelen hata
      if (data is String) {
        return data;
      }
    }
    
    // HTTP status code'a göre mesaj
    switch (error.response?.statusCode) {
      case 400:
        return 'Geçersiz istek';
      case 401:
        return 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın';
      case 403:
        return 'Bu işlem için yetkiniz yok';
      case 404:
        return 'Profil bulunamadı';
      case 500:
        return 'Sunucu hatası oluştu';
      default:
        return error.message ?? 'Bir hata oluştu';
    }
  }
}

final childProfileProvider = StateNotifierProvider<ChildProfileNotifier, ChildProfileState>((ref) {
  final apiService = ref.watch(childProfileApiServiceProvider);
  return ChildProfileNotifier(apiService);
});

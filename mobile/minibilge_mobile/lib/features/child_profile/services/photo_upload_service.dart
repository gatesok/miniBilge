import 'dart:io';
import 'package:dio/dio.dart';

class PhotoUploadService {
  final Dio _dio;

  PhotoUploadService(this._dio);

  /// Uploads [imageFile] as the profile photo for [childId].
  /// Returns the public URL of the uploaded photo.
  Future<String> uploadProfilePhoto({
    required String childId,
    required File imageFile,
  }) async {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        imageFile.path,
        filename: '$childId.$ext',
        contentType: DioMediaType.parse(contentType),
      ),
    });

    final response = await _dio.post(
      '/childprofile/$childId/photo',
      data: formData,
    );

    return response.data['photoUrl'] as String;
  }
}

import 'package:dio/dio.dart';
import '../models/app_notification_model.dart';

class NotificationInboxService {
  final Dio _dio;
  NotificationInboxService(this._dio);

  Future<List<AppNotificationModel>> getNotifications(String childId) async {
    final response = await _dio.get('/notifications/$childId');
    if (response.data is List) {
      return (response.data as List)
          .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<int> getUnreadCount(String childId) async {
    final response = await _dio.get('/notifications/$childId/unread-count');
    return response.data as int? ?? 0;
  }

  Future<void> markAllRead(String childId) async {
    await _dio.post('/notifications/$childId/mark-all-read');
  }

  Future<void> deleteNotification(String childId, String notificationId) async {
    await _dio.delete('/notifications/$childId/$notificationId');
  }
}

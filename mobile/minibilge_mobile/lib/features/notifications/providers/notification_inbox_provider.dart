import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/app_notification_model.dart';
import '../services/notification_inbox_service.dart';

// ── Service provider ────────────────────────────────────────────────────────

final notificationInboxServiceProvider =
    Provider<NotificationInboxService>((ref) {
  return NotificationInboxService(ref.watch(dioProvider));
});

// ── Unread count provider (badge) ────────────────────────────────────────────

final unreadNotificationCountProvider =
    StateNotifierProvider.family<UnreadCountNotifier, int, String>(
        (ref, childId) {
  return UnreadCountNotifier(ref.read(notificationInboxServiceProvider), childId);
});

class UnreadCountNotifier extends StateNotifier<int> {
  final NotificationInboxService _service;
  final String _childId;

  UnreadCountNotifier(this._service, this._childId) : super(0) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = await _service.getUnreadCount(_childId);
    } catch (_) {}
  }

  Future<void> refresh() => _load();
  void clear() => state = 0;
}

// ── Notification list provider ───────────────────────────────────────────────

final notificationInboxProvider = StateNotifierProvider.family<
    NotificationInboxNotifier,
    AsyncValue<List<AppNotificationModel>>,
    String>((ref, childId) {
  return NotificationInboxNotifier(
      ref.read(notificationInboxServiceProvider), childId);
});

class NotificationInboxNotifier
    extends StateNotifier<AsyncValue<List<AppNotificationModel>>> {
  final NotificationInboxService _service;
  final String _childId;

  NotificationInboxNotifier(this._service, this._childId)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final items = await _service.getNotifications(_childId);
      state = AsyncValue.data(items);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Tüm bildirimleri okundu işaretler ve listeyi günceller.
  Future<void> markAllRead() async {
    try {
      await _service.markAllRead(_childId);
      state.whenData((items) {
        state = AsyncValue.data(
            items.map((n) => AppNotificationModel(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  notificationType: n.notificationType,
                  isRead: true,
                  createdAt: n.createdAt,
                )).toList());
      });
    } catch (_) {}
  }

  /// Tek bildirimi siler.
  Future<void> delete(String childId, String notificationId) async {
    try {
      await _service.deleteNotification(childId, notificationId);
      state.whenData((items) {
        state = AsyncValue.data(
            items.where((n) => n.id != notificationId).toList());
      });
    } catch (_) {}
  }

  Future<void> refresh() => _load();
}

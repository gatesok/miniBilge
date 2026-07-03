import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/app_notification_model.dart';
import '../providers/notification_inbox_provider.dart';

class NotificationInboxScreen extends ConsumerStatefulWidget {
  final String childId;
  const NotificationInboxScreen({super.key, required this.childId});

  @override
  ConsumerState<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState
    extends ConsumerState<NotificationInboxScreen> {
  static const _badgeChannel =
      MethodChannel('com.minibilge.app/badge');

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markReadAndClear());
  }

  Future<void> _markReadAndClear() async {
    // Tüm bildirimleri okundu işaretle
    await ref
        .read(notificationInboxProvider(widget.childId).notifier)
        .markAllRead();
    // Unread badge sıfırla
    ref.read(unreadNotificationCountProvider(widget.childId).notifier).clear();
    // iOS uygulama ikonu badge'ini sıfırla
    try {
      await _badgeChannel.invokeMethod('clearBadge');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationInboxProvider(widget.childId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '🔔 Bildirimler',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 22,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(2, 2))
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: state.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 52, color: Colors.white70),
                          const SizedBox(height: 12),
                          Text('Bildirimler yüklenemedi',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => ref
                                .read(notificationInboxProvider(widget.childId)
                                    .notifier)
                                .refresh(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A3FCC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Tekrar Dene',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (items) => items.isEmpty
                      ? _EmptyState()
                      : RefreshIndicator(
                          color: const Color(0xFF7B61FF),
                          onRefresh: () => ref
                              .read(notificationInboxProvider(widget.childId)
                                  .notifier)
                              .refresh(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                            itemCount: items.length,
                            itemBuilder: (context, i) =>
                                _NotificationTile(item: items[i]),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Henüz bildirim yok',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Arkadaş istekleri, meydan okumalar\nve ödev güncellemeleri burada görünür',
              style: GoogleFonts.nunito(
                  color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel item;
  const _NotificationTile({required this.item});

  String get _typeIcon {
    return switch (item.notificationType) {
      'friend_request'        => '🤝',
      'match_invite'          => '⚡',
      'match_invite_response' => '⚡',
      'challenge_received'    => '⚔️',
      'challenge_accepted'    => '✅',
      'challenge_result'      => '🏆',
      'challenge_reminder'    => '⏰',
      'new_assignment'        => '📚',
      'assignment_due_reminder'=> '⏰',
      'assignment_updated'    => '✏️',
      'assignment_deleted'    => '🗑️',
      'kicked_from_classroom' => '🚪',
      'daily_reminder'        => '🎯',
      'streak_warning'        => '🔥',
      _                       => '🔔',
    };
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _formatTime(item.createdAt);
    final unread = !item.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unread
            ? Colors.white.withOpacity(0.28)
            : Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: unread
                ? Colors.white.withOpacity(0.50)
                : Colors.white.withOpacity(0.25),
            width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(_typeIcon,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w600),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7B61FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.body,
                  style: GoogleFonts.nunito(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  timeLabel,
                  style: GoogleFonts.nunito(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk. önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return DateFormat('d MMM', 'tr').format(dt.toLocal());
  }
}

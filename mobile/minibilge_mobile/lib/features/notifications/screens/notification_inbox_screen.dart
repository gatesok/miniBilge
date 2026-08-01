import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  static const _badgeChannel = MethodChannel('com.minibilge.app/badge');

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
                  horizontal: 16,
                  vertical: 12,
                ),
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
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'BİLDİRİMLER',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 22,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            blurRadius: 0,
                            color: Color(0xFF3D35CC),
                            offset: Offset(2, 2),
                          ),
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
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 52,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Bildirimler yüklenemedi',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => ref
                                .read(
                                  notificationInboxProvider(
                                    widget.childId,
                                  ).notifier,
                                )
                                .refresh(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A3FCC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Tekrar Dene',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
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
                              .read(
                                notificationInboxProvider(
                                  widget.childId,
                                ).notifier,
                              )
                              .refresh(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final item = items[i];
                              return Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) {
                                  ref
                                      .read(
                                        notificationInboxProvider(
                                          widget.childId,
                                        ).notifier,
                                      )
                                      .delete(widget.childId, item.id);
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                child: _NotificationTile(item: item),
                              );
                            },
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
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bildirim yok',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Arkadaş istekleri, meydan okumalar\nve ödev güncellemeleri burada görünür',
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel item;
  const _NotificationTile({required this.item});

  static const _challengeTypes = {
    'challenge_received',
    'challenge_accepted',
    'challenge_result',
    'challenge_reminder',
    'challenge_completion_reminder',
  };

  static const _assignmentTypes = {
    'new_assignment',
    'assignment_due_reminder',
    'assignment_updated',
    'assignment_deleted',
  };

  bool get _isTappable =>
      _challengeTypes.contains(item.notificationType) ||
      _assignmentTypes.contains(item.notificationType);

  void _onTap(BuildContext context) {
    if (_challengeTypes.contains(item.notificationType)) {
      context.go('/challenges');
    } else if (_assignmentTypes.contains(item.notificationType)) {
      context.go('/classrooms');
    }
  }

  _NotificationVisual get _visual {
    final normalizedTitle = _displayTitle.toLowerCase();

    if (item.notificationType == 'challenge_result') {
      if (normalizedTitle.contains('kazand')) {
        return const _NotificationVisual(
          icon: Icons.emoji_events_rounded,
          foreground: Color(0xFFFFB300),
          background: Color(0xFFFFF1C7),
        );
      }
      if (normalizedTitle.contains('berabere')) {
        return const _NotificationVisual(
          icon: Icons.handshake_rounded,
          foreground: Color(0xFF4B8AF0),
          background: Color(0xFFDCEBFF),
        );
      }
      return const _NotificationVisual(
        icon: Icons.sentiment_dissatisfied_rounded,
        foreground: Color(0xFFE96A71),
        background: Color(0xFFFFE1E3),
      );
    }

    return switch (item.notificationType) {
      'friend_request' => const _NotificationVisual(
        icon: Icons.person_add_alt_1_rounded,
        foreground: Color(0xFF26A69A),
        background: Color(0xFFD9F5EF),
      ),
      'match_invite' => const _NotificationVisual(
        icon: Icons.bolt_rounded,
        foreground: Color(0xFFFF8A00),
        background: Color(0xFFFFE6C6),
      ),
      'match_invite_response' => const _NotificationVisual(
        icon: Icons.sports_esports_rounded,
        foreground: Color(0xFF5A55D9),
        background: Color(0xFFE5E3FF),
      ),
      'challenge_received' => const _NotificationVisual(
        icon: Icons.shield_rounded,
        foreground: Color(0xFF8E35C7),
        background: Color(0xFFF0DFFF),
      ),
      'challenge_accepted' => const _NotificationVisual(
        icon: Icons.task_alt_rounded,
        foreground: Color(0xFF2EA866),
        background: Color(0xFFDDF5E7),
      ),
      'challenge_reminder' => const _NotificationVisual(
        icon: Icons.notifications_active_rounded,
        foreground: Color(0xFFFF8A00),
        background: Color(0xFFFFE6C6),
      ),
      'challenge_completion_reminder' => const _NotificationVisual(
        icon: Icons.play_circle_fill_rounded,
        foreground: Color(0xFF3777D8),
        background: Color(0xFFDDEAFF),
      ),
      'new_assignment' => const _NotificationVisual(
        icon: Icons.menu_book_rounded,
        foreground: Color(0xFF3B8E72),
        background: Color(0xFFDDF4E9),
      ),
      'assignment_due_reminder' => const _NotificationVisual(
        icon: Icons.event_available_rounded,
        foreground: Color(0xFFFF8A00),
        background: Color(0xFFFFE6C6),
      ),
      'assignment_updated' => const _NotificationVisual(
        icon: Icons.edit_note_rounded,
        foreground: Color(0xFF5277C8),
        background: Color(0xFFDDEAFF),
      ),
      'assignment_deleted' ||
      'kicked_from_classroom' => const _NotificationVisual(
        icon: Icons.info_outline_rounded,
        foreground: Color(0xFFE96A71),
        background: Color(0xFFFFE1E3),
      ),
      'daily_reminder' => const _NotificationVisual(
        icon: Icons.track_changes_rounded,
        foreground: Color(0xFF7B61FF),
        background: Color(0xFFE8E2FF),
      ),
      'streak_warning' => const _NotificationVisual(
        icon: Icons.local_fire_department_rounded,
        foreground: Color(0xFFFF6B35),
        background: Color(0xFFFFE1D5),
      ),
      _ => const _NotificationVisual(
        icon: Icons.notifications_rounded,
        foreground: Color(0xFF5B68C7),
        background: Color(0xFFE3E8FF),
      ),
    };
  }

  String get _displayTitle {
    var title = item.title.trim();
    const prefixes = [
      '⚔️',
      '🏆',
      '✅',
      '😔',
      '⏰',
      '🤝',
      '⚡',
      '📚',
      '✏️',
      '🗑️',
      '🚪',
      '🎯',
      '🔥',
      '🔔',
      '🎉',
    ];
    for (final prefix in prefixes) {
      if (title.startsWith(prefix)) {
        title = title.substring(prefix.length).trimLeft();
        break;
      }
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _formatTime(item.createdAt);
    final unread = !item.isRead;
    final visual = _visual;

    return GestureDetector(
      onTap: _isTappable ? () => _onTap(context) : null,
      child: Container(
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
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: visual.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(visual.icon, color: visual.foreground, size: 25),
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
                          _displayTitle,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
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
                      if (_isTappable)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white54,
                            size: 18,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLabel,
                    style: GoogleFonts.nunito(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _NotificationVisual {
  final IconData icon;
  final Color foreground;
  final Color background;

  const _NotificationVisual({
    required this.icon,
    required this.foreground,
    required this.background,
  });
}

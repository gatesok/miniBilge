import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge_models.dart';
import '../widgets/challenge_send_dialog.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../friends/providers/friend_provider.dart';
import '../../auth/providers/auth_provider.dart';

// ── Tasarım sabitleri ────────────────────────────────────────────────────────

const _kGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF4FACFE), Color(0xFF7B6FCD), Color(0xFF9B8FE8)],
);

BoxDecoration _glassCard({double radius = 16}) => BoxDecoration(
  color: const Color(0xFF1A0E52).withValues(alpha: 0.22),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

// ── Zorluk rozeti ────────────────────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  final String label;
  const _DifficultyBadge({required this.label});

  Color get _color {
    switch (label.toLowerCase()) {
      case 'kolay':
        return const Color(0xFF4CAF50);
      case 'orta':
        return const Color(0xFFFF9800);
      case 'zor':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF7B61FF); // İngilizce seviyeleri (A1..C2) vb.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 12),
          const SizedBox(width: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ana Ekran ────────────────────────────────────────────────────────────────

class ChallengeScreen extends ConsumerStatefulWidget {
  const ChallengeScreen({super.key});

  @override
  ConsumerState<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(challengeNotifierProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(challengeNotifierProvider);
    final childId = ref.watch(selectedChildProvider)?.id ?? '';
    final isPremium = ref
        .watch(authProvider)
        .maybeWhen(
          authenticated: (user) => user.isPremium,
          orElse: () => false,
        );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _kGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/dashboard');
                        }
                      },
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icon/dashboard_challenge.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Meydan Okumalar',
                                style: GoogleFonts.luckiestGuy(
                                  color: Colors.white,
                                  fontSize: 22,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 0,
                                      color: Color(0xFF3D35CC),
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => ref
                          .read(challengeNotifierProvider.notifier)
                          .loadAll(),
                    ),
                  ],
                ),
              ),
              // ── Tabs ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    labelColor: const Color(0xFF6A5ACD),
                    unselectedLabelColor: Colors.white,
                    labelStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                    unselectedLabelStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: [
                      _challengeTab(
                        icon: Icons.move_to_inbox_rounded,
                        label: 'Gelen',
                        count: challengeState.incoming.length,
                      ),
                      _challengeTab(
                        icon: Icons.outbox_rounded,
                        label: 'Gönderilen',
                        count: challengeState.outgoing.length,
                      ),
                      _challengeTab(
                        icon: Icons.history_rounded,
                        label: 'Geçmiş ${isPremium ? '90' : '7'}g',
                      ),
                      _challengeTab(
                        icon: Icons.people_alt_rounded,
                        label: 'Arkadaşlar',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // ── Tab Views ─────────────────────────────────────────
              Expanded(
                child: challengeState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : TabBarView(
                        controller: _tabs,
                        children: [
                          _ChallengeList(
                            challenges: challengeState.incoming,
                            childId: childId,
                            emptyText: 'Henüz gelen meydan okuma yok.',
                            showActions: true,
                          ),
                          _ChallengeList(
                            challenges: challengeState.outgoing,
                            childId: childId,
                            emptyText: 'Henüz gönderilen meydan okuma yok.',
                            showActions: true,
                          ),
                          _ChallengeList(
                            challenges: challengeState.history,
                            childId: childId,
                            emptyText: 'Henüz geçmiş meydan okuma yok.',
                          ),
                          const _FriendsChallengeTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Tab _challengeTab({
    required IconData icon,
    required String label,
    int count = 0,
  }) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: 3),
            Text(label),
            if (count > 0) _badge(count),
          ],
        ),
      ),
    );
  }

  Widget _badge(int count) => Container(
    margin: const EdgeInsets.only(left: 4),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: Colors.redAccent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      '$count',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

// ── Tab: Arkadaşlar (meydan okuma gönder) ────────────────────────────────────

class _FriendsChallengeTab extends ConsumerStatefulWidget {
  const _FriendsChallengeTab();

  @override
  ConsumerState<_FriendsChallengeTab> createState() =>
      _FriendsChallengeTabState();
}

class _FriendsChallengeTabState extends ConsumerState<_FriendsChallengeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendProvider.notifier).loadFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fs = ref.watch(friendProvider);
    final accepted = fs.friends.where((f) => f.status == 1).toList();

    if (fs.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (accepted.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icon/dashboard_friends.png',
                width: 76,
                height: 76,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                'Henüz arkadaşın yok.\nArkadaş ekleyerek meydan okuyabilirsin.',
                style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.push('/friends'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A5ACD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+ Arkadaş Ekle',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: accepted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final f = accepted[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: _glassCard(),
          child: Row(
            children: [
              _ChallengeAvatar(
                avatarValue: f.avatarImageUrl,
                name: f.name,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  f.name,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showChallengeSendDialog(
                  context,
                  challengeeId: f.childId,
                  challengeeName: f.name,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A5ACD), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A5ACD).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icon/dashboard_challenge.png',
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Meydan Oku',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Boş liste mesajı ─────────────────────────────────────────────────────────

class _ChallengeList extends ConsumerWidget {
  final List<ChallengeDto> challenges;
  final String childId;
  final String emptyText;
  final bool showActions;

  const _ChallengeList({
    required this.challenges,
    required this.childId,
    required this.emptyText,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (challenges.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: challenges.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => ChallengeCard(
        challenge: challenges[i],
        childId: childId,
        showActions: showActions,
      ),
    );
  }
}

// ── ChallengeCard ────────────────────────────────────────────────────────────

class ChallengeCard extends ConsumerStatefulWidget {
  final ChallengeDto challenge;
  final String childId;
  final bool showActions;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.childId,
    this.showActions = false,
  });

  @override
  ConsumerState<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends ConsumerState<ChallengeCard> {
  bool _busy = false;

  ChallengeDto get c => widget.challenge;

  @override
  Widget build(BuildContext context) {
    final isChallenger = c.challengerId == widget.childId;
    final opponentName = isChallenger ? c.challengeeName : c.challengerName;
    final opponentAvatar = isChallenger
        ? c.challengeeAvatarUrl
        : c.challengerAvatarUrl;

    return Container(
      decoration: _glassCard(),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Başlık satırı ────────────────────────────────────
            Row(
              children: [
                _ChallengeAvatar(
                  avatarValue: opponentAvatar,
                  name: opponentName,
                  size: 44,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isChallenger
                            ? 'Sen → $opponentName'
                            : '$opponentName → Sen',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            c.contentLabel,
                            style: GoogleFonts.nunito(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          if (c.hasDifficultyBadge)
                            _DifficultyBadge(label: c.difficultyLabel),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusChip(c.status, widget.childId, c),
              ],
            ),
            const SizedBox(height: 8),

            // ── Skor / Sonuç satırı ──────────────────────────────
            if (c.status == ChallengeStatus.completed &&
                c.resultMessage != null)
              _CompletedChallengeResult(
                resultMessage: c.resultMessage!,
                myScore: isChallenger ? c.challengerScore : c.challengeeScore,
                opponentScore: isChallenger
                    ? c.challengeeScore
                    : c.challengerScore,
                opponentName: opponentName,
                totalQuestions: c.totalQuestions,
              ),

            // ── Son tarih ────────────────────────────────────────
            if (c.status.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Son süre · ${DateFormat('d MMM HH:mm', 'tr_TR').format(c.expiresAt.toLocal())}',
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Bağlam metni (aktif durumlar için) ─────────────
            if (c.status.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0x554E68D8), Color(0x553EAFB5)],
                    ),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _contextualStatusIcon,
                        color: Colors.white,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          _contextualStatus,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Kabul / Reddet (sadece gelen + pending + challengee) ──
            if (widget.showActions &&
                c.status == ChallengeStatus.pending &&
                !isChallenger)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Reddet',
                        icon: Icons.close_rounded,
                        color: Colors.redAccent,
                        busy: _busy,
                        onTap: () => _respond(accept: false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: 'Kabul Et',
                        assetPath: 'assets/icon/dashboard_challenge.png',
                        color: const Color(0xFF43A047),
                        busy: _busy,
                        onTap: () => _respond(accept: true),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Oyna (sıra bu kişide ise) ─────────────────────────
            if (_canPlay)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: _ActionButton(
                    label: 'Oyna',
                    icon: Icons.play_arrow_rounded,
                    color: const Color(0xFF7C4DFF),
                    busy: _busy,
                    onTap: _startQuiz,
                  ),
                ),
              ),

            // ── Hatırlat (sırası rakipteyse) ───────────────────────
            if (_canRemind)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: _ActionButton(
                    label: c.canSendReminder
                        ? 'Hatırlat'
                        : 'Bugün hatırlatıldı',
                    icon: c.canSendReminder
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_paused_rounded,
                    color: c.canSendReminder
                        ? const Color(0xFFFF8C00)
                        : Colors.grey.shade600,
                    busy: _busy,
                    onTap: c.canSendReminder ? _sendReminder : () {},
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _canPlay {
    // Sadece aktif ve kabul edilmiş challenge'larda oynana bilir
    if (!c.status.isActive) return false;
    if (c.status == ChallengeStatus.pending) return false;
    final isChallenger = c.challengerId == widget.childId;
    // Kişi zaten oynadıysa (score gönderildiyse) tekrar oynatma
    if (isChallenger) {
      return c.challengerScore == null;
    } else {
      return c.challengeeScore == null;
    }
  }

  /// Kullanıcıya özel durum metni
  String get _contextualStatus {
    final isChallenger = c.challengerId == widget.childId;
    switch (c.status) {
      case ChallengeStatus.pending:
        return isChallenger ? 'Cevap bekleniyor' : 'Seni bekliyor';
      case ChallengeStatus.challengeeAccepted:
        if (isChallenger) {
          return c.challengerScore != null
              ? 'Sen oynadın, rakip bekleniyor'
              : 'Sıra sende';
        } else {
          return c.challengeeScore != null
              ? 'Sen oynadın, rakip bekleniyor'
              : 'Sıra sende';
        }
      case ChallengeStatus.challengerDone:
        return isChallenger ? 'Sen oynadın, rakip bekleniyor' : 'Sıra sende';
      case ChallengeStatus.completed:
        return c.resultMessage ?? 'Tamamlandı';
      case ChallengeStatus.expired:
        return 'Süresi Doldu';
      case ChallengeStatus.declined:
        return 'Reddedildi';
    }
  }

  IconData get _contextualStatusIcon {
    final isChallenger = c.challengerId == widget.childId;
    switch (c.status) {
      case ChallengeStatus.pending:
        return isChallenger
            ? Icons.hourglass_top_rounded
            : Icons.mark_email_unread_rounded;
      case ChallengeStatus.challengeeAccepted:
        final myScore = isChallenger ? c.challengerScore : c.challengeeScore;
        return myScore != null
            ? Icons.hourglass_top_rounded
            : Icons.sports_esports_rounded;
      case ChallengeStatus.challengerDone:
        return isChallenger
            ? Icons.hourglass_top_rounded
            : Icons.sports_esports_rounded;
      case ChallengeStatus.completed:
        return Icons.check_circle_rounded;
      case ChallengeStatus.expired:
        return Icons.timer_off_rounded;
      case ChallengeStatus.declined:
        return Icons.cancel_rounded;
    }
  }

  Future<void> _respond({required bool accept}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final notifier = ref.read(challengeNotifierProvider.notifier);
      if (accept) {
        await notifier.acceptChallenge(c.id);
      } else {
        await notifier.declineChallenge(c.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startQuiz() {
    if (c.competitionType != null) {
      context.push('/quiz/adult-challenge/${c.id}', extra: c);
      return;
    }
    context.push(
      '/quiz/challenge/${c.id}',
      extra: {'levelId': c.levelId ?? '', 'challengeId': c.id},
    );
  }

  /// Oyuncu kendi turunu tamamladıysa, henüz oynamamış rakibine hatırlatma
  /// gönderebilir. Her tarafın 2 saatlik hatırlatma sınırı ayrıdır.
  bool get _canRemind {
    if (!c.status.isActive) return false;
    final isChallenger = c.challengerId == widget.childId;
    if (isChallenger) {
      return c.challengeeScore == null;
    }
    return c.challengeeScore != null && c.challengerScore == null;
  }

  String get _reminderRecipientName =>
      c.challengerId == widget.childId ? c.challengeeName : c.challengerName;

  Future<void> _sendReminder() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(challengeNotifierProvider.notifier).remindChallenge(c.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔔 $_reminderRecipientName adlı oyuncuya hatırlatma gönderildi!',
            ),
            backgroundColor: const Color(0xFFFF8C00),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('message')
            ? e
                  .toString()
                  .split('message')[1]
                  .replaceAll(RegExp(r'[":{}]'), '')
                  .trim()
            : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ── Yardımcı widgetlar ───────────────────────────────────────────────────────

class _ChallengeAvatar extends StatelessWidget {
  final String? avatarValue;
  final String name;
  final double size;

  const _ChallengeAvatar({
    required this.avatarValue,
    required this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
      color: const Color(0xFF7867D9),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: GoogleFonts.luckiestGuy(
          color: Colors.white,
          fontSize: size * 0.38,
        ),
      ),
    );

    final value = avatarValue?.trim();
    Widget content = fallback();
    if (value != null && value.isNotEmpty) {
      final uri = Uri.tryParse(value);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        content = Image.network(
          value,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback(),
        );
      } else {
        final assetPath = value.startsWith('assets/')
            ? value
            : 'assets/avatar/characters/$value.png';
        content = Container(
          color: const Color(0xFFE8E5FF),
          padding: EdgeInsets.all(size * 0.07),
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            errorBuilder: (_, _, _) => fallback(),
          ),
        );
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.72),
          width: 2,
        ),
      ),
      child: ClipOval(child: content),
    );
  }
}

class _CompletedChallengeResult extends StatelessWidget {
  final String resultMessage;
  final int? myScore;
  final int? opponentScore;
  final String opponentName;
  final int totalQuestions;

  const _CompletedChallengeResult({
    required this.resultMessage,
    required this.myScore,
    required this.opponentScore,
    required this.opponentName,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = resultMessage.toLowerCase();
    final isWin = normalized.contains('kazan') || resultMessage.contains('🏆');
    final isDraw =
        normalized.contains('beraber') || resultMessage.contains('🤝');
    final accent = isWin
        ? const Color(0xFF45C77B)
        : isDraw
        ? const Color(0xFF63B4FF)
        : const Color(0xFFFF6B7A);
    final label = isWin
        ? 'Kazandın'
        : isDraw
        ? 'Berabere'
        : 'Bu kez rakibin kazandı';
    final icon = isWin
        ? Icons.emoji_events_rounded
        : isDraw
        ? Icons.handshake_rounded
        : Icons.replay_rounded;

    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.30),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.58)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Sonuç',
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          if (myScore != null && opponentScore != null) ...[
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _CompactScore(
                    label: 'Sen',
                    score: myScore!,
                    totalQuestions: totalQuestions,
                    isWinner: myScore! > opponentScore!,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Container(
                    width: 27,
                    height: 27,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'VS',
                      style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _CompactScore(
                    label: opponentName,
                    score: opponentScore!,
                    totalQuestions: totalQuestions,
                    isWinner: opponentScore! > myScore!,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactScore extends StatelessWidget {
  final String label;
  final int score;
  final int totalQuestions;
  final bool isWinner;

  const _CompactScore({
    required this.label,
    required this.score,
    required this.totalQuestions,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFF45C77B).withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isWinner
              ? const Color(0xFF75E5A2).withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            '$score/$totalQuestions',
            style: GoogleFonts.nunito(
              color: isWinner ? const Color(0xFF9AF2BC) : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? assetPath;
  final Color color;
  final bool busy;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    this.icon,
    this.assetPath,
    required this.color,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: busy
              ? const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (assetPath != null)
                      Image.asset(assetPath!, width: 21, height: 21)
                    else if (icon != null)
                      Icon(icon, color: Colors.white, size: 19),
                    if (assetPath != null || icon != null)
                      const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
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

Widget _statusChip(ChallengeStatus status, String childId, ChallengeDto c) {
  final String label;
  final Color color;
  final IconData icon;
  final isChallenger = c.challengerId == childId;

  switch (status) {
    case ChallengeStatus.pending:
      label = isChallenger ? 'Cevap bekleniyor' : 'Seni bekliyor';
      color = const Color(0xFFE67E22);
      icon = Icons.schedule_rounded;
    case ChallengeStatus.challengeeAccepted:
      final myScore = isChallenger ? c.challengerScore : c.challengeeScore;
      label = myScore != null ? 'Rakip bekleniyor' : 'Sıra Sende!';
      color = myScore != null
          ? const Color(0xFF1976D2)
          : const Color(0xFF9C27B0);
      icon = myScore != null
          ? Icons.hourglass_top_rounded
          : Icons.sports_esports_rounded;
    case ChallengeStatus.challengerDone:
      label = isChallenger ? 'Rakip bekleniyor' : 'Sıra Sende!';
      color = isChallenger ? const Color(0xFF1976D2) : const Color(0xFF9C27B0);
      icon = isChallenger
          ? Icons.hourglass_top_rounded
          : Icons.sports_esports_rounded;
    case ChallengeStatus.completed:
      label = 'Tamamlandı';
      color = const Color(0xFF5368C4);
      icon = Icons.check_circle_rounded;
    case ChallengeStatus.expired:
      label = 'Süresi Doldu';
      color = const Color(0xFF757575);
      icon = Icons.timer_off_rounded;
    case ChallengeStatus.declined:
      label = 'Reddedildi';
      color = const Color(0xFFE53935);
      icon = Icons.cancel_rounded;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

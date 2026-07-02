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

// ── Tasarım sabitleri ────────────────────────────────────────────────────────

const _kGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF4FACFE), Color(0xFF7B6FCD), Color(0xFF9B8FE8)],
);

BoxDecoration _glassCard({double radius = 16}) => BoxDecoration(
      color: const Color(0xFF1A0E52).withOpacity(0.22),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.30)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        )
      ],
    );

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
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        '⚔️ Meydan Okumalar',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: () =>
                          ref.read(challengeNotifierProvider.notifier).loadAll(),
                    ),
                  ],
                ),
              ),
              // ── Tabs ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: const Color(0xFF6A5ACD),
                    unselectedLabelColor: Colors.white,
                    labelStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800, fontSize: 11),
                    unselectedLabelStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600, fontSize: 11),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📥'),
                              const SizedBox(width: 4),
                              const Text('Gelen'),
                              if (challengeState.incoming.isNotEmpty)
                                _badge(challengeState.incoming.length),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📤'),
                              const SizedBox(width: 4),
                              const Text('Gönderilen'),
                              if (challengeState.outgoing.isNotEmpty)
                                _badge(challengeState.outgoing.length),
                            ],
                          ),
                        ),
                      ),
                      const Tab(text: '📜 Geçmiş'),
                      const Tab(text: '👥 Arkadaşlar'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // ── Tab Views ─────────────────────────────────────────
              Expanded(
                child: challengeState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
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
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
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
    final fs       = ref.watch(friendProvider);
    final accepted = fs.friends.where((f) => f.status == 1).toList();

    if (fs.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    if (accepted.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👥', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                'Henüz arkadaşın yok.\nArkadaş ekleyerek meydan okuyabilirsin.',
                style: GoogleFonts.nunito(
                    color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.push('/friends'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A5ACD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+ Arkadaş Ekle',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
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
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final f = accepted[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: _glassCard(),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF6A5ACD).withOpacity(0.4),
                backgroundImage: f.avatarImageUrl != null
                    ? NetworkImage(f.avatarImageUrl!)
                    : null,
                child: f.avatarImageUrl == null
                    ? Text(
                        f.name.isNotEmpty ? f.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )
                    : null,
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
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A5ACD), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A5ACD).withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚔️', style: TextStyle(fontSize: 14)),
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
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
    final opponentAvatar =
        isChallenger ? c.challengeeAvatarUrl : c.challengerAvatarUrl;

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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  backgroundImage: opponentAvatar != null
                      ? NetworkImage(opponentAvatar)
                      : null,
                  child: opponentAvatar == null
                      ? Text(opponentName.isNotEmpty ? opponentName[0] : '?',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold,
                              color: Colors.white))
                      : null,
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
                      Text(
                        '${c.subjectName} · ${c.levelName}',
                        style: GoogleFonts.nunito(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _statusChip(c.status, widget.childId, c),
              ],
            ),
            const SizedBox(height: 8),

            // ── Skor / Sonuç satırı ──────────────────────────────
            if (c.status == ChallengeStatus.completed && c.resultMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _resultBgColor(c.resultMessage!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  c.resultMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),

            // ── Son tarih ────────────────────────────────────────
            if (c.status.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: Colors.white54, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Son: ${DateFormat('d MMM HH:mm', 'tr_TR').format(c.expiresAt.toLocal())}',
                      style: GoogleFonts.nunito(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),

            // ── Bağlam metni (aktif durumlar için) ─────────────
            if (c.status.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _contextualStatus,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
                        color: Colors.redAccent,
                        busy: _busy,
                        onTap: () => _respond(accept: false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: '⚔️ Kabul Et',
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
                    label: '🎮 Oyna',
                    color: const Color(0xFF7C4DFF),
                    busy: _busy,
                    onTap: _startQuiz,
                  ),
                ),
              ),

            // ── Hatırlat (sadece challenger, rakip oynamadıysa) ───
            if (_canRemind)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: _ActionButton(
                    label: c.canSendReminder
                        ? '🔔 Hatırlat'
                        : '🔔 Bugün hatırlatıldı',
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
              : 'Sıra Sende! 🎮';
        } else {
          return c.challengeeScore != null
              ? 'Sen oynadın, rakip bekleniyor'
              : 'Sıra Sende! 🎮';
        }
      case ChallengeStatus.challengerDone:
        return isChallenger ? 'Sen oynadın, rakip bekleniyor' : 'Sıra Sende! 🎮';
      case ChallengeStatus.completed:
        return c.resultMessage ?? 'Tamamlandı';
      case ChallengeStatus.expired:
        return 'Süresi Doldu';
      case ChallengeStatus.declined:
        return 'Reddedildi';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startQuiz() {
    context.push('/quiz/challenge/${c.id}',
        extra: {'levelId': c.levelId, 'challengeId': c.id});
  }

  /// Challenger, challengee henüz oynamadıysa hatırlatma butonunu görür.
  bool get _canRemind {
    if (c.challengerId != widget.childId) return false;  // sadece meydan okuyan
    if (!c.status.isActive) return false;
    // ChallengerDone veya challengee henüz oynamamışsa
    return c.challengeeScore == null;
  }

  Future<void> _sendReminder() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(challengeNotifierProvider.notifier).remindChallenge(c.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔔 ${c.challengeeName}\'a hatırlatma gönderildi!'),
            backgroundColor: const Color(0xFFFF8C00),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('message')
            ? e.toString().split('message')[1].replaceAll(RegExp(r'[":{}]'), '').trim()
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

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool busy;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
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
                    child:
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }
}

Widget _statusChip(ChallengeStatus status, String childId, ChallengeDto c) {
  final String label;
  final Color color;
  final isChallenger = c.challengerId == childId;

  switch (status) {
    case ChallengeStatus.pending:
      label = isChallenger ? 'Cevap bekleniyor' : 'Seni bekliyor';
      color = const Color(0xFFE67E22);
    case ChallengeStatus.challengeeAccepted:
      final myScore = isChallenger ? c.challengerScore : c.challengeeScore;
      label = myScore != null ? 'Rakip bekleniyor' : 'Sıra Sende!';
      color = myScore != null
          ? const Color(0xFF1976D2)
          : const Color(0xFF9C27B0);
    case ChallengeStatus.challengerDone:
      label = isChallenger ? 'Rakip bekleniyor' : 'Sıra Sende!';
      color = isChallenger
          ? const Color(0xFF1976D2)
          : const Color(0xFF9C27B0);
    case ChallengeStatus.completed:
      label = 'Tamamlandı';
      color = const Color(0xFF43A047);
    case ChallengeStatus.expired:
      label = 'Süresi Doldu';
      color = const Color(0xFF757575);
    case ChallengeStatus.declined:
      label = 'Reddedildi';
      color = const Color(0xFFE53935);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: const TextStyle(
          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

Color _resultBgColor(String msg) {
  final lower = msg.toLowerCase();
  if (lower.contains('kazan') || msg.contains('🏆')) {
    return const Color(0xFF43A047);
  }
  if (lower.contains('beraber') || msg.contains('🤝')) {
    return const Color(0xFF1976D2);
  }
  return const Color(0xFFE53935);
}

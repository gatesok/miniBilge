import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge_models.dart';
import '../../child_profile/providers/selected_child_provider.dart';

// ── Tasarım sabitleri ────────────────────────────────────────────────────────

const _kGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
);

BoxDecoration _glassCard({double radius = 16}) => BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.45)),
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
    _tabs = TabController(length: 3, vsync: this);
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
                        fontWeight: FontWeight.w800, fontSize: 13),
                    unselectedLabelStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📥'),
                            const SizedBox(width: 4),
                            const Text('Gelen'),
                            if (challengeState.incoming.isNotEmpty)
                              _badge(challengeState.incoming.length),
                          ],
                        ),
                      ),
                      const Tab(text: '📤 Gönderilen'),
                      const Tab(text: '📜 Geçmiş'),
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
                          ),
                          _ChallengeList(
                            challenges: challengeState.history,
                            childId: childId,
                            emptyText: 'Henüz geçmiş meydan okuma yok.',
                          ),
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
                _statusChip(c.status),
              ],
            ),
            const SizedBox(height: 8),

            // ── Skor / Sonuç satırı ──────────────────────────────
            if (c.status == ChallengeStatus.completed && c.resultMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
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

            // ── Eylem butonları (sadece gelen + pending) ─────────
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
                        color: Colors.redAccent.withOpacity(0.8),
                        busy: _busy,
                        onTap: () => _respond(accept: false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: '⚔️ Kabul Et',
                        color: const Color(0xFF4CAF50).withOpacity(0.85),
                        busy: _busy,
                        onTap: () => _respond(accept: true),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Quiz başlat (kabul ettikten sonra ya da challenger ise) ──
            if (_canPlay)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: _ActionButton(
                    label: '🎮 Oyna',
                    color: const Color(0xFF7C4DFF).withOpacity(0.85),
                    busy: _busy,
                    onTap: _startQuiz,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _canPlay {
    final isChallenger = c.challengerId == widget.childId;
    if (isChallenger) {
      return c.status == ChallengeStatus.challengeeAccepted;
    } else {
      return c.status == ChallengeStatus.challengeeAccepted;
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

Widget _statusChip(ChallengeStatus status) {
  final (label, color) = switch (status) {
    ChallengeStatus.pending            => ('Bekliyor', Colors.orange),
    ChallengeStatus.challengeeAccepted => ('Kabul Edildi', Colors.blue),
    ChallengeStatus.challengerDone     => ('Sıra Onda', const Color(0xFF9C27B0)),
    ChallengeStatus.completed          => ('Tamamlandı', Colors.green),
    ChallengeStatus.expired            => ('Süresi Doldu', Colors.grey),
    ChallengeStatus.declined           => ('Reddedildi', Colors.red),
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.25),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.6)),
    ),
    child: Text(
      label,
      style: TextStyle(
          color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/friend_provider.dart';
import '../models/friend_models.dart';
import '../../education/providers/subject_provider.dart';
import '../../challenge/widgets/challenge_send_dialog.dart';

// ── Tasarım sabitleri ────────────────────────────────────────────────────────

const _kGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
);

BoxDecoration _glassCard({double radius = 20}) => BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.45)),
    );

// ── Ana Ekran ────────────────────────────────────────────────────────────────

class FriendsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const FriendsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabs;
  Timer? _onlineTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabs = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final n = ref.read(friendProvider.notifier);
      n.connectHub();
      await n.loadFriends();
      n.loadOnlineStatuses();
      n.loadPendingRequests();
      n.loadPendingInvites();
      n.syncSentInvites();
      // Her 60 saniyede online durumunu yenile
      _onlineTimer = Timer.periodic(const Duration(seconds: 60), (_) {
        ref.read(friendProvider.notifier).loadOnlineStatuses();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Hub yeniden bağlanıp RegisterPresence gönderene kadar bekle
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          ref.read(friendProvider.notifier).loadOnlineStatuses();
          ref.read(friendProvider.notifier).syncSentInvites();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabs.dispose();
    _onlineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state       = ref.watch(friendProvider);
    final reqCount    = state.pendingRequests.length;
    final inviteCount = state.pendingInvites.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _kGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 22),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'ARKADAŞLAR',
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 26,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(2, 2))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Tab Bar ──────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, fontSize: 12),
                  unselectedLabelStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600, fontSize: 12),
                  labelColor: const Color(0xFF5C3BC7),
                  unselectedLabelColor: Colors.white,
                  tabs: [
                    const Tab(text: 'Arkadaşlar'),
                    Tab(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('İstekler'),
                        if (reqCount > 0) ...[
                          const SizedBox(width: 4),
                          _TabBadge(reqCount, const Color(0xFFFF5252)),
                        ],
                      ]),
                    ),
                    Tab(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Davetler'),
                        if (inviteCount > 0) ...[
                          const SizedBox(width: 4),
                          _TabBadge(inviteCount, const Color(0xFFFFAB00)),
                        ],
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Tab İçerikleri ───────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _FriendsTab(state: state),
                    _RequestsTab(state: state),
                    _InvitesTab(state: state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

List<Color> _subjectColors(String name) {
  switch (name.toLowerCase()) {
    case 'matematik':
      return const [Color(0xFF29B6F6), Color(0xFF0277BD)];
    case 'i̇ngilizce':
    case 'ingilizce':
      return const [Color(0xFF26A69A), Color(0xFF00695C)];
    default:
      return const [Color(0xFF7E57C2), Color(0xFF4527A0)];
  }
}

String _subjectEmoji(String name) {
  switch (name.toLowerCase()) {
    case 'matematik':  return '🧮';
    case 'i̇ngilizce':
    case 'ingilizce': return '🇬🇧';
    default:          return '📚';
  }
}

// ── Tab: Arkadaşlar ──────────────────────────────────────────────────────────

class _FriendsTab extends ConsumerStatefulWidget {
  final FriendState state;
  const _FriendsTab({required this.state});

  @override
  ConsumerState<_FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends ConsumerState<_FriendsTab> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state    = widget.state;
    final notifier = ref.read(friendProvider.notifier);

    return Column(
      children: [
        // Arama çubuğu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.6)),
                ),
                child: TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.nunito(
                      color: const Color(0xFF2D2060), fontWeight: FontWeight.w700),
                  cursorColor: const Color(0xFF7B61FF),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: 'MB-XXXXXX arkadaş kodu',
                    hintStyle: GoogleFonts.nunito(
                        color: const Color(0xFF9B9BC0), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF9B9BC0)),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  onSubmitted: (_) => notifier.searchByCode(_codeCtrl.text),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => notifier.searchByCode(_codeCtrl.text),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF9B59B6), Color(0xFF7B61FF)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF7B61FF).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Text('Ara',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
            ),
          ]),
        ),

        // Arama sonucu
        if (state.searchResult != null) ...[
          const SizedBox(height: 10),
          _SearchResultCard(
            result: state.searchResult!,
            onSend: () => notifier.sendRequest(state.searchResult!.friendCode),
            onDismiss: notifier.clearSearch,
          ),
        ],

        if (state.error != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Text(state.error!,
                  style: GoogleFonts.nunito(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Arkadaş listesi
        if (state.isLoading && state.friends.isEmpty)
          const Expanded(
              child: Center(
                  child: CircularProgressIndicator(color: Colors.white)))
        else if (state.friends.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👥', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text('Henüz arkadaşın yok.',
                      style: GoogleFonts.luckiestGuy(
                          color: Colors.white, fontSize: 20,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(1, 1))
                          ])),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Yukarıdan arkadaş kodunu girerek ekleyebilirsin!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF7B61FF),
              onRefresh: () => ref.read(friendProvider.notifier).loadFriends(),
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: state.friends.length,
                itemBuilder: (ctx, i) =>
                    _FriendTile(friend: state.friends[i]),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Tab: İstekler ─────────────────────────────────────────────────────────────

class _RequestsTab extends ConsumerWidget {
  final FriendState state;
  const _RequestsTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📬', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 10),
            Text('Bekleyen istek yok.',
                style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.pendingRequests.length,
      itemBuilder: (ctx, i) {
        final req = state.pendingRequests[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: _glassCard(),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _AvatarWidget(name: req.name, avatarKey: req.avatarImageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.name,
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      if (req.friendCode.isNotEmpty)
                        Text(req.friendCode,
                            style: GoogleFonts.nunito(
                                color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                _ActionBtn(
                  icon: Icons.check_rounded,
                  color: const Color(0xFF1DB954),
                  onTap: () => ref
                      .read(friendProvider.notifier)
                      .respondRequest(req.friendshipId, true),
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  icon: Icons.close_rounded,
                  color: const Color(0xFFFF3B30),
                  onTap: () => ref
                      .read(friendProvider.notifier)
                      .respondRequest(req.friendshipId, false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Tab: Davetler ─────────────────────────────────────────────────────────────

class _InvitesTab extends ConsumerWidget {
  final FriendState state;
  const _InvitesTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.pendingInvites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 10),
            Text('Bekleyen davet yok.',
                style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.pendingInvites.length,
      itemBuilder: (ctx, i) {
        final inv      = state.pendingInvites[i];
        final timeLeft = inv.expiresAt.difference(DateTime.now());
        final expired  = timeLeft.isNegative;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: _glassCard(),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    _AvatarWidget(
                        name: inv.inviterName, avatarKey: inv.inviterAvatar),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inv.inviterName,
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                          if (inv.subjectName != null)
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7B61FF).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(inv.subjectName!,
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11)),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            expired
                                ? '⏰ Süre doldu'
                                : '⏳ ${timeLeft.inSeconds}s kaldı',
                            style: GoogleFonts.nunito(
                                color: expired
                                    ? Colors.red.shade200
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!expired) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => ref
                            .read(friendProvider.notifier)
                            .respondMatchInvite(inv.id, false),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Text('Reddet',
                                style: GoogleFonts.nunito(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await ref
                              .read(friendProvider.notifier)
                              .respondMatchInvite(inv.id, true);
                          if (result?.matchSessionId != null &&
                              context.mounted) {
                            context.push(
                                '/match/arena?matchId=${result!.matchSessionId}');
                          }
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFFFF9800),
                              Color(0xFFFFAB00)
                            ]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFFFF9800)
                                      .withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Center(
                            child: Text('⚡ Yarışa Katıl!',
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── FriendTile ────────────────────────────────────────────────────────────────

class _FriendTile extends ConsumerWidget {
  final FriendDto friend;
  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineStatuses = ref.watch(friendProvider.select((s) => s.onlineStatuses));
    final sentPending = ref.watch(friendProvider.select((s) => s.sentPendingInvites));
    final isOnline = onlineStatuses[friend.childId];
    final isPending = sentPending.containsKey(friend.childId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: _glassCard(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _AvatarWidget(name: friend.name, avatarKey: friend.avatarImageUrl, isOnline: isOnline),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend.name,
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  Text(friend.friendCode,
                      style: GoogleFonts.nunito(
                          color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            // Yarışa davet et
            if (isPending)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⏳', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text('Bekliyor',
                            style: GoogleFonts.nunito(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => ref
                        .read(friendProvider.notifier)
                        .cancelInvite(friend.childId),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.redAccent, size: 16),
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: () async {
                  final subjectsAsync = ref.read(subjectListProvider);
                  final subjects = subjectsAsync.valueOrNull ?? [];
                  String? selectedSubjectId;
                  if (subjects.isNotEmpty && context.mounted) {
                    selectedSubjectId = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _SubjectSheet(subjects: subjects),
                    );
                    if (selectedSubjectId == null) return;
                  }
                  if (!context.mounted) return;
                  final result = await ref
                      .read(friendProvider.notifier)
                      .sendMatchInvite(friend.childId,
                          subjectId: selectedSubjectId);
                  if (context.mounted && result == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Davet gönderilemedi'),
                      backgroundColor: Colors.red.shade700,
                    ));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF9800)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text('⚡', style: TextStyle(fontSize: 18)),
                ),
              ),
            const SizedBox(width: 6),
            // Async meydan okuma butonu
            GestureDetector(
              onTap: () => showChallengeSendDialog(
                context,
                challengeeId: friend.childId,
                challengeeName: friend.name,
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6A5ACD), Color(0xFF9C27B0)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6A5ACD).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text('⚔️', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
            // Menü
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              color: const Color(0xFF2D2060),
              onSelected: (v) {
                if (v == 'remove') {
                  ref
                      .read(friendProvider.notifier)
                      .removeFriend(friend.friendshipId);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'remove',
                  child: Row(children: [
                    const Icon(Icons.person_remove,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text('Arkadaşlıktan çıkar',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── SearchResultCard ─────────────────────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  final FriendSearchResultDto result;
  final VoidCallback onSend;
  final VoidCallback onDismiss;

  const _SearchResultCard({
    required this.result,
    required this.onSend,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final alreadyFriend = result.friendshipStatus == 1;
    final pending       = result.friendshipStatus == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _AvatarWidget(
                name: result.name, avatarKey: result.avatarImageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.name,
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  Text(result.friendCode,
                      style: GoogleFonts.nunito(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            if (!alreadyFriend && !pending)
              GestureDetector(
                onTap: onSend,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF2ECC71), Color(0xFF27AE60)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Ekle',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                ),
              )
            else
              Text(alreadyFriend ? 'Arkadaş ✓' : 'İstek gönderildi',
                  style: GoogleFonts.nunito(
                      color: Colors.white70, fontSize: 12,
                      fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Konu Seçim Bottom Sheet ───────────────────────────────────────────────────

class _SubjectSheet extends StatelessWidget {
  final List subjects;
  const _SubjectSheet({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1B4B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text('Hangi derste yarışacaksınız?',
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17)),
            const SizedBox(height: 16),
            ...subjects.map((s) {
              final colors = _subjectColors(s.name as String);
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(s.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Text(_subjectEmoji(s.name as String),
                              style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 16),
                          Text(s.name as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Yardımcı Widgetlar ────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final String name;
  final String? avatarKey;
  final bool? isOnline;
  const _AvatarWidget({required this.name, this.avatarKey, this.isOnline});

  @override
  Widget build(BuildContext context) {
    final avatar = _buildAvatar();
    if (isOnline == null) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: isOnline! ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final key = avatarKey;
    if (key != null && key.startsWith('http')) {
      return CircleAvatar(
          backgroundImage: NetworkImage(key), radius: 24);
    }
    if (key != null && key.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white.withOpacity(0.2),
        child: ClipOval(
          child: Image.asset(
            'assets/avatar/characters/$key.png',
            width: 48, height: 48, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFF7B61FF).withOpacity(0.6),
      child: _fallback(),
    );
  }

  Widget _fallback() => Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18),
      );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.45),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _TabBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _TabBadge(this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(10)),
      child: Text('$count',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/friend_provider.dart';
import '../models/friend_models.dart';
import '../../education/providers/subject_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(friendProvider.notifier);
      notifier.connectHub();
      notifier.loadFriends();
      notifier.loadPendingRequests();
      notifier.loadPendingInvites();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendProvider);
    final cs    = Theme.of(context).colorScheme;

    // Match invite badge
    final inviteCount = state.pendingInvites.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkadaşlar'),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            const Tab(text: 'Arkadaşlar'),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('İstekler'),
                if (state.pendingRequests.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  _Badge(state.pendingRequests.length, cs.error),
                ],
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Davetler'),
                if (inviteCount > 0) ...[
                  const SizedBox(width: 4),
                  _Badge(inviteCount, cs.primary),
                ],
              ]),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _FriendsTab(state: state),
          _RequestsTab(state: state),
          _InvitesTab(state: state),
        ],
      ),
    );
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
        // Arkadaş ara / ekle
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'MB-XXXXXX arkadaş kodu',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => notifier.searchByCode(_codeCtrl.text),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => notifier.searchByCode(_codeCtrl.text),
              child: const Text('Ara'),
            ),
          ]),
        ),

        // Arama sonucu
        if (state.searchResult != null)
          _SearchResultCard(
            result: state.searchResult!,
            onSend: () => notifier.sendRequest(state.searchResult!.friendCode),
            onDismiss: notifier.clearSearch,
          ),

        if (state.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),

        const Divider(height: 1),

        // Arkadaş listesi
        if (state.isLoading && state.friends.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (state.friends.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Henüz arkadaşın yok.\nYukarıdan arkadaş kodunu girerek ekleyebilirsin!',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(friendProvider.notifier).loadFriends(),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.friends.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                itemBuilder: (ctx, i) => _FriendTile(friend: state.friends[i]),
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
      return const Center(
        child: Text('Bekleyen arkadaşlık isteği yok.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.pendingRequests.length,
      itemBuilder: (ctx, i) {
        final req = state.pendingRequests[i];
        return Card(
          child: ListTile(
            leading: _Avatar(name: req.name, url: req.avatarImageUrl),
            title: Text(req.name),
            subtitle: Text(req.friendCode.isEmpty ? '' : req.friendCode),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => ref.read(friendProvider.notifier).respondRequest(req.friendshipId, true),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => ref.read(friendProvider.notifier).respondRequest(req.friendshipId, false),
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
      return const Center(
        child: Text('Bekleyen yarış daveti yok.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.pendingInvites.length,
      itemBuilder: (ctx, i) {
        final inv = state.pendingInvites[i];
        final timeLeft = inv.expiresAt.difference(DateTime.now());
        final expired  = timeLeft.isNegative;
        return Card(
          child: ListTile(
            leading: _Avatar(name: inv.inviterName, url: inv.inviterAvatar),
            title: Text('${inv.inviterName} seni yarışa davet etti!'),
            subtitle: Text(expired
                ? 'Süre doldu'
                : inv.subjectName != null
                    ? '${inv.subjectName} • ${timeLeft.inSeconds}s kaldı'
                    : '${timeLeft.inSeconds}s kaldı'),
            trailing: expired
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.flash_on, color: Colors.orange),
                        tooltip: 'Kabul et',
                        onPressed: () async {
                          final result = await ref
                              .read(friendProvider.notifier)
                              .respondMatchInvite(inv.id, true);
                          if (result?.matchSessionId != null && context.mounted) {
                            context.push('/match/arena?matchId=${result!.matchSessionId}');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Reddet',
                        onPressed: () => ref
                            .read(friendProvider.notifier)
                            .respondMatchInvite(inv.id, false),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _FriendTile extends ConsumerWidget {
  final FriendDto friend;
  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _Avatar(name: friend.name, url: friend.avatarImageUrl),
      title: Text(friend.name),
      subtitle: Text(friend.friendCode),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: const Icon(Icons.sports_esports),
          tooltip: 'Yarışa davet et',
          onPressed: () async {
            // Konu seç
            final subjectsAsync = ref.read(subjectListProvider);
            final subjects = subjectsAsync.valueOrNull ?? [];

            String? selectedSubjectId;
            if (subjects.isNotEmpty && context.mounted) {
              selectedSubjectId = await showModalBottomSheet<String>(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Hangi derste yarışacaksınız?',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ...subjects.map((s) => ListTile(
                            title: Text(s.name),
                            onTap: () => Navigator.of(context).pop(s.id),
                          )),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
              if (selectedSubjectId == null) return; // iptal
            }

            final result = await ref
                .read(friendProvider.notifier)
                .sendMatchInvite(friend.childId, subjectId: selectedSubjectId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result != null
                      ? '${friend.name} davet edildi!'
                      : 'Davet gönderilemedi'),
                ),
              );
            }
          },
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'remove') {
              ref.read(friendProvider.notifier).removeFriend(friend.friendshipId);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'remove', child: Text('Arkadaşlıktan çıkar')),
          ],
        ),
      ]),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        child: ListTile(
          leading: _Avatar(name: result.name, url: result.avatarImageUrl),
          title: Text(result.name),
          subtitle: Text(result.friendCode),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (!alreadyFriend && !pending)
              FilledButton.tonal(
                onPressed: onSend,
                child: const Text('Ekle'),
              )
            else
              Text(alreadyFriend ? 'Arkadaş ✓' : 'İstek gönderildi',
                  style: const TextStyle(color: Colors.grey)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
            ),
          ]),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  const _Avatar({required this.name, this.url});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.startsWith('http')) {
      return CircleAvatar(backgroundImage: NetworkImage(url!), radius: 22);
    }
    return CircleAvatar(
      radius: 22,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final Color color;
  const _Badge(this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text('$count',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

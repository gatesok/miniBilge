import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../avatar/widgets/point_balance_widget.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../models/leaderboard_entry.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/leaderboard_state.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with WidgetsBindingObserver {
  final Set<String> _highlightedIds = {};
  final Map<String, int> _previousScores = {};
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _setupRealtimeListener();
    });
  }

  void _setupRealtimeListener() {
    ref.listen<LeaderboardState>(leaderboardProvider, (previous, next) {
      print('📡 [Listener] State değişti!');
      next.whenOrNull(
        loaded: (entries, _) {
          print('📊 [Listener] ${entries.length} entry var, skorları kontrol ediliyor...');
          final changedIds = <String>{};
          for (final entry in entries) {
            final prevScore = _previousScores[entry.childProfileId];
            if (prevScore != null && prevScore != entry.totalScore) {
              changedIds.add(entry.childProfileId);
              print('🎯 [UI] Skor değişti: ${entry.childName} $prevScore → ${entry.totalScore}');
            }
            _previousScores[entry.childProfileId] = entry.totalScore;
          }

          if (changedIds.isNotEmpty && mounted) {
            print('✨ [UI] ${changedIds.length} kişinin skoru değişti, highlight ekleniyor: $changedIds');
            setState(() {
              _highlightedIds.addAll(changedIds);
            });
            print('✅ [UI] setState tamamlandı, _highlightedIds: $_highlightedIds');

            _highlightTimer?.cancel();
            _highlightTimer = Timer(const Duration(seconds: 3), () {
              print('⏰ [UI] 3 saniye geçti, highlight kaldırılıyor');
              if (mounted) {
                setState(() {
                  _highlightedIds.clear();
                });
                print('✅ [UI] Highlight temizlendi');
              }
            });
          } else {
            print('ℹ️ [UI] Hiçbir skor değişmedi');
          }
        },
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _highlightTimer?.cancel();
    ref.read(leaderboardProvider.notifier).disconnectHub();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reconnectHub();
    } else if (state == AppLifecycleState.paused) {
      ref.read(leaderboardProvider.notifier).disconnectHub();
    }
  }

  Future<void> _reconnectHub() async {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null || !mounted) return;

    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: StorageKeys.accessToken);
    if (token != null && mounted) {
      await ref
          .read(leaderboardProvider.notifier)
          .connectHub(token, selectedChild.id);
    }
  }

  Future<void> _loadData() async {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    await ref.read(leaderboardProvider.notifier).loadLeaderboard(selectedChild.id);

    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: StorageKeys.accessToken);
    if (token != null && mounted) {
      await ref
          .read(leaderboardProvider.notifier)
          .connectHub(token, selectedChild.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedChild = ref.watch(selectedChildProvider);
    final leaderboardState = ref.watch(leaderboardProvider);

    if (selectedChild == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sıralama')),
        body: const Center(child: Text('Lütfen bir çocuk profili seçin')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Sıralama'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CompactPointBalanceWidget(),
          ),
        ],
      ),
      body: leaderboardState.when(
        initial: () => const Center(child: Text('Yükleniyor...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(message, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        loaded: (entries, myEntry) => _buildLeaderboard(entries, myEntry, theme, selectedChild.id),
      ),
    );
  }

  Widget _buildLeaderboard(
    List<LeaderboardEntry> entries,
    LeaderboardEntry? myEntry,
    ThemeData theme,
    String childId,
  ) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          if (myEntry != null)
            SliverToBoxAdapter(
              child: _MyRankCard(
                entry: myEntry,
                theme: theme,
                isHighlighted: _highlightedIds.contains(myEntry.childProfileId),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Top ${entries.length} Sıralama',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          entries.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz sıralamada kimse yok.\nİlk sen gir!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = entries[index];
                      final isMe = entry.childProfileId == childId;
                      final isHighlighted = _highlightedIds.contains(entry.childProfileId);
                      return _LeaderboardTile(
                        entry: entry,
                        isMe: isMe,
                        isHighlighted: isHighlighted,
                        theme: theme,
                      );
                    },
                    childCount: entries.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _MyRankCard extends StatefulWidget {
  final LeaderboardEntry entry;
  final ThemeData theme;
  final bool isHighlighted;

  const _MyRankCard({
    required this.entry,
    required this.theme,
    required this.isHighlighted,
  });

  @override
  State<_MyRankCard> createState() => _MyRankCardState();
}

class _MyRankCardState extends State<_MyRankCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isHighlighted) {
      _startBlinking();
    }
  }

  @override
  void didUpdateWidget(_MyRankCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _startBlinking();
    } else if (!widget.isHighlighted && oldWidget.isHighlighted) {
      _stopBlinking();
    }
  }

  void _startBlinking() {
    _animationController.repeat(reverse: true);
  }

  void _stopBlinking() {
    _animationController.stop();
    _animationController.reset();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: widget.isHighlighted ? _opacityAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.theme.colorScheme.primary,
                  widget.theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: widget.isHighlighted
                  ? Border.all(color: Colors.amber, width: 3)
                  : null,
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.8),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: widget.theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${widget.entry.rank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sen',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        widget.entry.childName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.entry.gradeLevel ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 20),
                    Text(
                      '${widget.entry.totalScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'puan',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeaderboardTile extends StatefulWidget {
  final LeaderboardEntry entry;
  final bool isMe;
  final bool isHighlighted;
  final ThemeData theme;

  const _LeaderboardTile({
    required this.entry,
    required this.isMe,
    required this.isHighlighted,
    required this.theme,
  });

  @override
  State<_LeaderboardTile> createState() => _LeaderboardTileState();
}

class _LeaderboardTileState extends State<_LeaderboardTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isHighlighted) {
      _startBlinking();
    }
  }

  @override
  void didUpdateWidget(_LeaderboardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _startBlinking();
    } else if (!widget.isHighlighted && oldWidget.isHighlighted) {
      _stopBlinking();
    }
  }

  void _startBlinking() {
    _animationController.repeat(reverse: true);
  }

  void _stopBlinking() {
    _animationController.stop();
    _animationController.reset();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _rankBadge(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTopThree = widget.entry.rank <= 3;

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: widget.isHighlighted ? _opacityAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isMe
                  ? widget.theme.colorScheme.primary.withValues(alpha: 0.1)
                  : widget.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: widget.isMe
                  ? Border.all(color: widget.theme.colorScheme.primary, width: 1.5)
                  : widget.isHighlighted
                      ? Border.all(color: Colors.amber, width: 3)
                      : null,
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.8),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: ListTile(
              leading: SizedBox(
                width: 44,
                child: Center(
                  child: isTopThree
                      ? Text(
                          _rankBadge(widget.entry.rank),
                          style: const TextStyle(fontSize: 28),
                        )
                      : Text(
                          '#${widget.entry.rank}',
                          style: widget.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                ),
              ),
              title: Text(
                widget.entry.childName + (widget.isMe ? ' (Sen)' : ''),
                style: widget.theme.textTheme.titleSmall?.copyWith(
                  fontWeight: widget.isMe ? FontWeight.bold : FontWeight.normal,
                  color: widget.isMe ? widget.theme.colorScheme.primary : null,
                ),
              ),
              subtitle: Text(
                widget.entry.gradeLevel ?? '',
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.entry.totalScore}',
                    style: widget.theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

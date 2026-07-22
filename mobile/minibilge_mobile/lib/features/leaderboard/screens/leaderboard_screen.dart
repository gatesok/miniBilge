import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';
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

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

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
          print(
              '📊 [Listener] ${entries.length} entry var, skorları kontrol ediliyor...');
          final changedIds = <String>{};
          for (final entry in entries) {
            final prevScore = _previousScores[entry.childProfileId];
            if (prevScore != null && prevScore != entry.totalScore) {
              changedIds.add(entry.childProfileId);
              print(
                  '🎯 [UI] Skor değişti: ${entry.childName} $prevScore → ${entry.totalScore}');
            }
            _previousScores[entry.childProfileId] = entry.totalScore;
          }
          if (changedIds.isNotEmpty && mounted) {
            print(
                '✨ [UI] ${changedIds.length} kişinin skoru değişti, highlight ekleniyor: $changedIds');
            setState(() {
              _highlightedIds.addAll(changedIds);
            });
            print(
                '✅ [UI] setState tamamlandı, _highlightedIds: $_highlightedIds');
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
    if (!mounted) return;
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;
    if (selectedChild.isAdultProfile) return;
    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: StorageKeys.accessToken);
    if (token != null && mounted) {
      await ref
          .read(leaderboardProvider.notifier)
          .connectHub(token, selectedChild.id);
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;
    await ref
        .read(leaderboardProvider.notifier)
        .loadLeaderboard(
          selectedChild.id,
          isAdult: selectedChild.isAdultProfile,
        );
    if (!mounted) return;
    if (selectedChild.isAdultProfile) return;
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
    final selectedChild = ref.watch(selectedChildProvider);
    final leaderboardState = ref.watch(leaderboardProvider);

    if (selectedChild == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _gradient),
          child: SafeArea(
            child: Center(
              child: Text('Lütfen bir çocuk profili seçin',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
    }

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
                    Expanded(
                      child: Text(
                        selectedChild.isAdultProfile
                            ? '🏆 Yetişkin Sıralaması'
                            : '🏆 Çocuk Sıralaması',
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 24,
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
              // Body
              Expanded(
                child: leaderboardState.when(
                  initial: () => Center(
                    child: Text('Yükleniyor...',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.white),
                          const SizedBox(height: 16),
                          Text(message,
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _loadData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A3FCC),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text('Tekrar Dene',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loaded: (entries, myEntry) => _buildLeaderboard(
                      entries, myEntry, selectedChild.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboard(
    List<LeaderboardEntry> entries,
    LeaderboardEntry? myEntry,
    String childId,
  ) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF7B61FF),
      child: CustomScrollView(
        slivers: [
          // My rank card
          if (myEntry != null)
            SliverToBoxAdapter(
              child: _MyRankCard(
                entry: myEntry,
                isHighlighted:
                    _highlightedIds.contains(myEntry.childProfileId),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          // Label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Top 15 ${myEntry?.profileType == 'Adult' ? 'Yetişkin' : 'Çocuk'}',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 20,
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
          ),
          entries.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Text('🏆',
                              style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz sıralamada kimse yok.\nİlk sen gir!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
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
                      final isHighlighted =
                          _highlightedIds.contains(entry.childProfileId);
                      return _LeaderboardTile(
                        entry: entry,
                        isMe: isMe,
                        isHighlighted: isHighlighted,
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
  final bool isHighlighted;

  const _MyRankCard({required this.entry, required this.isHighlighted});

  @override
  State<_MyRankCard> createState() => _MyRankCardState();
}

class _MyRankCardState extends State<_MyRankCard>
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
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.isHighlighted) _startBlinking();
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

  void _startBlinking() => _animationController.repeat(reverse: true);
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
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFFE88EC9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: widget.isHighlighted
                  ? Border.all(color: Colors.amber, width: 3)
                  : Border.all(
                      color: Colors.white.withOpacity(0.4), width: 1.5),
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                          color: Colors.amber.withOpacity(0.7),
                          blurRadius: 16,
                          spreadRadius: 4)
                    ]
                  : [
                      BoxShadow(
                          color: const Color(0xFF7B61FF).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '#${widget.entry.rank}',
                      style: GoogleFonts.luckiestGuy(
                          fontSize: 18,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(1, 1))
                          ]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sen',
                          style: GoogleFonts.nunito(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text(widget.entry.childName,
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20)),
                      Text(widget.entry.gradeLevel ?? '',
                          style: GoogleFonts.nunito(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    Text(
                      '${widget.entry.totalScore}',
                      style: GoogleFonts.luckiestGuy(
                          fontSize: 26,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(1, 1))
                          ]),
                    ),
                    Text('puan',
                        style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
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

  const _LeaderboardTile(
      {required this.entry,
      required this.isMe,
      required this.isHighlighted});

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
        duration: const Duration(milliseconds: 600), vsync: this);
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.isHighlighted) _animationController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_LeaderboardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isHighlighted && oldWidget.isHighlighted) {
      _animationController.stop();
      _animationController.reset();
    }
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
            margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.isMe
                  ? const Color(0xFF7B61FF).withOpacity(0.3)
                  : Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isHighlighted
                    ? Colors.amber
                    : widget.isMe
                        ? const Color(0xFF7B61FF).withOpacity(0.7)
                        : Colors.white.withOpacity(0.35),
                width: widget.isHighlighted || widget.isMe ? 2 : 1.5,
              ),
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                          color: Colors.amber.withOpacity(0.7),
                          blurRadius: 14,
                          spreadRadius: 3)
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Rank badge
                SizedBox(
                  width: 44,
                  child: Center(
                    child: isTopThree
                        ? Text(_rankBadge(widget.entry.rank),
                            style: const TextStyle(fontSize: 28))
                        : Text(
                            '#${widget.entry.rank}',
                            style: GoogleFonts.luckiestGuy(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.6),
                                shadows: const [
                                  Shadow(
                                      blurRadius: 0,
                                      color: Color(0xFF3D35CC),
                                      offset: Offset(1, 1))
                                ]),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + grade
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.entry.childName +
                            (widget.isMe ? ' (Sen)' : ''),
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: widget.isMe
                              ? FontWeight.w800
                              : FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.entry.gradeLevel ?? '',
                        style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.65),
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Score
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.entry.totalScore}',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
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

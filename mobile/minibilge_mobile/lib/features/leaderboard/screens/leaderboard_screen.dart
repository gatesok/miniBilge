import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
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
    });
  }

  void _setupRealtimeListener() {
    ref.listen<LeaderboardState>(leaderboardProvider, (previous, next) {
      debugPrint('📡 [Listener] State değişti!');
      next.whenOrNull(
        loaded: (entries, _) {
          debugPrint(
            '📊 [Listener] ${entries.length} entry var, skorları kontrol ediliyor...',
          );
          final changedIds = <String>{};
          for (final entry in entries) {
            final prevScore = _previousScores[entry.childProfileId];
            if (prevScore != null && prevScore != entry.totalScore) {
              changedIds.add(entry.childProfileId);
              debugPrint(
                '🎯 [UI] Skor değişti: ${entry.childName} $prevScore → ${entry.totalScore}',
              );
            }
            _previousScores[entry.childProfileId] = entry.totalScore;
          }
          if (changedIds.isNotEmpty && mounted) {
            debugPrint(
              '✨ [UI] ${changedIds.length} kişinin skoru değişti, highlight ekleniyor: $changedIds',
            );
            setState(() {
              _highlightedIds.addAll(changedIds);
            });
            debugPrint(
              '✅ [UI] setState tamamlandı, _highlightedIds: $_highlightedIds',
            );
            _highlightTimer?.cancel();
            _highlightTimer = Timer(const Duration(seconds: 3), () {
              debugPrint('⏰ [UI] 3 saniye geçti, highlight kaldırılıyor');
              if (mounted) {
                setState(() {
                  _highlightedIds.clear();
                });
                debugPrint('✅ [UI] Highlight temizlendi');
              }
            });
          } else {
            debugPrint('ℹ️ [UI] Hiçbir skor değişmedi');
          }
        },
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _highlightTimer?.cancel();
    // Hub, autoDispose provider + notifier.dispose() ile otomatik kapanır.
    // dispose() içinde ref kullanmak "Cannot use ref after disposed" hatası verir.
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
    // ref.listen build içinde çağrılmalı (post-frame'de "ref disposed" hatası veriyordu).
    _setupRealtimeListener();
    final selectedChild = ref.watch(selectedChildProvider);
    final leaderboardState = ref.watch(leaderboardProvider);

    if (selectedChild == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _gradient),
          child: SafeArea(
            child: Center(
              child: Text(
                'Lütfen bir çocuk profili seçin',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                          color: Colors.white.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
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
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icon/dashboard_leaderboard.png',
                            width: 42,
                            height: 42,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                selectedChild.isAdultProfile
                                    ? 'Yetişkin Sıralaması'
                                    : 'Çocuk Sıralaması',
                                style: GoogleFonts.luckiestGuy(
                                  fontSize: 24,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: leaderboardState.when(
                  initial: () => Center(
                    child: Text(
                      'Yükleniyor...',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _loadData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A3FCC),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                'Tekrar Dene',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loaded: (entries, myEntry) =>
                      _buildLeaderboard(entries, myEntry, selectedChild.id),
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
                isHighlighted: _highlightedIds.contains(myEntry.childProfileId),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          // Label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'İlk 15 ${myEntry?.profileType == 'Adult' ? 'Yetişkin' : 'Çocuk'}',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 20,
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
            ),
          ),
          entries.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icon/dashboard_leaderboard.png',
                            width: 92,
                            height: 92,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz sıralamada kimse yok.\nİlk sen gir!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final entry = entries[index];
                    final isMe = entry.childProfileId == childId;
                    final isHighlighted = _highlightedIds.contains(
                      entry.childProfileId,
                    );
                    return _LeaderboardTile(
                      entry: entry,
                      isMe: isMe,
                      isHighlighted: isHighlighted,
                    );
                  }, childCount: entries.length),
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.7),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0xFF7B61FF).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _LeaderboardAvatar(entry: widget.entry, size: 58),
                    Positioned(
                      right: -7,
                      bottom: -5,
                      child: _RankBadge(rank: widget.entry.rank, compact: true),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sen',
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.entry.childName,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        _profileDetail(widget.entry),
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/icon/dashboard_stat_score.png',
                      width: 28,
                      height: 28,
                    ),
                    Text(
                      '${widget.entry.totalScore}',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 26,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            blurRadius: 0,
                            color: Color(0xFF3D35CC),
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'puan',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  const _LeaderboardTile({
    required this.entry,
    required this.isMe,
    required this.isHighlighted,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: widget.isHighlighted ? _opacityAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: widget.entry.rank <= 3
                  ? LinearGradient(
                      colors: _podiumColors(widget.entry.rank),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: widget.entry.rank <= 3
                  ? null
                  : widget.isMe
                  ? const Color(0xFF7B61FF).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isHighlighted
                    ? Colors.amber
                    : widget.isMe
                    ? const Color(0xFF7B61FF).withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.35),
                width: widget.isHighlighted || widget.isMe ? 2 : 1.5,
              ),
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.7),
                        blurRadius: 14,
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Rank badge
                _RankBadge(rank: widget.entry.rank),
                const SizedBox(width: 10),
                _LeaderboardAvatar(entry: widget.entry, size: 44),
                const SizedBox(width: 12),
                // Name + grade
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.entry.childName + (widget.isMe ? ' (Sen)' : ''),
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: widget.isMe
                              ? FontWeight.w800
                              : FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _profileDetail(widget.entry),
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Score
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icon/dashboard_stat_score.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.entry.totalScore}',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
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

String _profileDetail(LeaderboardEntry entry) {
  final grade = entry.gradeLevel?.trim();
  if (grade != null && grade.isNotEmpty && grade.toLowerCase() != 'adult') {
    return grade;
  }
  return entry.profileType == 'Adult' ? 'Yetişkin' : 'Çocuk';
}

List<Color> _podiumColors(int rank) {
  switch (rank) {
    case 1:
      return [
        const Color(0xFFF6C94C).withValues(alpha: 0.52),
        const Color(0xFFFFE9A3).withValues(alpha: 0.22),
      ];
    case 2:
      return [
        const Color(0xFFDCE5F2).withValues(alpha: 0.46),
        Colors.white.withValues(alpha: 0.16),
      ];
    default:
      return [
        const Color(0xFFD8915B).withValues(alpha: 0.45),
        const Color(0xFFFFD2B0).withValues(alpha: 0.16),
      ];
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final bool compact;

  const _RankBadge({required this.rank, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isPodium = rank <= 3;
    final color = switch (rank) {
      1 => const Color(0xFFFFC928),
      2 => const Color(0xFFC7D2E2),
      3 => const Color(0xFFC77B45),
      _ => Colors.white.withValues(alpha: 0.18),
    };
    final size = compact ? 27.0 : 42.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 1.5),
        boxShadow: isPodium
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: GoogleFonts.luckiestGuy(
            fontSize: compact ? 12 : 17,
            color: isPodium ? const Color(0xFF4A3574) : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardAvatar extends StatelessWidget {
  final LeaderboardEntry entry;
  final double size;

  const _LeaderboardAvatar({required this.entry, required this.size});

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
      color: const Color(0xFF7867D9),
      alignment: Alignment.center,
      child: Text(
        entry.childName.isEmpty ? '?' : entry.childName[0].toUpperCase(),
        style: GoogleFonts.luckiestGuy(
          color: Colors.white,
          fontSize: size * 0.42,
        ),
      ),
    );

    final avatar = entry.avatarImageUrl?.trim();
    Widget content = fallback();
    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('http')) {
        content = CachedNetworkImage(
          imageUrl: avatar,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => fallback(),
        );
      } else {
        final assetPath = avatar.startsWith('assets/')
            ? avatar
            : 'assets/avatar/characters/$avatar.png';
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A3FCC).withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(child: content),
    );
  }
}

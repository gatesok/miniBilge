import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';
import '../../progress/providers/progress_provider.dart';
import '../../education/providers/subject_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/streak_service.dart';
import '../../../core/services/daily_quest_service.dart';

// ─────────────────────────────────────────────────────────────
//  DASHBOARD SCREEN
// ─────────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);
    final childProfileState = ref.watch(childProfileProvider);
    // Eagerly start loading subjects so data is ready when user taps Matematik
    ref.watch(subjectListProvider);

    final isLoadingProfiles = childProfileState.maybeWhen(
      initial: () => true,
      loading: () => true,
      orElse: () => false,
    );

    if (isLoadingProfiles) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    ChildProfileDto? currentChild = selectedChild;
    childProfileState.maybeWhen(
      loaded: (profiles) {
        if (selectedChild != null) {
          currentChild = profiles.firstWhere(
            (p) => p.id == selectedChild.id,
            orElse: () => selectedChild,
          );
        }
      },
      orElse: () {},
    );

    final totalProfiles = childProfileState.maybeWhen(
      loaded: (profiles) => profiles.length,
      orElse: () => 0,
    );

    if (currentChild == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.child_care, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Lütfen bir profil seçin'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/child-profile-selection'),
                child: const Text('Profil Seç'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFF7EC8F0), // sky blue
              Color(0xFFAA9FE8), // lavender
              Color(0xFFC4A8E2), // soft violet
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating decorative math symbols
              const Positioned.fill(
                child: IgnorePointer(child: _FloatingSymbols()),
              ),
              // Scrollable main content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // ── Top Bar ──────────────────────────────
                    _TopBar(
                      child: currentChild!,
                      onLogout: () async {
                        await ref.read(authProvider.notifier).logout();
                        await ref
                            .read(selectedChildProvider.notifier)
                            .clearSelection();
                        if (context.mounted) context.go('/login');
                      },
                      onDeleteAccount: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text('Hesabı Sil'),
                            content: const Text(
                              'Hesabınızı silmek istediğinizden emin misiniz?\n\n'
                              'Bu işlem geri alınamaz. Tüm profilleriniz, '
                              'ilerlemeniz ve verileriniz kalıcı olarak silinecektir.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('İptal'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Hesabı Sil'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          final error = await ref
                              .read(authProvider.notifier)
                              .deleteAccount();
                          if (error != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else if (context.mounted) {
                            await ref
                                .read(selectedChildProvider.notifier)
                                .clearSelection();
                            context.go('/login');
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    // ── Title ────────────────────────────────
                    Text(
                      'MİNİ BİLGE',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 52,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(3, 3)),
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(-1, -1)),
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(3, -1)),
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(-1, 3)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // ── Avatar ───────────────────────────────
                    GestureDetector(
                      onTap: () => context.push('/avatar/profile'),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.22),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B61FF).withOpacity(0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: () {
                            final key = currentChild!.avatarImageUrl;
                            if (key != null && key.startsWith('http')) {
                              return CachedNetworkImage(
                                imageUrl: key,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                                errorWidget: (_, __, ___) => const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('🧒', style: TextStyle(fontSize: 40)),
                                ),
                              );
                            }
                            if (key != null && key.isNotEmpty) {
                              return Image.asset(
                                'assets/avatar/characters/$key.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('🧒', style: TextStyle(fontSize: 40)),
                                ),
                              );
                            }
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('🧒', style: TextStyle(fontSize: 40)),
                            );
                          }(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Subtitle ─────────────────────────────
                    Text(
                      'Hoş Geldin, ${currentChild!.name}! 👋',
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // ── Grade badge ───────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.45),
                            width: 1.5),
                      ),
                      child: Text(
                        '${currentChild!.age} yaşında  •  ${currentChild!.gradeLevel}',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // ── Friend Code ───────────────────────────
                    if (currentChild!.friendCode != null &&
                        currentChild!.friendCode!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: currentChild!.friendCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Arkadaş kodu kopyalandı!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tag,
                                  size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                currentChild!.friendCode!,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.copy,
                                  size: 12, color: Colors.white60),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),

                    // ── Streak + Daily Quest ──────────────────
                    _StreakAndQuestRow(
                      childId: currentChild!.id,
                      onStartStreak: () {
                        final subjectsAsync = ref.read(subjectListProvider);
                        subjectsAsync.whenData((subjects) {
                          final math = subjects.firstWhere(
                            (s) => s.name.toLowerCase() == 'matematik',
                            orElse: () => subjects.first,
                          );
                          context.push(
                              '/education/topics/${math.id}',
                              extra: math.name);
                        });
                      },
                    ),
                    const SizedBox(height: 18),

                    // ── Section label ─────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ne oynamak istersin?',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Main action buttons ───────────────────
                    // Dinamik ders butonları (subjects tablosundan)
                    ...ref.watch(subjectListProvider).maybeWhen(
                      data: (subjects) => subjects.map((subject) {
                        final config = _subjectButtonConfig(subject.name);
                        final isEnglish = subject.name
                            .toLowerCase()
                            .replaceAll('i̇', 'i')
                            .contains('ingilizce');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _GameButton(
                            label: subject.name.toUpperCase(),
                            emoji: config.$1,
                            gradientColors: config.$2,
                            shadowColor: config.$3,
                            onTap: () => isEnglish
                                ? context.push(
                                    '/education/english-level/${subject.id}',
                                    extra: subject.name,
                                  )
                                : context.push(
                                    '/education/topics/${subject.id}',
                                    extra: subject.name,
                                  ),
                          ),
                        );
                      }).toList(),
                      orElse: () => [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _GameButtonLoading(),
                        ),
                      ],
                    ),

                    _GameButton(
                      label: 'CANLI YARIŞ',
                      emoji: '⚡',
                      gradientColors: const [
                        Color(0xFFFF7043),
                        Color(0xFFBF360C)
                      ],
                      shadowColor: const Color(0xFF7F2407),
                      onTap: () => context.push('/match/subject-select'),
                    ),
                    const SizedBox(height: 12),

                    _GameButton(
                      label: 'SIRALAMA',
                      emoji: '🏆',
                      gradientColors: const [
                        Color(0xFFFFCA28),
                        Color(0xFFFF8F00)
                      ],
                      shadowColor: const Color(0xFFBF6900),
                      onTap: () => context.push('/leaderboard'),
                    ),
                    const SizedBox(height: 12),

                    _GameButton(
                      label: 'ARKADAŞLAR',
                      emoji: '🤝',
                      gradientColors: const [
                        Color(0xFF26C6DA),
                        Color(0xFF0077B6),
                      ],
                      shadowColor: const Color(0xFF005B8E),
                      onTap: () => context.push('/friends'),
                    ),
                    const SizedBox(height: 12),

                    _GameButton(
                      label: 'MEYDAN OKUMALAR',
                      emoji: '⚔️',
                      gradientColors: const [
                        Color(0xFF6A5ACD),
                        Color(0xFF9C27B0),
                      ],
                      shadowColor: const Color(0xFF4A0072),
                      onTap: () => context.push('/challenges'),
                    ),
                    const SizedBox(height: 22),

                    // ── Secondary 2×2 grid ────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _SmallGameButton(
                            label: 'ROZETLERİM',
                            emoji: '🏅',
                            color: const Color(0xFF7B61FF),
                            shadowColor: const Color(0xFF3D35CC),
                            onTap: () =>
                                context.push('/badges'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallGameButton(
                            label: 'KARTLARIM',
                            emoji: '🃏',
                            color: const Color(0xFF1565C0),
                            shadowColor: const Color(0xFF0D3C6E),
                            onTap: () =>
                                context.push('/cards'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallGameButton(
                            label: 'AVATAR',
                            emoji: '🎭',
                            color: const Color(0xFF9C27B0),
                            shadowColor: const Color(0xFF4A148C),
                            onTap: () =>
                                context.push('/avatar/profile'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallGameButton(
                            label: 'RAPOR',
                            emoji: '📈',
                            color: const Color(0xFF43A047),
                            shadowColor: const Color(0xFF1B5E20),
                            onTap: () =>
                                context.push('/parent-report'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallGameButton(
                            label: 'GEÇMİŞ',
                            emoji: '📋',
                            color: const Color(0xFF5C6BC0),
                            shadowColor: const Color(0xFF283593),
                            onTap: () {
                              final childId = currentChild?.id;
                              if (childId != null) {
                                context.push(
                                    '/match/history?childId=$childId');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallGameButton(
                            label: totalProfiles == 1
                                ? 'YENİ PROFİL'
                                : 'DEĞİŞTİR',
                            emoji:
                                totalProfiles == 1 ? '➕' : '🔄',
                            color: const Color(0xFF78909C),
                            shadowColor: const Color(0xFF37474F),
                            onTap: () {
                              if (totalProfiles == 1) {
                                context.push('/child-profile/add');
                              } else {
                                context.go(
                                    '/child-profile-selection');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Progress stats ────────────────────────
                    _ProgressStatsCard(childId: currentChild!.id),
                    const SizedBox(height: 32),
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

// ─────────────────────────────────────────────────────────────
//  TOP BAR  (stars · coins · logout)
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatefulWidget {
  final ChildProfileDto child;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  const _TopBar({
    required this.child,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  bool _soundEnabled = SoundService.isEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Stars & Coins pill
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.28),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Colors.white.withOpacity(0.45), width: 1.5),
          ),
          child: Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 4),
              Text(
                '${widget.child.totalStars}',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        // Settings menu button
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') widget.onLogout();
            if (value == 'delete') widget.onDeleteAccount();
            if (value == 'edit_profile') {
              context.push('/child-profile/edit/${widget.child.id}');
            }
            if (value == 'sound') {
              await SoundService.setEnabled(!_soundEnabled);
              setState(() => _soundEnabled = SoundService.isEnabled);
            }
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.28),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(0.45), width: 1.5),
            ),
            child: const Icon(Icons.more_vert_rounded,
                color: Colors.white, size: 22),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit_profile',
              child: Row(
                children: [
                  const Icon(Icons.manage_accounts_rounded, size: 20),
                  const SizedBox(width: 10),
                  const Text('Profil Ayarları'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'sound',
              child: Row(
                children: [
                  Icon(
                    _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(_soundEnabled ? 'Sesi Kapat' : 'Sesi Aç'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('Çıkış Yap'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_forever_rounded,
                      size: 20, color: Colors.red.shade700),
                  const SizedBox(width: 10),
                  Text('Hesabı Sil',
                      style: TextStyle(color: Colors.red.shade700)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STREAK + DAILY QUEST ROW
// ─────────────────────────────────────────────────────────────
class _StreakAndQuestRow extends StatefulWidget {
  final String childId;
  final VoidCallback onStartStreak;
  const _StreakAndQuestRow({required this.childId, required this.onStartStreak});

  @override
  State<_StreakAndQuestRow> createState() => _StreakAndQuestRowState();
}

class _StreakAndQuestRowState extends State<_StreakAndQuestRow> {
  int _streak = 0;
  int _questProgress = 0;
  bool _questDone = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkStreakWarning();
  }

  Future<void> _checkStreakWarning() async {
    final atRisk = await StreakService.isStreakAtRisk(widget.childId);
    if (atRisk && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4A3FCC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'Zincirini Kaybetme!',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 22,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                            blurRadius: 0,
                            color: Color(0xFF2A1F9D),
                            offset: Offset(2, 2)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bugün 1 soru çözmen yeterli!\nZincirin devam etsin 🚀',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Haydi Başla!',
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
        );
      });
    }
  }

  Future<void> _load() async {
    final streak = await StreakService.getCurrentStreak(widget.childId);
    final progress =
        await DailyQuestService.getTodayProgress(widget.childId);
    final done = await DailyQuestService.isCompletedToday(widget.childId);
    if (mounted) {
      setState(() {
        _streak = streak;
        _questProgress = progress;
        _questDone = done;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Streak kartı
        Expanded(
          child: GestureDetector(
            onTap: _streak == 0 ? widget.onStartStreak : null,
            child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _streak > 0 ? '🔥' : '💤',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _streak > 0
                            ? '$_streak Günlük Zincir!'
                            : 'Zincir Yok',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _streak > 0
                            ? 'Harika gidiyorsun!'
                            : 'Bugün başla!',
                        style: GoogleFonts.nunito(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
        const SizedBox(width: 12),
        // Günlük görev kartı
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _questDone
                  ? const Color(0xFF2ECC71).withOpacity(0.3)
                  : Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _questDone
                    ? const Color(0xFF2ECC71).withOpacity(0.6)
                    : Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _questDone ? '✅' : '🎯',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _questDone ? 'Tamamlandı!' : 'Günlük Görev',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_questProgress / DailyQuestService.dailyGoal)
                        .clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _questDone
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFF7B61FF),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_questProgress/${DailyQuestService.dailyGoal} soru',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FLOATING MATH SYMBOLS  (decorative background)
// ─────────────────────────────────────────────────────────────
class _FloatingSymbols extends StatelessWidget {
  const _FloatingSymbols();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _sym('+', 54, -0.25, 12, 90, Colors.yellow),
        _sym('×', 36, 0.35, null, 65, Colors.pinkAccent, right: 14),
        _sym('÷', 46, 0.12, 18, 310, Colors.lightGreenAccent),
        _sym('=', 34, -0.18, null, 260, Colors.orange, right: 16),
        _sym('+', 28, 0.40, null, 520, Colors.cyanAccent, right: 10),
        _sym('×', 42, -0.15, 14, 580, Colors.yellow),
        _sym('−', 50, 0.22, null, 680, Colors.pinkAccent, right: 18),
        _sym('÷', 30, -0.30, 30, 750, Colors.lime),
      ],
    );
  }

  Widget _sym(
    String s,
    double size,
    double angle,
    double? left,
    double top,
    Color color, {
    double? right,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Text(
          s,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            color: color.withOpacity(0.30),
          ),
        ),
      ),
    );
  }
}

// Ders adına göre emoji + renk konfigürasyonu döndürür
(String, List<Color>, Color) _subjectButtonConfig(String name) {
  switch (name.toLowerCase()) {
    case 'matematik':
      return ('🧮', const [Color(0xFF29B6F6), Color(0xFF0277BD)], const Color(0xFF01579B));
    case 'i̇ngilizce':
    case 'ingilizce':
      return ('🇬🇧', const [Color(0xFF26A69A), Color(0xFF00695C)], const Color(0xFF004D40));
    default:
      return ('📚', const [Color(0xFF7E57C2), Color(0xFF4527A0)], const Color(0xFF311B92));
  }
}

// ─────────────────────────────────────────────────────────────
//  GAME BUTTON LOADING  (placeholder while subjects load)
// ─────────────────────────────────────────────────────────────
class _GameButtonLoading extends StatelessWidget {
  const _GameButtonLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GAME BUTTON  (large pill, 3-D press effect)
// ─────────────────────────────────────────────────────────────
class _GameButton extends StatelessWidget {
  final String label;
  final String emoji;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback? onTap;

  const _GameButton({
    required this.label,
    required this.emoji,
    required this.gradientColors,
    required this.shadowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Darker bottom = 3-D shadow layer
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          // Actual button, shifted up to expose shadow
          margin: const EdgeInsets.only(bottom: 5),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.18),
                offset: const Offset(0, -3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji icon in frosted circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.28),
                        offset: const Offset(1, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.75),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SMALL GAME BUTTON  (2-column grid tiles)
// ─────────────────────────────────────────────────────────────
class _SmallGameButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final Color shadowColor;
  final VoidCallback? onTap;

  const _SmallGameButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.shadowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                offset: const Offset(0, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.luckiestGuy(
                  fontSize: 13,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PROGRESS STATS CARD
// ─────────────────────────────────────────────────────────────
class _ProgressStatsCard extends ConsumerWidget {
  final String childId;
  const _ProgressStatsCard({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(childProgressProvider(childId));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Colors.white.withOpacity(0.40), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: progressAsync.when(
        data: (progress) => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📊', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'İlerleme İstatistikleri',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    emoji: '🏅',
                    label: 'Toplam\nPuan',
                    value: '${progress.totalScore}',
                    color: const Color(0xFFFFCA28),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBox(
                    emoji: '⭐',
                    label: 'Toplam\nYıldız',
                    value: '${progress.totalStars}',
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBox(
                    emoji: '✅',
                    label: 'Tamam-\nlanan',
                    value: '${progress.completedLevelsCount}',
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        error: (e, s) => Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '🎯 Quiz çözerek puan kazan!',
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STAT BOX  (used inside _ProgressStatsCard)
// ─────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: color.withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.luckiestGuy(
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.88),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';
import '../../progress/providers/progress_provider.dart';
import '../../education/providers/subject_provider.dart';

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
                    const SizedBox(height: 26),

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
                    _GameButton(
                      label: 'MATEMATİK',
                      emoji: '🧮',
                      gradientColors: const [
                        Color(0xFF29B6F6),
                        Color(0xFF0277BD)
                      ],
                      shadowColor: const Color(0xFF01579B),
                      onTap: () {
                        final subjectsAsync =
                            ref.read(subjectListProvider);
                        subjectsAsync.whenData((subjects) {
                          final math = subjects.firstWhere(
                            (s) =>
                                s.name.toLowerCase() == 'matematik',
                            orElse: () => subjects.first,
                          );
                          context.push(
                              '/education/topics/${math.id}',
                              extra: math.name);
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    _GameButton(
                      label: 'CANLI YARIŞ',
                      emoji: '⚡',
                      gradientColors: const [
                        Color(0xFFFF7043),
                        Color(0xFFBF360C)
                      ],
                      shadowColor: const Color(0xFF7F2407),
                      onTap: () => context.go('/match/request'),
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
                    const SizedBox(height: 22),

                    // ── Secondary 2×2 grid ────────────────────
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
class _TopBar extends StatelessWidget {
  final ChildProfileDto child;
  final VoidCallback onLogout;
  const _TopBar({required this.child, required this.onLogout});

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
                '${child.totalStars}',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 14),
              const Text('🪙', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 4),
              Text(
                '${child.totalCoins}',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        // Logout button
        GestureDetector(
          onTap: onLogout,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.28),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(0.45), width: 1.5),
            ),
            child: const Icon(Icons.logout_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ],
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

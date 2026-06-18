import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/child_profile_dto.dart';
import '../providers/child_profile_provider.dart';
import '../providers/selected_child_provider.dart';

class ChildProfileSelectionScreen extends ConsumerStatefulWidget {
  const ChildProfileSelectionScreen({super.key});

  @override
  ConsumerState<ChildProfileSelectionScreen> createState() =>
      _ChildProfileSelectionScreenState();
}

class _ChildProfileSelectionScreenState
    extends ConsumerState<ChildProfileSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childProfileState = ref.read(childProfileProvider);
      childProfileState.maybeWhen(
        loaded: (profiles) async {
          if (profiles.length == 1) {
            await ref
                .read(selectedChildProvider.notifier)
                .selectChild(profiles.first);
            if (mounted) context.go('/dashboard');
          }
        },
        orElse: () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final childProfileState = ref.watch(childProfileProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFF7EC8F0),
              Color(0xFFAA9FE8),
              Color(0xFFC4A8E2),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating math symbols
              const Positioned.fill(
                child: IgnorePointer(child: _SelectionFloatingSymbols()),
              ),
              // Content
              Column(
                children: [
                  // ── App Bar ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Title
                        Expanded(
                          child: Text(
                            'Kim Oynayacak?',
                            style: GoogleFonts.luckiestGuy(
                              fontSize: 26,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                    blurRadius: 0,
                                    color: Color(0xFF3D35CC),
                                    offset: Offset(2, 2)),
                                Shadow(
                                    blurRadius: 0,
                                    color: Color(0xFF3D35CC),
                                    offset: Offset(-1, -1)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Settings button
                        GestureDetector(
                          onTap: () => context.push('/child-profiles'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.45),
                                  width: 1.5),
                            ),
                            child: const Icon(Icons.settings_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ──────────────────────────────────
                  Expanded(
                    child: childProfileState.when(
                      initial: () => const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white),
                      ),
                      loaded: (profiles) {
                        if (profiles.isEmpty) {
                          return _EmptyState(
                            onAdd: () =>
                                context.push('/child-profile/add'),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              20, 8, 20, 100),
                          itemCount: profiles.length,
                          itemBuilder: (context, index) {
                            final profile = profiles[index];
                            return _ProfileCard(
                              profile: profile,
                              onSelect: () async {
                                await ref
                                    .read(selectedChildProvider
                                        .notifier)
                                    .selectChild(profile);
                                if (context.mounted) {
                                  context.go('/dashboard');
                                }
                              },
                            );
                          },
                        );
                      },
                      error: (message) => Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Text('😕',
                                style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            Text(
                              message,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            _AddButton(
                              onTap: () => ref
                                  .read(childProfileProvider
                                      .notifier)
                                  .loadProfiles(),
                              label: 'Tekrar Dene',
                              emoji: '🔄',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── FAB: Yeni Profil Ekle ──────────────────
              Positioned(
                bottom: 24,
                right: 20,
                left: 20,
                child: _AddButton(
                  onTap: () => context.push('/child-profile/add'),
                  label: 'Yeni Profil Ekle',
                  emoji: '➕',
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
//  PROFILE CARD
// ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final ChildProfileDto profile;
  final VoidCallback onSelect;

  const _ProfileCard({required this.profile, required this.onSelect});

  static const _avatarColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFFF7B731),
    Color(0xFF5F27CD),
    Color(0xFF00D2D3),
    Color(0xFFFF9F43),
    Color(0xFF1DD1A1),
  ];

  @override
  Widget build(BuildContext context) {
    final colorIndex = profile.name.codeUnitAt(0) % _avatarColors.length;
    final avatarColor = _avatarColors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(26),
        border:
            Border.all(color: Colors.white.withOpacity(0.45), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          children: [
            // ── Avatar circle ────────────────────────
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: avatarColor.withOpacity(0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 42,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(1, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Name ─────────────────────────────────
            Text(
              profile.name,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            // ── Age & Grade ───────────────────────────
            Text(
              '${profile.age} yaşında  •  ${profile.gradeLevelEnum?.displayName ?? profile.gradeLevel}${profile.englishLevelEnum != null ? '  •  ${profile.englishLevelEnum!.displayName}' : ''}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 14),

            // ── Stats row ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(
                  emoji: '⭐',
                  value: '${profile.totalStars} Yıldız',
                  color: const Color(0xFFFFCA28),
                ),
                const SizedBox(width: 10),
                _StatChip(
                  emoji: '🪙',
                  value: '${profile.totalCoins} Coin',
                  color: const Color(0xFFFF9800),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Play Button ───────────────────────────
            GestureDetector(
              onTap: onSelect,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF66BB6A),
                        Color(0xFF2E7D32),
                      ],
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'OYNA',
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(1, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STAT CHIP
// ─────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final Color color;

  const _StatChip({
    required this.emoji,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD BUTTON  (bottom pill)
// ─────────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String emoji;

  const _AddButton({
    required this.onTap,
    required this.label,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4A148C),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.luckiestGuy(
                  fontSize: 18,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(1, 2),
                      blurRadius: 3,
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
}

// ─────────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👶', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              'Henüz profil yok!',
              style: GoogleFonts.luckiestGuy(
                fontSize: 26,
                color: Colors.white,
                shadows: const [
                  Shadow(
                      blurRadius: 0,
                      color: Color(0xFF3D35CC),
                      offset: Offset(2, 2)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'İlk çocuk profilini oluştur ve oynamaya başla!',
              style: GoogleFonts.nunito(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _AddButton(
              onTap: onAdd,
              label: 'Profil Oluştur',
              emoji: '✨',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FLOATING SYMBOLS
// ─────────────────────────────────────────────────────────────
class _SelectionFloatingSymbols extends StatelessWidget {
  const _SelectionFloatingSymbols();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _sym('+', 50, -0.2, 10, 90, Colors.yellow),
        _sym('×', 36, 0.3, null, 70, Colors.pinkAccent, right: 12),
        _sym('÷', 42, 0.1, 16, 350, Colors.lightGreenAccent),
        _sym('=', 30, -0.2, null, 300, Colors.orange, right: 14),
        _sym('+', 26, 0.4, null, 600, Colors.cyanAccent, right: 10),
        _sym('×', 44, -0.15, 12, 650, Colors.yellow),
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
            color: color.withOpacity(0.28),
          ),
        ),
      ),
    );
  }
}

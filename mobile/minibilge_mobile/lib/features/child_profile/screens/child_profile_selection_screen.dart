import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/child_profile_dto.dart';
import '../providers/child_profile_provider.dart';
import '../providers/selected_child_provider.dart';
import '../../../core/services/analytics_service.dart';

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

  void _openNewProfile() {
    final hasExistingProfile = ref
        .read(childProfileProvider)
        .maybeWhen(
          loaded: (profiles) => profiles.isNotEmpty,
          orElse: () => false,
        );
    if (hasExistingProfile) {
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.premiumFeatureTapped,
          parameters: const {'feature_key': 'additional_child_profile'},
        ),
      );
    }
    context.push('/child-profile/add');
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
            colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
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
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                                  offset: Offset(2, 2),
                                ),
                                Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF3D35CC),
                                  offset: Offset(-1, -1),
                                ),
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
                              color: Colors.white.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ──────────────────────────────────
                  Expanded(
                    child: childProfileState.when(
                      initial: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      loaded: (profiles) {
                        if (profiles.isEmpty) {
                          return _EmptyState(
                            onAdd: () => context.push('/child-profile/add'),
                          );
                        }
                        final horizontalPadding =
                            ((MediaQuery.sizeOf(context).width - 680) / 2)
                                .clamp(20.0, double.infinity)
                                .toDouble();
                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            8,
                            horizontalPadding,
                            28,
                          ),
                          itemCount: profiles.length + 1,
                          itemBuilder: (context, index) {
                            if (index == profiles.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: _AddButton(
                                  onTap: _openNewProfile,
                                  label: 'Yeni Profil Ekle',
                                  icon: Icons.add_rounded,
                                ),
                              );
                            }
                            final profile = profiles[index];
                            return _ProfileCard(
                              profile: profile,
                              onSelect: () async {
                                await ref
                                    .read(selectedChildProvider.notifier)
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.sentiment_dissatisfied_rounded,
                              color: Colors.white,
                              size: 64,
                            ),
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
                                  .read(childProfileProvider.notifier)
                                  .loadProfiles(),
                              label: 'Tekrar Dene',
                              icon: Icons.refresh_rounded,
                            ),
                          ],
                        ),
                      ),
                      unauthenticated: () => const SizedBox.shrink(),
                    ),
                  ),
                ],
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
    final isAdult = profile.isAdultProfile;
    final profileTypeLabel = isAdult ? 'Yetişkin' : 'Çocuk';

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 2),
          boxShadow: [
            BoxShadow(
              color: avatarColor.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            _ProfileAvatar(profile: profile, color: avatarColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _ProfileTypeBadge(
                        label: profileTypeLabel,
                        isAdult: isAdult,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.age} yaşında • ${profile.gradeLevelEnum?.displayName ?? profile.gradeLevel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  if (profile.englishLevelEnum != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'İngilizce ${profile.englishLevelEnum!.displayName}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.76),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.star_rounded,
                        value: '${profile.totalStars}',
                        color: const Color(0xFFFFCA28),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Profili Seç',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final ChildProfileDto profile;
  final Color color;

  const _ProfileAvatar({required this.profile, required this.color});

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Center(
      child: Text(
        profile.name[0].toUpperCase(),
        style: GoogleFonts.luckiestGuy(fontSize: 32, color: Colors.white),
      ),
    );

    final key = profile.avatarImageUrl;
    Widget image = fallback();
    if (key != null && key.startsWith('http')) {
      image = CachedNetworkImage(
        imageUrl: key,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => fallback(),
      );
    } else if (key != null && key.isNotEmpty) {
      // Yerleşik karakterler tam-boy (3:4) illüstrasyonlardır. Daire içinde
      // cover kullanmak karakterin başını/ayaklarını kırptığı için bu ekranda
      // da güvenli boşlukla bütün karakteri gösteriyoruz.
      image = Padding(
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          'assets/avatar/characters/$key.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          errorBuilder: (_, _, _) => fallback(),
        ),
      );
    }

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.38), blurRadius: 12)],
      ),
      child: ClipOval(child: image),
    );
  }
}

class _ProfileTypeBadge extends StatelessWidget {
  final String label;
  final bool isAdult;

  const _ProfileTypeBadge({required this.label, required this.isAdult});

  @override
  Widget build(BuildContext context) {
    final color = isAdult ? const Color(0xFF7B61FF) : const Color(0xFF26C6DA);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STAT CHIP
// ─────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
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
  final IconData icon;

  const _AddButton({
    required this.onTap,
    required this.label,
    required this.icon,
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
                color: Colors.white.withValues(alpha: 0.18),
                offset: const Offset(0, -3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.luckiestGuy(
                  fontSize: 18,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.25),
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
            const Icon(Icons.child_care_rounded, color: Colors.white, size: 80),
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
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'İlk çocuk profilini oluştur ve oynamaya başla!',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _AddButton(
              onTap: onAdd,
              label: 'Profil Oluştur',
              icon: Icons.auto_awesome_rounded,
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
            color: color.withValues(alpha: 0.28),
          ),
        ),
      ),
    );
  }
}

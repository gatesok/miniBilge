import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/child_profile_provider.dart';
import '../providers/child_profile_state.dart';
import '../providers/selected_child_provider.dart';
import '../models/child_profile_dto.dart';

class ChildProfileListScreen extends ConsumerStatefulWidget {
  const ChildProfileListScreen({super.key});

  @override
  ConsumerState<ChildProfileListScreen> createState() =>
      _ChildProfileListScreenState();
}

class _ChildProfileListScreenState
    extends ConsumerState<ChildProfileListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(childProfileProvider.notifier).loadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    final childProfileState = ref.watch(childProfileProvider);

    ref.listen<ChildProfileState>(childProfileProvider, (_, next) {
      next.maybeWhen(
        unauthenticated: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
        orElse: () {},
      );
    });

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
              // Floating symbols
              const Positioned.fill(
                child: IgnorePointer(child: _ListFloatingSymbols()),
              ),

              Column(
                children: [
                  // ── App Bar ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Çocuk Profilleri',
                            style: GoogleFonts.luckiestGuy(
                              fontSize: 24,
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
                        // Logout button
                        GestureDetector(
                          onTap: () async {
                            await ref
                                .read(authProvider.notifier)
                                .logout();
                            if (context.mounted) context.go('/login');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.45),
                                  width: 1.5),
                            ),
                            child: const Icon(Icons.logout_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ────────────────────────────────
                  Expanded(
                    child: childProfileState.when(
                      initial: () => Center(
                        child: Text(
                          'Profiller yükleniyor...',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
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
                            return _ChildProfileCard(
                              profile: profile,
                              onTap: () async {
                                await ref
                                    .read(selectedChildProvider
                                        .notifier)
                                    .selectChild(profile);
                                if (context.mounted) {
                                  context.go('/dashboard');
                                }
                              },
                              onEdit: () => context.push(
                                  '/child-profile/edit/${profile.id}'),
                              onDelete: () => _showDeleteDialog(
                                  context, profile),
                            );
                          },
                        );
                      },
                      error: (message) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
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
                      unauthenticated: () => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),

              // ── FAB ─────────────────────────────────────
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: _AddButton(
                  onTap: () => context.push('/child-profile/add'),
                  label: 'Çocuk Profili Ekle',
                  emoji: '➕',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChildProfileDto profile) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗑️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Profili Sil',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 22,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                        blurRadius: 0,
                        color: Color(0xFF3D35CC),
                        offset: Offset(2, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${profile.name} profilini silmek istediğine emin misin?\nBu işlem geri alınamaz.',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.of(dialogContext).pop(),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5)),
                        ),
                        child: Text(
                          'İptal',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.of(dialogContext).pop();
                        final success = await ref
                            .read(childProfileProvider.notifier)
                            .deleteProfile(profile.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: Text(success
                                ? 'Profil silindi'
                                : 'Hata oluştu'),
                            backgroundColor: success
                                ? const Color(0xFF43A047)
                                : const Color(0xFFD32F2F),
                          ));
                        }
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          'Sil',
                          style: GoogleFonts.luckiestGuy(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
//  CHILD PROFILE CARD
// ─────────────────────────────────────────────────────────────
class _ChildProfileCard extends StatelessWidget {
  final ChildProfileDto profile;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildProfileCard({
    required this.profile,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Colors.white.withOpacity(0.45), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: avatarColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      profile.name[0].toUpperCase(),
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.age} yaşında  •  ${profile.gradeLevelEnum?.displayName ?? profile.gradeLevel}${profile.englishLevelEnum != null ? '  •  🇬🇧 ${profile.englishLevelEnum!.displayName}' : ''}',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MiniChip('⭐', '${profile.totalStars}',
                              const Color(0xFFFFCA28)),
                          const SizedBox(width: 8),
                          _MiniChip('🪙', '${profile.totalCoins}',
                              const Color(0xFFFF9800)),
                        ],
                      ),
                    ],
                  ),
                ),

                // "..." menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded,
                      color: Colors.white, size: 26),
                  color: const Color(0xFF4A3ABA),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Text('✏️',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Text('Düzenle',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Text('🗑️',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Text('Sil',
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFFFF6B6B),
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Play button
            GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12),
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
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 6),
                      Text(
                        'Oyna',
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 17,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color:
                                  Colors.black.withOpacity(0.25),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
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
//  MINI CHIP  (stars / coins inline)
// ─────────────────────────────────────────────────────────────
class _MiniChip extends StatelessWidget {
  final String emoji;
  final String value;
  final Color color;
  const _MiniChip(this.emoji, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD BUTTON  (bottom full-width pill)
// ─────────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String emoji;
  const _AddButton(
      {required this.onTap, required this.label, required this.emoji});

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
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FLOATING SYMBOLS
// ─────────────────────────────────────────────────────────────
class _ListFloatingSymbols extends StatelessWidget {
  const _ListFloatingSymbols();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _sym('+', 50, -0.2, 10, 90, Colors.yellow),
        _sym('×', 36, 0.3, null, 70, Colors.pinkAccent, right: 12),
        _sym('÷', 42, 0.1, 16, 400, Colors.lightGreenAccent),
        _sym('=', 30, -0.2, null, 350, Colors.orange, right: 14),
        _sym('+', 26, 0.4, null, 650, Colors.cyanAccent, right: 10),
        _sym('×', 44, -0.15, 12, 700, Colors.yellow),
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

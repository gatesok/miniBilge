import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/avatar_service_provider.dart';
import '../models/item_type.dart';
import '../models/equipped_item.dart';

class AvatarProfileScreen extends ConsumerStatefulWidget {
  const AvatarProfileScreen({super.key});

  @override
  ConsumerState<AvatarProfileScreen> createState() =>
      _AvatarProfileScreenState();
}

class _AvatarProfileScreenState extends ConsumerState<AvatarProfileScreen> {
  String _selectedCharacter = 'male_person';
  String _savedCharacter = 'male_person';
  bool _isSavingCharacter = false;

  static const _characters = [
    {'key': 'male_person', 'label': 'Erkek', 'emoji': '👦'},
    {'key': 'female_person', 'label': 'Kadın', 'emoji': '👩'},
    {'key': 'male_adventurer', 'label': 'Kaşif E', 'emoji': '🧑'},
    {'key': 'female_adventurer', 'label': 'Kaşif K', 'emoji': '👩'},
    {'key': 'robot', 'label': 'Robot', 'emoji': '🤖'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild != null) {
      // Seçili karakterı avatarImageUrl'den yükle
      final saved = selectedChild.avatarImageUrl;
      if (saved != null && _characters.any((c) => c['key'] == saved)) {
        _selectedCharacter = saved;
        _savedCharacter = saved;
      }
      ref.read(avatarProvider.notifier).loadAvatarData(selectedChild.id);
    }
  }

  void _selectCharacter(String characterKey) {
    setState(() => _selectedCharacter = characterKey);
  }

  Future<void> _saveCharacter() async {
    final child = ref.read(selectedChildProvider);
    if (child == null ||
        _selectedCharacter == _savedCharacter ||
        _isSavingCharacter) {
      return;
    }

    setState(() => _isSavingCharacter = true);

    try {
      final apiService = ref.read(avatarApiServiceProvider);
      await apiService.updateCharacter(
        childProfileId: child.id,
        characterKey: _selectedCharacter,
      );
      final updatedChild = child.copyWith(avatarImageUrl: _selectedCharacter);
      await ref
          .read(childProfileProvider.notifier)
          .replaceProfileLocally(updatedChild);
      await ref.read(selectedChildProvider.notifier).selectChild(updatedChild);
      if (!mounted) return;
      setState(() => _savedCharacter = _selectedCharacter);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Avatarın kaydedildi!')));
    } catch (e) {
      debugPrint('Karakter kaydedilemedi: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar kaydedilemedi. Lütfen tekrar dene.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingCharacter = false);
      }
    }
  }

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  Widget build(BuildContext context) {
    final selectedChild = ref.watch(selectedChildProvider);
    final avatarState = ref.watch(avatarProvider);

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
                  fontSize: 18,
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
                      child: Text(
                        'Avatar Profilim',
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 22,
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
                  ],
                ),
              ),
              // Body
              Expanded(
                child: avatarState.when(
                  initial: () => Center(
                    child: Text(
                      'Veri yüklenmedi',
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
                  loaded: (availableItems, ownedItems, equippedItems) =>
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Avatar Display Card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    // Avatar Preview Area
                                    Container(
                                      width: double.infinity,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          ..._buildEquippedItemLayer(
                                            equippedItems,
                                            ItemType.background,
                                          ),
                                          Image.asset(
                                            'assets/avatar/characters/$_selectedCharacter.png',
                                            width: 180,
                                            height: 180,
                                            fit: BoxFit.contain,
                                          ),
                                          ..._buildEquippedItemLayer(
                                            equippedItems,
                                            ItemType.outfit,
                                          ),
                                          ..._buildEquippedItemLayer(
                                            equippedItems,
                                            ItemType.accessory,
                                          ),
                                          ..._buildEquippedItemLayer(
                                            equippedItems,
                                            ItemType.hat,
                                          ),
                                          ..._buildEquippedItemLayer(
                                            equippedItems,
                                            ItemType.glasses,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Character Selector
                                    SizedBox(
                                      height: 68,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: _characters.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          final c = _characters[index];
                                          final isSelected =
                                              _selectedCharacter == c['key'];
                                          return GestureDetector(
                                            onTap: () => _selectCharacter(
                                              c['key'] as String,
                                            ),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              width: 56,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white.withValues(
                                                        alpha: 0.35,
                                                      )
                                                    : Colors.white.withValues(
                                                        alpha: 0.12,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.white
                                                            .withValues(alpha: 0.3),
                                                  width: isSelected ? 2.5 : 1.5,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/avatar/characters/${c['key']}.png',
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    c['label'] as String,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: isSelected
                                                                ? 1
                                                                : 0.7,
                                                          ),
                                                      fontSize: 9,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w800
                                                          : FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _SaveAvatarButton(
                                      isChanged:
                                          _selectedCharacter != _savedCharacter,
                                      isSaving: _isSavingCharacter,
                                      onTap: _saveCharacter,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      selectedChild.name,
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
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _Game3DButton(
                                    label: '🏅 ROZETLERİM',
                                    gradientColors: const [
                                      Color(0xFF9B59B6),
                                      Color(0xFF7B61FF),
                                    ],
                                    shadowColor: const Color(0xFF4A2072),
                                    onTap: () => context.push('/badges'),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _Game3DButton(
                                    label: '🃏 KARTLARIM',
                                    gradientColors: const [
                                      Color(0xFF16A085),
                                      Color(0xFF1ABC9C),
                                    ],
                                    shadowColor: const Color(0xFF0A6B5A),
                                    onTap: () => context.push('/cards'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEquippedItemLayer(
    List<EquippedItem> equippedItems,
    ItemType type,
  ) {
    final item = equippedItems.where((e) => e.type == type).firstOrNull;
    if (item == null) return [];

    final emoji = _extractEmoji(item.name);
    final alignment = _getItemAlignment(type);
    final size = type == ItemType.hat ? 38.0 : 30.0;

    return [
      Align(
        alignment: alignment,
        child: Text(emoji, style: TextStyle(fontSize: size)),
      ),
    ];
  }

  Alignment _getItemAlignment(ItemType type) {
    // Stack height=280, image=180x180 centered → image starts at y≈50
    // Kenney idle: head top ≈ y55, eyes ≈ y80, body center ≈ y150
    // Alignment formula: (pixel_y - 140) / 140
    switch (type) {
      case ItemType.hat:
        return const Alignment(0.0, -0.60); // y≈56
      case ItemType.glasses:
        return const Alignment(0.0, -0.35); // y≈91
      case ItemType.outfit:
        return const Alignment(0.0, 0.10); // y≈154
      case ItemType.accessory:
        return const Alignment(-0.70, 0.10);
      case ItemType.background:
        return const Alignment(0.75, -0.85);
    }
  }

  String _extractEmoji(String text) {
    for (final rune in text.runes) {
      if (rune >= 0x1F000 || (rune >= 0x2190 && rune <= 0x2BFF)) {
        return String.fromCharCode(rune);
      }
    }
    return '🎁';
  }
}

class _Game3DButton extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _Game3DButton({
    required this.label,
    required this.gradientColors,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.luckiestGuy(
                fontSize: 16,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 0,
                    color: shadowColor,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveAvatarButton extends StatelessWidget {
  final bool isChanged;
  final bool isSaving;
  final VoidCallback onTap;

  const _SaveAvatarButton({
    required this.isChanged,
    required this.isSaving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = isChanged && !isSaving;
    final backgroundColor = isEnabled
        ? const Color(0xFF36A852)
        : Colors.white.withValues(alpha: 0.16);
    final shadowColor = isEnabled
        ? const Color(0xFF176E2D)
        : Colors.transparent;

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 50,
          decoration: BoxDecoration(
            color: shadowColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: isEnabled ? 4 : 0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: isEnabled ? 0.42 : 0.24),
                width: 1.3,
              ),
            ),
            child: Center(
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isChanged
                              ? Icons.check_circle_rounded
                              : Icons.check_circle_outline_rounded,
                          color: Colors.white.withValues(
                            alpha: isEnabled ? 1 : 0.55,
                          ),
                          size: 21,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isChanged ? 'AVATARI KAYDET' : 'AVATAR KAYDEDİLDİ',
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(
                              alpha: isEnabled ? 1 : 0.55,
                            ),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

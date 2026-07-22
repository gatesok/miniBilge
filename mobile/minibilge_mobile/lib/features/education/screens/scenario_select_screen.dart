import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/roleplay_models.dart';
import '../services/roleplay_service.dart';
import '../services/roleplay_attempt_store.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/services/ad_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';

class ScenarioSelectScreen extends ConsumerStatefulWidget {
  final String level;

  const ScenarioSelectScreen({super.key, required this.level});

  @override
  ConsumerState<ScenarioSelectScreen> createState() => _ScenarioSelectScreenState();
}

class _ScenarioSelectScreenState extends ConsumerState<ScenarioSelectScreen> {
  static const _bgColor    = Color(0xFF0D1B2A);
  static const _cardColor  = Color(0xFF1A2A3A);
  static const _accentColor = Color(0xFF7C4DFF);

  List<ScenarioDto> _scenarios = [];
  bool _isLoading = true;
  String? _error;

  // Hak takibi
  int _attemptsLeft = 2;
  bool _isLoadingAd = false;

  String get _childId => ref.read(selectedChildProvider)?.id ?? 'guest';

  @override
  void initState() {
    super.initState();
    _loadScenarios();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final left = await RolePlayAttemptStore.getAttemptsLeft(_childId);
    if (mounted) setState(() => _attemptsLeft = left);
  }

  Future<void> _loadScenarios() async {
    try {
      final dio = ref.read(dioProvider);
      final service = RolePlayService(dio);
      final scenarios = await service.getScenarios(widget.level);
      if (mounted) setState(() { _scenarios = scenarios; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _watchAd() async {
    setState(() => _isLoadingAd = true);
    RewardedAdService.showRewardedAd(
      placement: AdPlacements.rolePlayExtraAttempt,
      onRewarded: () async {
        await RolePlayAttemptStore.grantAttempt(_childId);
        await _loadAttempts();
      },
      onComplete: () {
        if (mounted) setState(() => _isLoadingAd = false);
      },
    );
  }

  Future<void> _selectScenario(ScenarioDto scenario) async {
    if (_attemptsLeft <= 0) return;

    // Hakkı düş
    final ok = await RolePlayAttemptStore.consumeAttempt(_childId);
    if (!ok) {
      await _loadAttempts();
      return;
    }
    await _loadAttempts();

    if (!mounted) return;
    final child = ref.read(selectedChildProvider);
    context.pushNamed(
      'roleplay-session',
      extra: {
        'scenario': scenario,
        'level': widget.level,
        'childProfileId': child?.id ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Rol Yapma · ${widget.level}',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          _AttemptsChip(attemptsLeft: _attemptsLeft),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: _accentColor))
                : _error != null
                    ? _buildError()
                    : _buildScenarioList(),
            // Kilit overlay — hak 0 olduğunda gösterilir
            if (!_isLoading && _error == null && _attemptsLeft <= 0)
              _LimitOverlay(
                isLoadingAd: _isLoadingAd,
                onWatchAd: _watchAd,
                onBack: () => context.pop(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          Text('Senaryolar yüklenemedi', style: GoogleFonts.nunito(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () { setState(() { _isLoading = true; _error = null; }); _loadScenarios(); },
            style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            'Bir senaryo seç ve konuşmaya başla!',
            style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: _scenarios.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _ScenarioCard(
              scenario: _scenarios[i],
              onTap: () => _selectScenario(_scenarios[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Senaryo Kartı ────────────────────────────────────────────────────────────

class _ScenarioCard extends StatelessWidget {
  final ScenarioDto scenario;
  final VoidCallback onTap;

  const _ScenarioCard({required this.scenario, required this.onTap});

  static const _cardColor = Color(0xFF1A2A3A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            // Emoji
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(scenario.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scenario.title,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scenario.description,
                    style: GoogleFonts.nunito(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  // Karakter rozeti
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: Colors.white38, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '${scenario.characterName} • ${scenario.characterRole}',
                        style: GoogleFonts.nunito(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Kalan Hak Rozeti ─────────────────────────────────────────────────────────

class _AttemptsChip extends StatelessWidget {
  final int attemptsLeft;
  const _AttemptsChip({required this.attemptsLeft});

  @override
  Widget build(BuildContext context) {
    final color = attemptsLeft > 1
        ? const Color(0xFF7C4DFF)
        : attemptsLeft == 1
            ? Colors.orange
            : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '🎭 $attemptsLeft',
        style: GoogleFonts.nunito(
            color: color, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

// ─── Kilit Overlay ────────────────────────────────────────────────────────────

class _LimitOverlay extends StatelessWidget {
  final bool isLoadingAd;
  final VoidCallback onWatchAd;
  final VoidCallback onBack;

  const _LimitOverlay({
    required this.isLoadingAd,
    required this.onWatchAd,
    required this.onBack,
  });

  static const _accentColor = Color(0xFF7C4DFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A3A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⏳', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  Text(
                    'Günlük Hakkın Bitti',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bugünkü 2 ücretsiz rol yapma oturumunu kullandın. Kısa bir reklam izleyerek ekstra hak kazanabilirsin.',
                    style: GoogleFonts.nunito(
                      color: Colors.white60,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoadingAd ? null : onWatchAd,
                      icon: isLoadingAd
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.play_circle_outline, color: Colors.white),
                      label: Text(
                        isLoadingAd ? 'Reklam yükleniyor...' : 'Reklam İzle → +1 Oturum',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onBack,
                    child: Text(
                      'Geri Dön',
                      style: GoogleFonts.nunito(
                          color: Colors.white54, fontSize: 14),
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

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/roleplay_models.dart';

class RolePlayResultScreen extends StatefulWidget {
  final EndSessionResponse result;
  final ScenarioDto scenario;

  const RolePlayResultScreen({
    super.key,
    required this.result,
    required this.scenario,
  });

  @override
  State<RolePlayResultScreen> createState() => _RolePlayResultScreenState();
}

class _RolePlayResultScreenState extends State<RolePlayResultScreen> {
  static const _bgColor    = Color(0xFF0D1B2A);
  static const _cardColor  = Color(0xFF1A2A3A);
  static const _accentColor = Color(0xFF7C4DFF);

  late final ConfettiController _confetti;
  bool _showTurkish = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.result.score >= 80) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (widget.result.score >= 80) return const Color(0xFF00BFA5);
    if (widget.result.score >= 50) return Colors.amber;
    return Colors.redAccent;
  }

  String get _scoreLabel {
    if (widget.result.score >= 80) return 'Mükemmel! 🌟';
    if (widget.result.score >= 50) return 'İyi İş! 👍';
    return 'Devam Et! 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Başlık
                  Text(
                    'Konuşma Tamamlandı!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.luckiestGuy(
                      color: Colors.white,
                      fontSize: 26,
                      shadows: const [Shadow(blurRadius: 0, color: Color(0xFF3D35CC), offset: Offset(2, 2))],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.scenario.emoji} ${widget.scenario.title}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // Puan çemberi
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            value: widget.result.score / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation(_scoreColor),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${widget.result.score}',
                              style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 40),
                            ),
                            Text(
                              '/100',
                              style: GoogleFonts.nunito(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _scoreLabel,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(color: _scoreColor, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 24),

                  // İstatistikler
                  _StatsRow(turnCount: widget.result.turnCount),
                  const SizedBox(height: 20),

                  // Ödüller
                  if (widget.result.starsEarned > 0)
                    _RewardBanner(stars: widget.result.starsEarned),
                  if (widget.result.starsEarned > 0)
                    const SizedBox(height: 20),

                  // Geri bildirim
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline, color: Color(0xFF7C4DFF), size: 18),
                            const SizedBox(width: 8),
                            Text('Evaluation',
                                style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                            const Spacer(),
                            // TR/EN toggle
                            GestureDetector(
                              onTap: () => setState(() => _showTurkish = !_showTurkish),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _showTurkish
                                      ? const Color(0xFF7C4DFF).withOpacity(0.25)
                                      : Colors.white10,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _showTurkish
                                        ? const Color(0xFF7C4DFF)
                                        : Colors.white24,
                                  ),
                                ),
                                child: Text(
                                  _showTurkish ? '🇹🇷 TR' : '🇬🇧 EN',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _showTurkish && widget.result.feedbackTr.isNotEmpty
                              ? widget.result.feedbackTr
                              : widget.result.feedback,
                          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  // İyileştirme ipuçları (sadece score < 100 ve improvements varsa)
                  if (widget.result.score < 100 && widget.result.improvements.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ImprovementsCard(
                      improvements: widget.result.improvements,
                      showTurkish: _showTurkish,
                    ),
                  ],
                  const SizedBox(height: 28),

                  // Butonlar
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Başka Senaryo',
                        style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.goNamed('dashboard'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Ana Sayfa',
                        style: GoogleFonts.nunito(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
          // Konfeti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [Color(0xFF7C4DFF), Color(0xFF00BFA5), Colors.amber, Colors.pinkAccent],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── İstatistik satırı ────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int turnCount;
  const _StatsRow({required this.turnCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(icon: '💬', label: 'Cevap', value: '$turnCount')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          Text(label, style: GoogleFonts.nunito(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Ödül banner ─────────────────────────────────────────────────────────────

class _RewardBanner extends StatelessWidget {
  final int stars;

  const _RewardBanner({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 6),
          Text('+$stars',
              style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        ],
      ),
    );
  }
}

// ─── İyileştirme İpuçları ─────────────────────────────────────────────────────

class _ImprovementsCard extends StatelessWidget {
  final List<ImprovementHint> improvements;
  final bool showTurkish;

  const _ImprovementsCard({
    required this.improvements,
    required this.showTurkish,
  });

  static const _areaMeta = {
    'Grammar':       ('📝', Color(0xFFFFB300), 'Dilbilgisi'),
    'Vocabulary':    ('📚', Color(0xFF29B6F6), 'Kelime Bilgisi'),
    'Fluency':       ('🗣️', Color(0xFF26A69A), 'Akıcılık'),
    'Pronunciation': ('🔊', Color(0xFFEC407A), 'Telaffuz'),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                showTurkish ? 'Gelişim Alanları' : 'How to Improve',
                style: GoogleFonts.nunito(
                  color: Colors.amber,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...improvements.map((hint) {
            final meta = _areaMeta[hint.area] ?? ('✏️', const Color(0xFF7C4DFF), hint.area);
            final areaLabel  = showTurkish ? meta.$3 : hint.area;
            final issueText  = showTurkish && hint.issueTr.isNotEmpty ? hint.issueTr : hint.issue;
            final tipText    = showTurkish && hint.suggestionTr.isNotEmpty ? hint.suggestionTr : hint.suggestion;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: meta.$2.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: meta.$2.withOpacity(0.18)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meta.$1, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            areaLabel,
                            style: GoogleFonts.nunito(
                              color: meta.$2,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            issueText,
                            style: GoogleFonts.nunito(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  tipText,
                                  style: GoogleFonts.nunito(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                  ),
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
          }),
        ],
      ),
    );
  }
}

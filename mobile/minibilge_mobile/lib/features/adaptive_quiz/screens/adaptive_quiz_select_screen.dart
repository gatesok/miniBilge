import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/adaptive_quiz_config.dart';

class AdaptiveQuizSelectScreen extends StatefulWidget {
  const AdaptiveQuizSelectScreen({super.key});

  @override
  State<AdaptiveQuizSelectScreen> createState() =>
      _AdaptiveQuizSelectScreenState();
}

class _AdaptiveQuizSelectScreenState extends State<AdaptiveQuizSelectScreen> {
  String? _selectedSubject; // "Matematik" | "İngilizce"
  String? _selectedLevel;   // "3. Sınıf" | "B2" vb.

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4FACFE), Color(0xFF7B2FBE), Color(0xFF4776E6)],
  );

  // Matematik sınıfları
  static const _mathLevels = [
    ('1. Sınıf', 1, 1),
    ('2. Sınıf', 2, 1),
    ('3. Sınıf', 3, 2),
    ('4. Sınıf', 4, 2),
  ]; // (displayName, gradeLevel, difficulty)

  // İngilizce CEFR seviyeleri
  static const _englishLevels = [
    ('A1 – Başlangıç',  'A1', 1, 1),
    ('A2 – Temel',      'A2', 1, 1),
    ('B1 – Orta Altı',  'B1', 1, 2),
    ('B2 – Orta',       'B2', 1, 2),
    ('C1 – Orta Üstü',  'C1', 1, 3),
    ('C2 – Ustalık',    'C2', 1, 3),
  ]; // (displayName, code, gradeLevel, difficulty)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) context.pop();
                        else context.go('/dashboard');
                      },
                    ),
                    Expanded(
                      child: Text('🤖 Sana Özel Quiz',
                          style: GoogleFonts.luckiestGuy(
                              color: Colors.white,
                              fontSize: 20,
                              shadows: const [
                                Shadow(
                                    blurRadius: 0,
                                    color: Color(0xFF2C0654),
                                    offset: Offset(1, 1))
                              ])),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Adım 1: Ders seç
                      _StepLabel(step: '1', title: 'Ders Seç'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SubjectCard(
                              emoji: '🔢',
                              label: 'Matematik',
                              selected: _selectedSubject == 'Matematik',
                              onTap: () => setState(() {
                                _selectedSubject = 'Matematik';
                                _selectedLevel  = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SubjectCard(
                              emoji: '🇬🇧',
                              label: 'İngilizce',
                              selected: _selectedSubject == 'İngilizce',
                              onTap: () => setState(() {
                                _selectedSubject = 'İngilizce';
                                _selectedLevel  = null;
                              }),
                            ),
                          ),
                        ],
                      ),

                      // Adım 2: Seviye seç (ders seçildiyse göster)
                      if (_selectedSubject != null) ...[
                        const SizedBox(height: 28),
                        _StepLabel(
                          step: '2',
                          title: _selectedSubject == 'Matematik'
                              ? 'Sınıf Seç'
                              : 'Seviye Seç',
                        ),
                        const SizedBox(height: 12),
                        if (_selectedSubject == 'Matematik')
                          ..._mathLevels.map((l) => _LevelTile(
                                label: l.$1,
                                selected: _selectedLevel == l.$1,
                                onTap: () =>
                                    setState(() => _selectedLevel = l.$1),
                              ))
                        else
                          ..._englishLevels.map((l) => _LevelTile(
                                label: l.$1,
                                selected: _selectedLevel == l.$1,
                                onTap: () =>
                                    setState(() => _selectedLevel = l.$1),
                              )),
                      ],

                      // Başla butonu
                      if (_selectedSubject != null &&
                          _selectedLevel != null) ...[
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: _startQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7B2FBE),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Soruları Üret 🚀',
                              style: GoogleFonts.luckiestGuy(
                                  fontSize: 18,
                                  shadows: const [
                                    Shadow(
                                        blurRadius: 0,
                                        color: Color(0xFF4A0090),
                                        offset: Offset(1, 1))
                                  ])),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz() {
    if (_selectedSubject == null || _selectedLevel == null) return;

    AdaptiveQuizConfig config;

    if (_selectedSubject == 'Matematik') {
      final level = _mathLevels.firstWhere((l) => l.$1 == _selectedLevel);
      config = AdaptiveQuizConfig(
        subjectName:  'Matematik',
        levelDisplay: level.$1,
        topicName:    '${level.$1} Matematik',
        gradeLevel:   level.$2,
        difficulty:   level.$3,
      );
    } else {
      final level = _englishLevels.firstWhere((l) => l.$1 == _selectedLevel);
      config = AdaptiveQuizConfig(
        subjectName:  'İngilizce',
        levelDisplay: level.$2, // "B2"
        topicName:    '${level.$2} English',
        gradeLevel:   level.$3,
        difficulty:   level.$4,
      );
    }

    context.push('/adaptive-quiz', extra: config);
  }
}

// ── Yardımcı widget'lar ───────────────────────────────────────────────────────

class _StepLabel extends StatelessWidget {
  final String step;
  final String title;
  const _StepLabel({required this.step, required this.title});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Center(
              child: Text(step,
                  style: const TextStyle(
                      color: Color(0xFF7B2FBE),
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ],
      );
}

class _SubjectCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool   selected;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.white : Colors.white38,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(label,
                  style: GoogleFonts.nunito(
                      color: selected
                          ? const Color(0xFF7B2FBE)
                          : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ],
          ),
        ),
      );
}

class _LevelTile extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;

  const _LevelTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white
                  : Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.white : Colors.white30,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? const Color(0xFF7B2FBE)
                      : Colors.white60,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(label,
                    style: GoogleFonts.nunito(
                        color: selected
                            ? const Color(0xFF7B2FBE)
                            : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      );
}

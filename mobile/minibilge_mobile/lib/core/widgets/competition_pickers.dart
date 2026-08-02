import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Yarışma seçim ekranlarında (meydan okuma + canlı yarış) ortak kullanılan
/// tasarım bileşenleri: numaralı bölüm başlığı, mod kartı, zorluk
/// (yeşil-sarı-kırmızı) ve konu/seviye pill'leri.

const _accent = Color(0xFF7B61FF);
const _accent2 = Color(0xFF9C6BFF);
const _ink = Color(0xFF2D2060);

/// Numaralı bölüm başlığı: mor daire içinde numara + başlık metni.
Widget competitionSectionLabel(int n, String title) => Row(
  children: [
    Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_accent, _accent2]),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$n',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    ),
    const SizedBox(width: 8),
    Text(
      title,
      style: GoogleFonts.nunito(
        fontWeight: FontWeight.w900,
        fontSize: 15,
        color: _ink,
      ),
    ),
  ],
);

/// Yarışma türü kartı (Genel Kültür Düellosu / İngilizce Quiz gibi).
class CompetitionModeCard extends StatelessWidget {
  const CompetitionModeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEADFFF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? _accent : const Color(0xFFE7DEF8),
          width: selected ? 2 : 1.5,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_accent, _accent2]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: _ink,
              ),
            ),
          ),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? _accent : const Color(0xFFCFC4EC),
          ),
        ],
      ),
    ),
  );
}

/// Kolay-Orta-Zor zorluk seçici — yeşil-sarı-kırmızı, eşit genişlikte 3 pill.
class DifficultyPills extends StatelessWidget {
  const DifficultyPills({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String? selected;
  final ValueChanged<String> onSelect;

  static const _items = ['Kolay', 'Orta', 'Zor'];

  @override
  Widget build(BuildContext context) => Row(
    children: _items.map((d) {
      final sel = selected == d;
      final color = difficultyColor(d);
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: d == _items.last ? 0 : 8),
          child: GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? color : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? color : color.withValues(alpha: 0.35),
                  width: sel ? 2 : 1.5,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.40),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Icon(
                    difficultyIcon(d),
                    color: sel ? Colors.white : color,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d,
                    style: GoogleFonts.nunito(
                      color: sel ? Colors.white : color,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

/// Konu / seviye seçimi için mor pill (seçili = mor gradient, boşta = açık mor).
class CompetitionPill extends StatelessWidget {
  const CompetitionPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(colors: [_accent, _accent2])
            : null,
        color: selected ? null : const Color(0xFFEDE7FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? _accent : const Color(0xFFDED4F6),
          width: 1.5,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.32),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: selected ? Colors.white : const Color(0xFF4A3B8A),
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    ),
  );
}

/// Zorluk rengi: Kolay = yeşil, Orta = sarı, Zor = kırmızı.
Color difficultyColor(String d) {
  switch (d) {
    case 'Kolay':
      return const Color(0xFF43A047);
    case 'Zor':
      return const Color(0xFFE05252);
    default:
      return const Color(0xFFE2A52C);
  }
}

IconData difficultyIcon(String d) {
  switch (d) {
    case 'Kolay':
      return Icons.sentiment_satisfied_alt_rounded;
    case 'Zor':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.psychology_alt_rounded;
  }
}

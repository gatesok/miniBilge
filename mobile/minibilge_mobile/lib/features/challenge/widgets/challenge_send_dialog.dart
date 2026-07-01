import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../education/models/subject.dart';
import '../../education/models/topic.dart';
import '../../education/models/level.dart';
import '../../education/providers/subject_provider.dart';
import '../../education/providers/topic_provider.dart';
import '../../education/providers/level_provider.dart';
import '../providers/challenge_provider.dart';

/// Arkadaşa meydan okuma göndermek için konu/seviye seçim diyalogu.
/// [challengeeId] hedef çocuğun ID'si, [challengeeName] kartındaki isim.
Future<void> showChallengeSendDialog(
  BuildContext context, {
  required String challengeeId,
  required String challengeeName,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ChallengeSendSheet(
      challengeeId: challengeeId,
      challengeeName: challengeeName,
    ),
  );
}

class _ChallengeSendSheet extends ConsumerStatefulWidget {
  final String challengeeId;
  final String challengeeName;

  const _ChallengeSendSheet({
    required this.challengeeId,
    required this.challengeeName,
  });

  @override
  ConsumerState<_ChallengeSendSheet> createState() => _ChallengeSendSheetState();
}

class _ChallengeSendSheetState extends ConsumerState<_ChallengeSendSheet> {
  Subject? _subject;
  Topic? _topic;
  Level? _level;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            '⚔️ ${widget.challengeeName}\'a Meydan Oku',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Konu ve seviye seç, rakibine meydan okumayı gönder!',
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 18),

          // ── Ders seçimi ──────────────────────────────────────────
          _SectionLabel('Ders'),
          ref.watch(subjectListProvider).when(
                data: (subjects) => _ChipRow<Subject>(
                  items: subjects.where((s) => s.isActive).toList(),
                  selected: _subject,
                  label: (s) => s.name,
                  onTap: (s) => setState(() {
                    _subject = s;
                    _topic   = null;
                    _level   = null;
                  }),
                ),
                loading: () => const _Loading(),
                error: (e, _) => Text('Hata: $e',
                    style: const TextStyle(color: Colors.white70)),
              ),
          const SizedBox(height: 14),

          // ── Konu seçimi ──────────────────────────────────────────
          if (_subject != null) ...[
            _SectionLabel('Konu'),
            ref.watch(topicListProvider(_subject!.id)).when(
                  data: (topics) => _ChipRow<Topic>(
                    items: topics.where((t) => t.isActive).toList(),
                    selected: _topic,
                    label: (t) => t.name,
                    onTap: (t) => setState(() {
                      _topic = t;
                      _level = null;
                    }),
                  ),
                  loading: () => const _Loading(),
                  error: (e, _) => Text('Hata: $e',
                      style: const TextStyle(color: Colors.white70)),
                ),
            const SizedBox(height: 14),
          ],

          // ── Seviye seçimi ────────────────────────────────────────
          if (_topic != null) ...[
            _SectionLabel('Seviye'),
            ref.watch(levelListProvider(_topic!.id)).when(
                  data: (levels) => _ChipRow<Level>(
                    items: levels.where((l) => l.isActive).toList(),
                    selected: _level,
                    label: (l) => l.name,
                    onTap: (l) => setState(() => _level = l),
                  ),
                  loading: () => const _Loading(),
                  error: (e, _) => Text('Hata: $e',
                      style: const TextStyle(color: Colors.white70)),
                ),
            const SizedBox(height: 20),
          ],

          // ── Gönder butonu ────────────────────────────────────────
          if (_level != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5ACD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        '⚔️ Meydan Oku!',
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
    );
  }

  Future<void> _send() async {
    final level = _level;
    if (level == null) return;
    setState(() => _sending = true);
    try {
      await ref.read(challengeNotifierProvider.notifier).sendChallenge(
            challengeeId: widget.challengeeId,
            levelId: level.id,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${widget.challengeeName}\'a meydan okuma gönderildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

// ── Yardımcı widgetlar ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1),
        ),
      );
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
}

class _ChipRow<T> extends StatelessWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T> onTap;

  const _ChipRow({
    required this.items,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 6,
        children: items
            .map(
              (item) => GestureDetector(
                onTap: () => onTap(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected == item
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected == item
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    label(item),
                    style: GoogleFonts.nunito(
                      color: selected == item
                          ? const Color(0xFF6A5ACD)
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/badge_dto.dart';
import '../providers/collection_provider.dart';

/// Dashboard için "Yaklaşan Rozetler": tamamlanmaya en yakın 1–2 kilitli rozeti
/// ilerleme çubuğuyla gösterir. Henüz ilerleme yoksa hiç görünmez.
class UpcomingBadges extends ConsumerWidget {
  final String childId;
  const UpcomingBadges({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(badgeCollectionProvider(childId));

    return async.maybeWhen(
      data: (collection) {
        final upcoming =
            collection.badges
                .where(
                  (b) =>
                      !b.isEarned &&
                      b.isApplicableToProfile &&
                      b.progress != null &&
                      b.progress!.target > 0 &&
                      b.progress!.current > 0,
                )
                .toList()
              ..sort((a, b) => b.progress!.ratio.compareTo(a.progress!.ratio));

        if (upcoming.isEmpty) return const SizedBox.shrink();
        final top = upcoming.take(2).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFFFFD54F),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Yaklaşan Rozetler',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < top.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _UpcomingCard(badge: top[i]),
              ],
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final BadgeDto badge;
  const _UpcomingCard({required this.badge});

  String get _label {
    final p = badge.progress!;
    return p.unit == 'percent' ? '%${p.current}' : '${p.current}/${p.target}';
  }

  @override
  Widget build(BuildContext context) {
    final p = badge.progress!;
    return GestureDetector(
      onTap: () => context.push('/badges'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.2),
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/badges/${badge.key}.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Text(badge.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.ratio,
                      minHeight: 5,
                      backgroundColor: Colors.white.withOpacity(0.22),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFFFD54F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _label,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

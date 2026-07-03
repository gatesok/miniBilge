import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/adaptive_quiz_provider.dart';
import '../models/adaptive_quiz_models.dart';

/// Dashboard'da gösterilen "Sana Özel Quiz" banner'ı.
/// Yalnızca çocuğun zayıf konusu varsa görünür.
class AdaptiveQuizBanner extends ConsumerWidget {
  const AdaptiveQuizBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(weakTopicsProvider);

    return topicsAsync.maybeWhen(
      data: (topics) {
        // Zayıf konu yoksa demo kart göster (kaldırılacak — production'da SizedBox.shrink())
        final topic = topics.isNotEmpty
            ? topics.first
            : WeakTopicModel(
                subjectName: 'İngilizce',
                topicName: 'Gramer Konuları',
                avgSuccessPercent: 55,
                attemptCount: 0,
                suggestedDifficulty: 2,
              );
        return _BannerCard(topic: topic);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final WeakTopicModel topic;
  const _BannerCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/adaptive-quiz/select'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B2FBE), Color(0xFF4776E6)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B2FBE).withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sana Özel Quiz!',
                      style: GoogleFonts.luckiestGuy(
                        color: Colors.white,
                        fontSize: 16,
                        shadows: const [
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF2C0654),
                              offset: Offset(1, 1))
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${topic.subjectName} · ${topic.topicName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Başarı oranın: %${topic.avgSuccessPercent.toStringAsFixed(0)} — AI ile pratik yap!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white70, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../child_profile/providers/selected_child_provider.dart';
import '../../education/models/certificate_data.dart';
import '../../education/widgets/certificate_preview_dialog.dart';
import '../../progress/providers/progress_provider.dart';

class CertificateGalleryScreen extends ConsumerStatefulWidget {
  const CertificateGalleryScreen({super.key});

  @override
  ConsumerState<CertificateGalleryScreen> createState() =>
      _CertificateGalleryScreenState();
}

class _CertificateGalleryScreenState
    extends ConsumerState<CertificateGalleryScreen> {
  String _filter = 'all';

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(selectedChildProvider);
    if (child == null) return const Scaffold(body: SizedBox.shrink());
    final certificates = ref.watch(certificatesProvider(child.id));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Başarı Sertifikalarım',
                        style: GoogleFonts.luckiestGuy(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterButton('all', 'Tümü'),
                    const SizedBox(width: 8),
                    _filterButton('mathematics', 'Matematik'),
                    const SizedBox(width: 8),
                    _filterButton('english', 'İngilizce'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: certificates.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (_, _) => Center(
                    child: Text(
                      'Sertifikalar yüklenemedi.',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  data: _grid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String value, String label) {
    final selected = _filter == value;
    return Expanded(
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        showCheckmark: false,
        label: Center(child: Text(label)),
        labelStyle: GoogleFonts.nunito(
          color: selected ? const Color(0xFF4A3FCC) : Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
        selectedColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
      ),
    );
  }

  Widget _grid(List<CertificateData> all) {
    final certificates = all.where((certificate) {
      return _filter == 'all' || certificate.subjectCode == _filter;
    }).toList();
    if (certificates.isEmpty) {
      return Center(
        child: Text(
          'Bu kategoride sertifika yok.',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.93,
      ),
      itemCount: certificates.length,
      itemBuilder: (_, index) => _certificateCard(certificates[index]),
    );
  }

  Widget _certificateCard(CertificateData certificate) {
    final accent = certificate.isEnglish
        ? const Color(0xFF8257F5)
        : const Color(0xFF099CB0);
    final date = certificate.completedAt;
    return Material(
      color: Colors.white.withValues(alpha: 0.17),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => showCertificatePreview(context, certificate),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  certificate.isEnglish
                      ? Icons.translate_rounded
                      : Icons.calculate_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                certificate.topicName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '%${certificate.scorePercentage}',
                style: GoogleFonts.luckiestGuy(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              Text(
                '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

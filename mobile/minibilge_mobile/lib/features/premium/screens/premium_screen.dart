import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/legal_config.dart';
import '../providers/premium_provider.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(premiumProvider);
    final notifier = ref.read(premiumProvider.notifier);
    final selectedProductId = _selectedProductId ?? premiumYearlyProductId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MiniBilge Premium'),
        backgroundColor: const Color(0xFF7EC8F0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFF7EC8F0), // sky blue
              Color(0xFFAA9FE8), // lavender
              Color(0xFFC4A8E2), // soft violet
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFFB45CFF)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 52)),
                          const SizedBox(height: 8),
                          Text(
                            state.isPremium
                                ? 'Premium üyeliğin aktif'
                                : 'Çocuğuna özel öğrenme yolculuğu',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _Benefit(
                            icon: Icons.auto_awesome_rounded,
                            label: 'Günde 10 kişisel AI quiz hakkı',
                          ),
                          const _Benefit(
                            icon: Icons.quiz_rounded,
                            label:
                                'Matematik ve İngilizce quizlerinde sınırsız erişim',
                          ),
                          const _Benefit(
                            icon: Icons.podcasts_rounded,
                            label: 'Tüm podcastleri sınırsız dinleme',
                          ),
                          const _Benefit(
                            icon: Icons.family_restroom_rounded,
                            label: '3 çocuk profiline kadar tek üyelik',
                          ),
                          const _Benefit(
                            icon: Icons.insights_rounded,
                            label: '90 günlük ayrıntılı gelişim görünümü',
                          ),
                          const _Benefit(
                            icon: Icons.palette_rounded,
                            label: 'Özel kart, avatar ve rozet koleksiyonları',
                          ),
                          const _Benefit(
                            icon: Icons.download_for_offline_rounded,
                            label:
                                'Podcastleri çevrimdışı dinlemek için indirme',
                          ),
                          const _Benefit(
                            icon: Icons.workspace_premium_rounded,
                            label: 'Seviye ve dönem başarı sertifikaları',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!state.isStoreAvailable && !state.isPremium)
                      const _InfoCard(
                        text:
                            'Ürünler App Store’dan yüklenemedi. App Store bağlantını kontrol edip tekrar aç.',
                        error: true,
                      ),
                    if (state.products.isEmpty &&
                        state.isStoreAvailable &&
                        !state.isPremium)
                      const _InfoCard(
                        text:
                            'Premium ürünleri henüz App Store’da kullanıma hazır değil.',
                        error: true,
                      ),
                    ...state.products.map(
                      (product) => _ProductCard(
                        product: product,
                        isYearly: product.id == premiumYearlyProductId,
                        isSelected: product.id == selectedProductId,
                        isBusy: state.processingProductId != null,
                        onSelect: () =>
                            setState(() => _selectedProductId = product.id),
                        onBuy: () => notifier.buy(product),
                      ),
                    ),
                    if (state.message != null) ...[
                      const SizedBox(height: 8),
                      _InfoCard(text: state.message!, error: state.isError),
                    ],
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: state.processingProductId == null
                          ? notifier.restore
                          : null,
                      child: state.processingProductId == 'restore'
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Satın Alımları Geri Yükle'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ödeme, onayladığında mağaza hesabından (App Store / Google '
                      'Play) alınır. Abonelik, mevcut dönemin bitiminden en az 24 saat '
                      'önce iptal edilmezse otomatik yenilenir. Aboneliğini istediğin '
                      'zaman mağaza hesap ayarlarından yönetebilirsin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _LegalLink(
                          label: 'Aboneliği Yönet',
                          onTap: () => _openUrl(
                            context,
                            LegalConfig.manageSubscriptionsUrl,
                          ),
                        ),
                        const _LinkDot(),
                        _LegalLink(
                          label: 'Kullanım Koşulları',
                          onTap: () =>
                              _openUrl(context, LegalConfig.termsOfUseUrl),
                        ),
                        const _LinkDot(),
                        _LegalLink(
                          label: 'Gizlilik Politikası',
                          onTap: () =>
                              _openUrl(context, LegalConfig.privacyPolicyUrl),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bağlantı açılamadı.')));
    }
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6C4CE5),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LinkDot extends StatelessWidget {
  const _LinkDot();

  @override
  Widget build(BuildContext context) {
    return const Text('•', style: TextStyle(color: Colors.black26));
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isYearly,
    required this.isSelected,
    required this.isBusy,
    required this.onSelect,
    required this.onBuy,
  });

  final ProductDetails product;
  final bool isYearly;
  final bool isSelected;
  final bool isBusy;
  final VoidCallback onSelect;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? const Color(0xFF7A5CFA) : Colors.black12,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: isBusy ? null : onSelect,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isYearly)
                      const Text(
                        'EN AVANTAJLI',
                        style: TextStyle(
                          color: Color(0xFF6C4CE5),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    Text(
                      isYearly ? 'Yıllık Premium' : 'Aylık Premium',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: isBusy ? null : onBuy,
                child: const Text('Seç'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text, required this.error});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: error ? const Color(0xFFB3261E) : const Color(0xFF267A37),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

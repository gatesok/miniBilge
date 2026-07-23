import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../providers/premium_provider.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumProvider);
    final notifier = ref.read(premiumProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: const Text('MiniBilge Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
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
                              : 'Öğrenirken reklamlara veda et',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _Benefit(
                          icon: Icons.block_rounded,
                          label: 'Tüm profillerde reklamsız deneyim',
                        ),
                        const _Benefit(
                          icon: Icons.all_inclusive_rounded,
                          label: 'Premium içerik hakları tüm profillerde',
                        ),
                        const _Benefit(
                          icon: Icons.family_restroom_rounded,
                          label: 'Tek üyelik, ailedeki bütün profiller',
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
                      isBusy: state.processingProductId != null,
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
                    'Ödeme Apple ID hesabından alınır. Abonelik, mevcut dönemin '
                    'bitiminden en az 24 saat önce iptal edilmezse otomatik yenilenir. '
                    'Aboneliğini App Store hesap ayarlarından yönetebilirsin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
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
    required this.isBusy,
    required this.onBuy,
  });

  final ProductDetails product;
  final bool isYearly;
  final bool isBusy;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isYearly ? 4 : 1,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isYearly ? const Color(0xFF7A5CFA) : Colors.black12,
          width: isYearly ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
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
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
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

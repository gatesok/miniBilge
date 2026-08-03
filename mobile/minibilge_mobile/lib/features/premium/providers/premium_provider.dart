import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/premium_status.dart';
import '../services/premium_api_service.dart';

const premiumMonthlyProductId = 'minibilge_premium_monthly';
const premiumYearlyProductId = 'minibilge_premium_yearly';
const _premiumProductIds = {premiumMonthlyProductId, premiumYearlyProductId};

class PremiumState {
  const PremiumState({
    this.isLoading = true,
    this.isStoreAvailable = false,
    this.isPremium = false,
    this.products = const [],
    this.processingProductId,
    this.message,
    this.isError = false,
  });

  final bool isLoading;
  final bool isStoreAvailable;
  final bool isPremium;
  final List<ProductDetails> products;
  final String? processingProductId;
  final String? message;
  final bool isError;

  PremiumState copyWith({
    bool? isLoading,
    bool? isStoreAvailable,
    bool? isPremium,
    List<ProductDetails>? products,
    String? processingProductId,
    bool clearProcessingProduct = false,
    String? message,
    bool clearMessage = false,
    bool? isError,
  }) {
    return PremiumState(
      isLoading: isLoading ?? this.isLoading,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      isPremium: isPremium ?? this.isPremium,
      products: products ?? this.products,
      processingProductId: clearProcessingProduct
          ? null
          : processingProductId ?? this.processingProductId,
      message: clearMessage ? null : message ?? this.message,
      isError: isError ?? this.isError,
    );
  }
}

final premiumApiServiceProvider = Provider<PremiumApiService>((ref) {
  return PremiumApiService(ref.read(dioProvider));
});

final premiumProvider =
    StateNotifierProvider.autoDispose<PremiumNotifier, PremiumState>((ref) {
      final userId = ref.read(
        authProvider.select(
          (state) => state.maybeWhen(
            authenticated: (user) => user.id,
            orElse: () => '',
          ),
        ),
      );
      return PremiumNotifier(
        ref,
        ref.read(premiumApiServiceProvider),
        InAppPurchase.instance,
        userId,
      );
    });

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier(this._ref, this._api, this._store, this._userId)
    : super(const PremiumState()) {
    _subscription = _store.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        state = state.copyWith(
          isLoading: false,
          clearProcessingProduct: true,
          message: 'Satın alma bilgisi alınamadı. Lütfen tekrar deneyin.',
          isError: true,
        );
      },
    );
    unawaited(_initialize());
  }

  final Ref _ref;
  final PremiumApiService _api;
  final InAppPurchase _store;
  final String _userId;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> _initialize() async {
    unawaited(AnalyticsService.logEvent(AnalyticsEvents.paywallView));
    try {
      final status = await _api.getStatus();
      _applyPremiumStatus(status.isPremium, status.expiresAt);

      final available = await _store.isAvailable();
      if (!available) {
        state = state.copyWith(
          isLoading: false,
          isStoreAvailable: false,
          isPremium: status.isPremium,
          message: 'App Store şu anda kullanılamıyor.',
          isError: true,
        );
        return;
      }

      final response = await _store.queryProductDetails(_premiumProductIds);
      final products = [...response.productDetails]
        ..sort((a, b) {
          if (a.id == premiumMonthlyProductId) return -1;
          if (b.id == premiumMonthlyProductId) return 1;
          return a.rawPrice.compareTo(b.rawPrice);
        });

      state = state.copyWith(
        isLoading: false,
        isStoreAvailable: true,
        products: products,
        isPremium: status.isPremium,
        message: response.error?.message,
        isError: response.error != null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        message: 'Premium bilgileri yüklenemedi.',
        isError: true,
      );
    }
  }

  Future<void> buy(ProductDetails product) async {
    if (_userId.isEmpty || state.processingProductId != null) return;
    unawaited(
      AnalyticsService.logEvent(
        AnalyticsEvents.paywallPlanSelected,
        parameters: {'product_id': product.id},
      ),
    );
    state = state.copyWith(
      processingProductId: product.id,
      clearMessage: true,
      isError: false,
    );
    try {
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.purchaseStarted,
          parameters: {'product_id': product.id},
        ),
      );
      await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: _userId,
        ),
      );
    } catch (_) {
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.purchaseFailed,
          parameters: {'product_id': product.id, 'reason': 'start_error'},
        ),
      );
      state = state.copyWith(
        clearProcessingProduct: true,
        message: 'Satın alma başlatılamadı.',
        isError: true,
      );
    }
  }

  Future<void> restore() async {
    if (state.processingProductId != null) return;
    state = state.copyWith(
      processingProductId: 'restore',
      clearMessage: true,
      isError: false,
    );
    try {
      await _store.restorePurchases(applicationUserName: _userId);
      state = state.copyWith(
        clearProcessingProduct: true,
        message: 'Geri yükleme isteği tamamlandı.',
        isError: false,
      );
    } catch (_) {
      state = state.copyWith(
        clearProcessingProduct: true,
        message: 'Satın alımlar geri yüklenemedi.',
        isError: true,
      );
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (!_premiumProductIds.contains(purchase.productID)) continue;

      if (purchase.status == PurchaseStatus.pending) {
        state = state.copyWith(processingProductId: purchase.productID);
        continue;
      }

      if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.purchaseFailed,
            parameters: {
              'product_id': purchase.productID,
              'reason': purchase.status == PurchaseStatus.canceled
                  ? 'canceled'
                  : 'store_error',
            },
          ),
        );
        state = state.copyWith(
          clearProcessingProduct: true,
          message: purchase.status == PurchaseStatus.canceled
              ? 'Satın alma iptal edildi.'
              : purchase.error?.message ?? 'Satın alma tamamlanamadı.',
          isError: purchase.status != PurchaseStatus.canceled,
        );
        if (purchase.pendingCompletePurchase) {
          await _store.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Android'de premium sunucu tarafında Google Play RTDN webhook'u ile
        // aktive olur; istemci Apple doğrulaması yapmaz (ayrı akış).
        if (Platform.isAndroid) {
          await _handleAndroidPurchase(purchase);
          continue;
        }

        final transactionId = purchase.purchaseID;
        if (transactionId == null || transactionId.isEmpty) {
          state = state.copyWith(
            clearProcessingProduct: true,
            message: 'App Store işlem kimliği alınamadı.',
            isError: true,
          );
          continue;
        }

        try {
          final verified = await _api.verifyApplePurchase(
            transactionId: transactionId,
            productId: purchase.productID,
          );
          if (!verified.isPremium) {
            throw StateError('Abonelik aktif değil');
          }
          _applyPremiumStatus(true, verified.expiresAt);
          unawaited(
            AnalyticsService.logEvent(
              purchase.status == PurchaseStatus.restored
                  ? AnalyticsEvents.purchaseRestored
                  : AnalyticsEvents.purchaseCompleted,
              parameters: {'product_id': purchase.productID},
            ),
          );
          state = state.copyWith(
            isPremium: true,
            clearProcessingProduct: true,
            message: purchase.status == PurchaseStatus.restored
                ? 'Premium üyeliğin geri yüklendi.'
                : 'MiniBilge Premium aktif!',
            isError: false,
          );
          if (purchase.pendingCompletePurchase) {
            await _store.completePurchase(purchase);
          }
        } catch (_) {
          unawaited(
            AnalyticsService.logEvent(
              AnalyticsEvents.purchaseFailed,
              parameters: {
                'product_id': purchase.productID,
                'reason': 'verify_failed',
              },
            ),
          );
          state = state.copyWith(
            clearProcessingProduct: true,
            message:
                'Satın alma doğrulanamadı. İşlem tamamlanmadı; tekrar deneyebilirsin.',
            isError: true,
          );
        }
      }
    }
  }

  /// Android: satın alma sonrası Apple doğrulaması yapılmaz. Store işlemi tamamlanır
  /// ve premium (Google Play RTDN webhook'u ile) aktifleşene kadar durum yoklanır.
  Future<void> _handleAndroidPurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _store.completePurchase(purchase);
    }

    PremiumStatus? status;
    for (var attempt = 0; attempt < 5; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      try {
        status = await _api.getStatus();
      } catch (_) {
        status = null;
      }
      if (status?.isPremium == true) break;
    }

    if (status?.isPremium == true) {
      _applyPremiumStatus(true, status!.expiresAt);
      unawaited(
        AnalyticsService.logEvent(
          purchase.status == PurchaseStatus.restored
              ? AnalyticsEvents.purchaseRestored
              : AnalyticsEvents.purchaseCompleted,
          parameters: {'product_id': purchase.productID},
        ),
      );
      state = state.copyWith(
        isPremium: true,
        clearProcessingProduct: true,
        message: purchase.status == PurchaseStatus.restored
            ? 'Premium üyeliğin geri yüklendi.'
            : 'MiniBilge Premium aktif!',
        isError: false,
      );
    } else {
      // Webhook henüz işlenmemiş olabilir; hata değil, bekleme mesajı.
      state = state.copyWith(
        clearProcessingProduct: true,
        message:
            'Satın alman alındı. Premium birkaç dakika içinde aktifleşecek.',
        isError: false,
      );
    }
  }

  void _applyPremiumStatus(bool isPremium, DateTime? expiresAt) {
    _ref
        .read(authProvider.notifier)
        .updatePremiumStatus(isPremium: isPremium, expiresAt: expiresAt);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

import 'dart:io';

/// Yasal ve abonelik bağlantıları (App Store & Play Store uyumlu).
///
/// TODO(domain): Kendi domain'in yayına girince [termsOfUseUrl] ve
/// [privacyPolicyUrl] değerlerini gerçek, barındırılan sayfalarla değiştir.
/// Her iki store da bu iki sayfanın erişilebilir olmasını zorunlu tutar.
abstract final class LegalConfig {
  /// Kullanım Koşulları (EULA). Tek URL her iki platformda da geçerli.
  static const String termsOfUseUrl =
      'https://minibilgeapp.com/kullanim-kosullari';

  /// Gizlilik Politikası. Tek URL her iki platformda da geçerli.
  static const String privacyPolicyUrl =
      'https://minibilgeapp.com/gizlilik';

  /// Aktif aboneliği yönetme sayfası — platforma göre store hesap ekranı.
  static String get manageSubscriptionsUrl => Platform.isIOS
      ? 'https://apps.apple.com/account/subscriptions'
      : 'https://play.google.com/store/account/subscriptions';

  /// Yasal URL'ler henüz gerçek domain ile doldurulmadıysa true döner.
  static bool get hasPlaceholderLegalUrls =>
      termsOfUseUrl.contains('example.com') ||
      privacyPolicyUrl.contains('example.com');
}

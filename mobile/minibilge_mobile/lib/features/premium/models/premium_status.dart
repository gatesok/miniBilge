class PremiumStatus {
  const PremiumStatus({
    required this.isPremium,
    this.productId,
    this.expiresAt,
  });

  final bool isPremium;
  final String? productId;
  final DateTime? expiresAt;

  factory PremiumStatus.fromJson(Map<String, dynamic> json) {
    return PremiumStatus(
      isPremium: json['IsPremium'] as bool? ?? false,
      productId: json['ProductId'] as String?,
      expiresAt: json['ExpiresAt'] == null
          ? null
          : DateTime.tryParse(json['ExpiresAt'] as String),
    );
  }
}

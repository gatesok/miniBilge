import 'package:dio/dio.dart';

import '../models/premium_status.dart';

class PremiumApiService {
  const PremiumApiService(this._dio);

  final Dio _dio;

  Future<PremiumStatus> getStatus() async {
    final response = await _dio.get('/premium/status');
    return PremiumStatus.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PremiumStatus> verifyApplePurchase({
    required String transactionId,
    required String productId,
  }) async {
    final response = await _dio.post(
      '/premium/verify',
      data: {'TransactionId': transactionId, 'ProductId': productId},
    );
    return PremiumStatus.fromJson(response.data as Map<String, dynamic>);
  }
}

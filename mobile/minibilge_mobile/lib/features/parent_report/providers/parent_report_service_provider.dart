import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../services/parent_report_api_service.dart';

final parentReportApiServiceProvider = Provider<ParentReportApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ParentReportApiService(dio);
});

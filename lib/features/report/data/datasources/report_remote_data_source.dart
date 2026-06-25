import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource({required this.api, required this.dio});

  final lucent.ReportsApi api;
  final Dio dio;

  Future<lucent.ReportDashboardDataDto> fetchDashboard(
    ReportDashboardRange range, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await api.reportsControllerGetDashboardV1(
      range: range.apiValue,
      startDate: range == ReportDashboardRange.custom ? startDate : null,
      endDate: range == ReportDashboardRange.custom ? endDate : null,
    );
    return response.data!.data;
  }
}

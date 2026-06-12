import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;

class ReportRemoteDataSource {
  ReportRemoteDataSource({required this.api, required this.dio});

  final lucent.ReportsApi api;
  final Dio dio;

  Future<lucent.ReportDashboardDataDto> fetchDashboard() async {
    final response = await api.reportsControllerGetDashboardV1();
    return response.data!.data;
  }
}

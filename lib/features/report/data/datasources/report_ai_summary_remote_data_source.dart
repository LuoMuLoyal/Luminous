import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;

class ReportAiSummaryRemoteDataSource {
  ReportAiSummaryRemoteDataSource({required this.api, required this.dio});

  final lucent.ReportsApi api;
  final Dio dio;

  Future<lucent.ReportWeeklySummaryDataDto> generate() async {
    final response = await api.reportsControllerGenerateWeeklySummaryV1(
      generateReportWeeklySummaryDto: lucent.GenerateReportWeeklySummaryDto(),
    );
    return response.data!.data;
  }
}

import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';

class ReportAiSummaryRemoteDataSource {
  ReportAiSummaryRemoteDataSource({required this.api, required this.dio});

  final lucent.ReportsApi api;
  final Dio dio;

  Future<lucent.ReportSummaryDataDto> generate(ReportAiSummaryRange range) async {
    final dtoRange = switch (range) {
      ReportAiSummaryRange.last7Days =>
        lucent.GenerateReportSummaryDtoRangeEnum.last7Days,
      ReportAiSummaryRange.last30Days =>
        lucent.GenerateReportSummaryDtoRangeEnum.last30Days,
    };

    final response = await api.reportsControllerGenerateSummaryV1(
      generateReportSummaryDto: lucent.GenerateReportSummaryDto(
        range: dtoRange,
      ),
    );
    final data = response.data?.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Lucent report AI summary response is empty.',
      );
    }
    return data;
  }
}

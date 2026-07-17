import 'package:dio/dio.dart';
import 'package:lucent_api/api/export.dart' as lucent;
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/core/network/sse.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';

sealed class ReportAiRemoteEvent {
  const ReportAiRemoteEvent();
}

class ReportAiRemoteSummaryEvent extends ReportAiRemoteEvent {
  const ReportAiRemoteSummaryEvent(this.summary);

  final String summary;
}

class ReportAiRemoteResultEvent extends ReportAiRemoteEvent {
  const ReportAiRemoteResultEvent(this.dto);

  final lucent.ReportSummaryDataDto dto;
}

class ReportAiSummaryRemoteDataSource {
  ReportAiSummaryRemoteDataSource({required this.api, required this.dio});

  final lucent.ReportsApi api;
  final Dio dio;

  Future<lucent.ReportSummaryDataDto> generate(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async {
    final dtoRange = switch (range) {
      ReportAiSummaryRange.last7Days =>
        lucent.GenerateReportSummaryDtoRangeRange.last7Days,
      ReportAiSummaryRange.last30Days =>
        lucent.GenerateReportSummaryDtoRangeRange.last30Days,
      ReportAiSummaryRange.custom =>
        lucent.GenerateReportSummaryDtoRangeRange.custom,
    };

    final response = await api.reportsControllerGenerateSummaryV1(
      body: lucent.GenerateReportSummaryDto(
        range: dtoRange,
        startDate: startDate,
        endDate: endDate,
      ),
    );
    return response.data;
  }

  Stream<ReportAiRemoteEvent> generateStream(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    final dtoRange = switch (range) {
      ReportAiSummaryRange.last7Days => 'last_7_days',
      ReportAiSummaryRange.last30Days => 'last_30_days',
      ReportAiSummaryRange.custom => 'custom',
    };

    final body = <String, Object?>{
      'range': dtoRange,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };

    final sse = LucentSseClient(dio: dio);

    await for (final event in sse.postJson(
      LucentApiPaths.reportSummaryGenerateStream,
      body: body,
    )) {
      switch (event.event) {
        case 'summary':
          final data = event.data;
          if (data is Map<String, Object?>) {
            final summary = data['summary'];
            if (summary is String && summary.trim().isNotEmpty) {
              yield ReportAiRemoteSummaryEvent(summary);
            }
          }
        case 'result':
          final json = requireMap(event.data);
          yield ReportAiRemoteResultEvent(
            lucent.ReportSummaryDataDto.fromJson(json),
          );
        case 'error':
          throw mapSseStreamError(event.data);
        case 'done':
          return;
        default:
          break;
      }
    }
  }
}

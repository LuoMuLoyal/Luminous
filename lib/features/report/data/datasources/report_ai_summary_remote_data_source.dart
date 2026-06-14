import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/network/lucent_sse.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';

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

  Stream<ReportAiRemoteEvent> generateStream(
    ReportAiSummaryRange range,
  ) async* {
    final dtoRange = switch (range) {
      ReportAiSummaryRange.last7Days => 'last_7_days',
      ReportAiSummaryRange.last30Days => 'last_30_days',
    };

    final sse = LucentSseClient(dio: dio);

    await for (final event in sse.postJson(
      '/api/v1/user/reports/summary/generate/stream',
      body: <String, Object?>{
        'range': dtoRange,
      },
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
          final json = _requireMap(event.data);
          yield ReportAiRemoteResultEvent(
            lucent.ReportSummaryDataDto.fromJson(json),
          );
        case 'error':
          throw _mapStreamError(event.data);
        case 'done':
          return;
        default:
          break;
      }
    }
  }

  Map<String, dynamic> _requireMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    throw const LucentApiException(message: 'Lucent SSE payload is invalid.');
  }

  LucentApiException _mapStreamError(Object? data) {
    final json = _requireMap(data);
    return LucentApiException(
      message: json['message']?.toString() ?? 'Request failed.',
      code: json['code'] is int ? json['code'] as int : null,
      statusCode: json['statusCode'] is int ? json['statusCode'] as int : null,
      data: json,
    );
  }
}

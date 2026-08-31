import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/client/sse.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';

sealed class ReviewAiRemoteEvent {
  const ReviewAiRemoteEvent();
}

class ReviewAiRemoteSummaryEvent extends ReviewAiRemoteEvent {
  const ReviewAiRemoteSummaryEvent(this.summary);

  final String summary;
}

class ReviewAiRemoteResultEvent extends ReviewAiRemoteEvent {
  const ReviewAiRemoteResultEvent(this.dto);

  final lucent.ReportSummaryResponseDto dto;
}

class ReviewAiSummaryRemoteDataSource {
  ReviewAiSummaryRemoteDataSource({required this.api, required this.dio});

  final lucent.ReportsApi api;
  final Dio dio;

  Stream<ReviewAiRemoteEvent> generateStream(
    ReviewAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    final dtoRange = switch (range) {
      ReviewAiSummaryRange.last7Days => 'last_7_days',
      ReviewAiSummaryRange.last30Days => 'last_30_days',
      ReviewAiSummaryRange.custom => 'custom',
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
              yield ReviewAiRemoteSummaryEvent(summary);
            }
          }
        case 'result':
          final json = requireMap(event.data);
          yield ReviewAiRemoteResultEvent(
            lucent.ReportSummaryResponseDto.fromJson(json),
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

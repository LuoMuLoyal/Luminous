import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/client/sse.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/features/review/domain/entities/digest.dart';

sealed class ReviewDigestRemoteEvent {
  const ReviewDigestRemoteEvent();
}

class ReviewDigestRemoteSummaryEvent extends ReviewDigestRemoteEvent {
  const ReviewDigestRemoteSummaryEvent(this.summary);

  final String summary;
}

class ReviewDigestRemoteResultEvent extends ReviewDigestRemoteEvent {
  const ReviewDigestRemoteResultEvent(this.dto);

  final lucent.ReportSummaryResponse dto;
}

class ReviewDigestRemoteDataSource {
  ReviewDigestRemoteDataSource({required this.api, required this.dio});

  final lucent.ReportsApi api;
  final Dio dio;

  Stream<ReviewDigestRemoteEvent> generateStream(
    ReviewDigestRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    final dtoRange = switch (range) {
      ReviewDigestRange.last7Days => 'last_7_days',
      ReviewDigestRange.last30Days => 'last_30_days',
      ReviewDigestRange.custom => 'custom',
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
              yield ReviewDigestRemoteSummaryEvent(summary);
            }
          }
        case 'result':
          final json = requireMap(event.data);
          yield ReviewDigestRemoteResultEvent(
            lucent.ReportSummaryResponse.fromJson(json),
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

import 'package:dio/dio.dart';
import 'package:lucent_api/api/export.dart' as lucent;
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/sse.dart';

sealed class TodayAiRemoteEvent {
  const TodayAiRemoteEvent();
}

class TodayAiRemoteSummaryEvent extends TodayAiRemoteEvent {
  const TodayAiRemoteSummaryEvent(this.summary);

  final String summary;
}

class TodayAiRemoteResultEvent extends TodayAiRemoteEvent {
  const TodayAiRemoteResultEvent(this.dto);

  final lucent.TodayAnalysisDataDto dto;
}

class TodayAiRemoteDataSource {
  TodayAiRemoteDataSource({required this.api, required this.dio});

  final lucent.TodayAnalysisApi api;
  final Dio dio;

  Future<lucent.TodayAnalysisDataDto> generate({String? date}) async {
    final response = await api.todayAnalysisControllerGenerateV1(
      body: lucent.GenerateTodayAnalysisDto(date: date),
    );
    return response.data;
  }

  Stream<TodayAiRemoteEvent> generateStream({String? date}) async* {
    final sse = LucentSseClient(dio: dio);

    await for (final event in sse.postJson(
      '/api/v1/user/today-analysis/generate/stream',
      body: <String, Object?>{if (date != null) 'date': date},
    )) {
      switch (event.event) {
        case 'summary':
          final data = event.data;
          if (data is Map<String, Object?>) {
            final summary = data['summary'];
            if (summary is String && summary.trim().isNotEmpty) {
              yield TodayAiRemoteSummaryEvent(summary);
            }
          }
        case 'result':
          final json = _requireMap(event.data);
          yield TodayAiRemoteResultEvent(
            lucent.TodayAnalysisDataDto.fromJson(json),
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
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const LucentApiException(message: 'Lucent SSE payload is invalid.');
  }

  LucentApiException _mapStreamError(Object? data) {
    final json = _requireMap(data);
    return LucentApiException(
      message: json['message']?.toString() ?? '请求失败，请稍后再试。',
      code: json['code'] is int ? json['code'] as int : null,
      statusCode: json['statusCode'] is int ? json['statusCode'] as int : null,
      data: json,
    );
  }
}

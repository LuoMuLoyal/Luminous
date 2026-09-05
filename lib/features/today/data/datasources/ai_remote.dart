import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/client/sse.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/map_utils.dart';

sealed class TodayAiRemoteEvent {
  const TodayAiRemoteEvent();
}

class TodayAiRemoteSummaryEvent extends TodayAiRemoteEvent {
  const TodayAiRemoteSummaryEvent(this.summary);

  final String summary;
}

class TodayAiRemoteResultEvent extends TodayAiRemoteEvent {
  const TodayAiRemoteResultEvent(this.dto);

  final lucent.TodayAnalysisReadDataAnalysis dto;
}

class TodayAiRemoteDataSource {
  TodayAiRemoteDataSource({required this.api, required this.dio});

  final lucent.TodayAnalysisApi api;
  final Dio dio;

  Future<lucent.TodayAnalysisReadData> read({String? date}) async {
    final response = await api.read(date: date);
    final data = response.data;
    if (data == null) {
      throw LucentFailure.network(
        message: 'Today analysis read response was empty.',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return lucent.TodayAnalysisReadData.fromJson(data.toJson());
  }

  /// Requests a bounded refresh and normalizes the oneOf response to a read
  /// DTO. The generated client merges the union variants incorrectly (all
  /// fields become required), so this method uses a raw [Dio] call and parses
  /// the direct resource by inspecting `status`/`analysis`.
  Future<lucent.TodayAnalysisReadData> refresh({String? date}) async {
    final response = await dio.post<Object>(
      LucentApiPaths.todayAnalysisRefresh,
      data: <String, Object?>{if (date != null) 'date': date},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw LucentFailure.network(
        message: 'Today analysis refresh response was empty or malformed.',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }

    return _normalizeRefreshData(data);
  }

  lucent.TodayAnalysisReadData _normalizeRefreshData(
    Map<String, dynamic> data,
  ) {
    final status = data['status'] as String?;
    final analysisJson = data['analysis'];
    final jobId = data['jobId'] as String?;

    if (status == 'pending' && jobId != null) {
      return lucent.TodayAnalysisReadData(
        status: lucent.TodayAnalysisReadDataStatusEnum.pending,
        analysis: null,
        sourceVersion: 0,
        computedVersion: 0,
        computedAt: null,
        retryAfterSeconds: data['retryAfterSeconds'] as num?,
      );
    }

    if (status == 'ready' || status == null) {
      final analysisMap = status == null ? data : analysisJson;
      final analysis = analysisMap is Map<String, dynamic>
          ? lucent.TodayAnalysisReadDataAnalysis.fromJson(analysisMap)
          : null;
      return lucent.TodayAnalysisReadData(
        status: lucent.TodayAnalysisReadDataStatusEnum.ready,
        analysis: analysis,
        sourceVersion: data['sourceVersion'] as num? ?? 0,
        computedVersion: data['computedVersion'] as num? ?? 0,
        computedAt: data['computedAt'] as String?,
        retryAfterSeconds: data['retryAfterSeconds'] as num?,
      );
    }

    final readStatus = _mapReadStatus(status);
    final analysis = analysisJson is Map<String, dynamic>
        ? lucent.TodayAnalysisReadDataAnalysis.fromJson(analysisJson)
        : null;
    return lucent.TodayAnalysisReadData(
      status: readStatus,
      analysis: analysis,
      sourceVersion: data['sourceVersion'] as num? ?? 0,
      computedVersion: data['computedVersion'] as num? ?? 0,
      computedAt: data['computedAt'] as String?,
      retryAfterSeconds: data['retryAfterSeconds'] as num?,
    );
  }

  lucent.TodayAnalysisReadDataStatusEnum _mapReadStatus(String status) {
    return switch (status) {
      'empty' => lucent.TodayAnalysisReadDataStatusEnum.empty,
      'pending' => lucent.TodayAnalysisReadDataStatusEnum.pending,
      'ready' => lucent.TodayAnalysisReadDataStatusEnum.ready,
      'stale' => lucent.TodayAnalysisReadDataStatusEnum.stale,
      'failed' => lucent.TodayAnalysisReadDataStatusEnum.failed,
      _ => lucent.TodayAnalysisReadDataStatusEnum.unknownDefaultOpenApi,
    };
  }

  Stream<TodayAiRemoteEvent> generateStream({String? date}) async* {
    final sse = LucentSseClient(dio: dio);

    await for (final event in sse.postJson(
      LucentApiPaths.todayAnalysisGenerateStream,
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
          final json = requireMap(event.data);
          yield TodayAiRemoteResultEvent(
            lucent.TodayAnalysisReadDataAnalysis.fromJson(json),
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

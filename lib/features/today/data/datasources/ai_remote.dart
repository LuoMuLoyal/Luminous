import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/map_utils.dart';
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
      generateTodayAnalysisDto: lucent.GenerateTodayAnalysisDto(date: date),
    );
    final envelope = response.data;
    if (envelope == null) {
      throw StateError('Today analysis generate response was empty.');
    }

    final data = envelope.data;
    final analysis = data.analysis;
    if (analysis != null) {
      return analysis;
    }

    return lucent.TodayAnalysisDataDto(
      date: data.date,
      generatedAt: data.generatedAt,
      sourceVersion: data.sourceVersion,
      summary: data.summary,
      bullets: data.bullets,
      actionLabel: data.actionLabel,
      action: data.action,
      confidenceNote: data.confidenceNote,
    );
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
            lucent.TodayAnalysisDataDto.fromJson(json),
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

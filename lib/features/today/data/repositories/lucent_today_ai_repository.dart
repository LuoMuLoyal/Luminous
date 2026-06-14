import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/today/data/datasources/today_ai_remote_data_source.dart';
import 'package:luminous/features/today/domain/entities/today_ai_analysis.dart';

sealed class TodayAiGenerationEvent {
  const TodayAiGenerationEvent();
}

class TodayAiGenerationSummaryEvent extends TodayAiGenerationEvent {
  const TodayAiGenerationSummaryEvent(this.summary);

  final String summary;
}

class TodayAiGenerationResultEvent extends TodayAiGenerationEvent {
  const TodayAiGenerationResultEvent(this.analysis);

  final TodayAiAnalysis analysis;
}

abstract interface class TodayAiRepository {
  Future<TodayAiAnalysis> generate({String? date});
  Stream<TodayAiGenerationEvent> generateStream({String? date});
}

final todayAiRemoteDataSourceProvider = Provider<TodayAiRemoteDataSource>((
  ref,
) {
  final api = ref.watch(lucentTodayAnalysisApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return TodayAiRemoteDataSource(api: api, dio: dio);
});

final todayAiRepositoryProvider = Provider<TodayAiRepository>((ref) {
  final dataSource = ref.watch(todayAiRemoteDataSourceProvider);
  return LucentTodayAiRepository(dataSource: dataSource);
});

class LucentTodayAiRepository implements TodayAiRepository {
  LucentTodayAiRepository({required this.dataSource});

  final TodayAiRemoteDataSource dataSource;

  @override
  Future<TodayAiAnalysis> generate({String? date}) async {
    await for (final event in generateStream(date: date)) {
      if (event is TodayAiGenerationResultEvent) {
        return event.analysis;
      }
    }
    throw StateError('Today AI stream ended without a final result.');
  }

  @override
  Stream<TodayAiGenerationEvent> generateStream({String? date}) async* {
    await for (final event in dataSource.generateStream(date: date)) {
      switch (event) {
        case TodayAiRemoteSummaryEvent():
          yield TodayAiGenerationSummaryEvent(event.summary);
        case TodayAiRemoteResultEvent():
          yield TodayAiGenerationResultEvent(_mapAnalysis(event.dto));
      }
    }
  }

  TodayAiAnalysis _mapAnalysis(lucent.TodayAnalysisDataDto dto) {
    return TodayAiAnalysis(
      date: dto.date,
      generatedAt: DateTime.parse(dto.generatedAt),
      summary: dto.summary,
      bullets: dto.bullets.map(_mapBullet).toList(growable: false),
      actionLabel: dto.actionLabel,
      confidenceNote: dto.confidenceNote,
    );
  }

  TodayAiAnalysisBullet _mapBullet(lucent.TodayAnalysisBulletDto dto) {
    return TodayAiAnalysisBullet(
      kind: switch (dto.kind.value) {
        'medication' => TodayAiAnalysisBulletKind.medication,
        'hydration' => TodayAiAnalysisBulletKind.hydration,
        'sleep' => TodayAiAnalysisBulletKind.sleep,
        _ => TodayAiAnalysisBulletKind.general,
      },
      text: dto.text,
    );
  }
}

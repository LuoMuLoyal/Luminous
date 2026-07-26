import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/today/data/datasources/ai_remote.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/repositories/ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent_ai.g.dart';

@riverpod
TodayAiRemoteDataSource todayAiRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).todayAnalysis;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return TodayAiRemoteDataSource(api: api, dio: dio);
}

@riverpod
TodayAiRepository todayAiRepository(Ref ref) {
  final dataSource = ref.watch(todayAiRemoteDataSourceProvider);
  return LucentTodayAiRepository(dataSource: dataSource);
}

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
    throw StateError('今日 AI 流式响应已结束，但没有返回最终结果。');
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

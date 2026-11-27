import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:luminous/core/network/wire_time.dart';
import 'package:luminous/features/today/data/datasources/briefing_remote.dart';
import 'package:luminous/features/today/domain/entities/briefing.dart';
import 'package:luminous/features/today/domain/repositories/briefing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent_briefing.g.dart';

@riverpod
TodayBriefingRemoteDataSource todayBriefingRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).todayAnalysis;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return TodayBriefingRemoteDataSource(api: api, dio: dio);
}

@riverpod
TodayBriefingRepository todayBriefingRepository(Ref ref) {
  final dataSource = ref.watch(todayBriefingRemoteDataSourceProvider);
  return LucentTodayBriefingRepository(dataSource: dataSource);
}

class LucentTodayBriefingRepository implements TodayBriefingRepository {
  LucentTodayBriefingRepository({required this.dataSource});

  final TodayBriefingRemoteDataSource dataSource;

  @override
  TaskEither<LucentFailure, TodayBriefing> read(DateTime date) {
    return TaskEither.tryCatch(() async {
      final dto = await dataSource.read(date: _formatDate(date));
      return _mapReadDataDto(dto);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, TodayBriefing> refresh(DateTime date) {
    return TaskEither.tryCatch(() async {
      final dto = await dataSource.refresh(date: _formatDate(date));
      return _mapReadDataDto(dto);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// 兼容保留：当前无生产消费者，仅保留 API 兼容；流结束无结果按本地
  /// 不变量映射 Left(unknown)。
  @override
  TaskEither<LucentFailure, TodayBriefing> generate({String? date}) {
    return TaskEither.tryCatch(() async {
      await for (final event in generateStream(date: date)) {
        if (event is TodayBriefingResultEvent) {
          return event.analysis;
        }
      }
      // 流结束但无最终结果：服务端未返回有效数据，视为可恢复失败。
      throw const LucentFailure(
        kind: LucentFailureKind.business,
        code: 'AI_EMPTY_RESULT',
        message: 'Today AI stream ended without a final result.',
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  Stream<TodayBriefingEvent> generateStream({String? date}) async* {
    await for (final event in dataSource.generateStream(date: date)) {
      switch (event) {
        case TodayBriefingRemoteSummaryEvent():
          yield TodayBriefingSummaryEvent(event.summary);
        case TodayBriefingRemoteResultEvent():
          yield TodayBriefingResultEvent(_mapAnalysis(event.dto));
      }
    }
  }

  TodayBriefing _mapReadDataDto(lucent.AnalysisReadResponse dto) {
    final analysis = dto.analysis;
    final status = _mapMaterializationStatus(dto.status);
    final sourceVersion = dto.sourceVersion.toInt();
    final computedVersion = dto.computedVersion.toInt();
    if (analysis == null) {
      return TodayBriefing(
        date: _formatDate(DateTime.now()),
        generatedAt: parseDateTimeOrEpoch(dto.computedAt),
        summary: '',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: status,
        briefingGenerated: false,
        sourceVersion: sourceVersion,
        computedVersion: computedVersion,
      );
    }
    return _mapAnalysis(
      analysis,
      materializationStatus: status,
      computedAt: parseDateTimeOrNull(dto.computedAt),
      sourceVersion: sourceVersion,
      computedVersion: computedVersion,
    );
  }

  TodayBriefing _mapAnalysis(
    lucent.AnalysisReadResponseAnalysis dto, {
    TodayBriefingMaterializationStatus materializationStatus =
        TodayBriefingMaterializationStatus.ready,
    DateTime? computedAt,
    int sourceVersion = 0,
    int computedVersion = 0,
  }) {
    return TodayBriefing(
      date: dto.date,
      generatedAt: computedAt ?? parseDateTimeOrEpoch(dto.generatedAt),
      summary: dto.summary,
      bullets: dto.bullets.map(_mapBullet).toList(growable: false),
      actionLabel: dto.actionLabel,
      confidenceNote: dto.confidenceNote,
      materializationStatus: materializationStatus,
      briefingGenerated: dto.briefingGenerated,
      sourceVersion: sourceVersion,
      computedVersion: computedVersion,
    );
  }

  TodayBriefingBullet _mapBullet(
    lucent.AnalysisReadResponseAnalysisBullets dto,
  ) {
    return TodayBriefingBullet(
      kind: switch (dto.kind.value) {
        'medication' => TodayBriefingBulletKind.medication,
        'hydration' => TodayBriefingBulletKind.hydration,
        'sleep' => TodayBriefingBulletKind.sleep,
        _ => TodayBriefingBulletKind.general,
      },
      text: dto.text,
    );
  }

  TodayBriefingMaterializationStatus _mapMaterializationStatus(
    lucent.AnalysisReadResponseStatusEnum status,
  ) {
    return switch (status) {
      lucent.AnalysisReadResponseStatusEnum.empty =>
        TodayBriefingMaterializationStatus.empty,
      lucent.AnalysisReadResponseStatusEnum.pending =>
        TodayBriefingMaterializationStatus.pending,
      lucent.AnalysisReadResponseStatusEnum.ready =>
        TodayBriefingMaterializationStatus.ready,
      lucent.AnalysisReadResponseStatusEnum.stale =>
        TodayBriefingMaterializationStatus.stale,
      lucent.AnalysisReadResponseStatusEnum.failed =>
        TodayBriefingMaterializationStatus.failed,
      lucent.AnalysisReadResponseStatusEnum.unknownDefaultOpenApi =>
        TodayBriefingMaterializationStatus.empty,
    };
  }

  /// The AI-analysis endpoints key on a local `yyyy-MM-dd` day.
  String _formatDate(DateTime date) => formatWireDateKey(date);
}

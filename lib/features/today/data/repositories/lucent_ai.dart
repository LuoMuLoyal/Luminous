import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/core/utils/date_format.dart';
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
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  TaskEither<LucentFailure, TodayAiAnalysis> read(DateTime date) {
    return TaskEither.tryCatch(() async {
      final dto = await dataSource.read(date: _formatDate(date));
      return _mapReadDataDto(dto);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, TodayAiAnalysis> refresh(DateTime date) {
    return TaskEither.tryCatch(() async {
      final dto = await dataSource.refresh(date: _formatDate(date));
      return _mapReadDataDto(dto);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// 兼容保留：当前无生产消费者，仅保留 API 兼容；流结束无结果按本地
  /// 不变量映射 Left(unknown)。
  @override
  TaskEither<LucentFailure, TodayAiAnalysis> generate({String? date}) {
    return TaskEither.tryCatch(() async {
      await for (final event in generateStream(date: date)) {
        if (event is TodayAiGenerationResultEvent) {
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

  TodayAiAnalysis _mapReadDataDto(lucent.TodayAnalysisReadDataDto dto) {
    final analysis = dto.analysis;
    final status = _mapMaterializationStatus(dto.status);
    final sourceVersion = dto.sourceVersion.toInt();
    final computedVersion = dto.computedVersion.toInt();
    if (analysis == null) {
      return TodayAiAnalysis(
        date: _formatDate(DateTime.now()),
        generatedAt: parseDateTimeOrEpoch(dto.computedAt),
        summary: '',
        bullets: const [],
        actionLabel: '',
        confidenceNote: '',
        materializationStatus: status,
        aiGenerated: false,
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

  TodayAiAnalysis _mapAnalysis(
    lucent.TodayAnalysisDataDto dto, {
    TodayAiAnalysisMaterializationStatus materializationStatus =
        TodayAiAnalysisMaterializationStatus.ready,
    DateTime? computedAt,
    int sourceVersion = 0,
    int computedVersion = 0,
  }) {
    return TodayAiAnalysis(
      date: dto.date,
      generatedAt: computedAt ?? parseDateTimeOrEpoch(dto.generatedAt),
      summary: dto.summary,
      bullets: dto.bullets.map(_mapBullet).toList(growable: false),
      actionLabel: dto.actionLabel,
      confidenceNote: dto.confidenceNote,
      materializationStatus: materializationStatus,
      aiGenerated: dto.aiGenerated,
      sourceVersion: sourceVersion,
      computedVersion: computedVersion,
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

  TodayAiAnalysisMaterializationStatus _mapMaterializationStatus(
    lucent.TodayAnalysisReadDataDtoStatusEnum status,
  ) {
    return switch (status) {
      lucent.TodayAnalysisReadDataDtoStatusEnum.empty =>
        TodayAiAnalysisMaterializationStatus.empty,
      lucent.TodayAnalysisReadDataDtoStatusEnum.pending =>
        TodayAiAnalysisMaterializationStatus.pending,
      lucent.TodayAnalysisReadDataDtoStatusEnum.ready =>
        TodayAiAnalysisMaterializationStatus.ready,
      lucent.TodayAnalysisReadDataDtoStatusEnum.stale =>
        TodayAiAnalysisMaterializationStatus.stale,
      lucent.TodayAnalysisReadDataDtoStatusEnum.failed =>
        TodayAiAnalysisMaterializationStatus.failed,
      lucent.TodayAnalysisReadDataDtoStatusEnum.unknownDefaultOpenApi =>
        TodayAiAnalysisMaterializationStatus.empty,
    };
  }

  String _formatDate(DateTime date) => _dateFormat.format(date.toLocal());
}

import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/features/report/data/datasources/ai_summary_remote.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';
import 'package:luminous/features/report/domain/repositories/ai_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent_ai_summary.g.dart';

@riverpod
ReportAiSummaryRemoteDataSource reportAiSummaryRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).reports;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return ReportAiSummaryRemoteDataSource(api: api, dio: dio);
}

@riverpod
ReportAiSummaryRepository reportAiSummaryRepository(Ref ref) {
  final dataSource = ref.watch(reportAiSummaryRemoteDataSourceProvider);
  return LucentReportAiSummaryRepository(dataSource: dataSource);
}

class LucentReportAiSummaryRepository implements ReportAiSummaryRepository {
  LucentReportAiSummaryRepository({required this.dataSource});

  final ReportAiSummaryRemoteDataSource dataSource;

  @override
  Stream<ReportAiGenerationEvent> generateStream(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    await for (final event in dataSource.generateStream(
      range,
      startDate: startDate,
      endDate: endDate,
    )) {
      switch (event) {
        case ReportAiRemoteSummaryEvent():
          yield ReportAiGenerationSummaryEvent(event.summary);
        case ReportAiRemoteResultEvent():
          yield ReportAiGenerationResultEvent(_mapSummary(event.dto));
      }
    }
  }

  ReportAiSummary _mapSummary(lucent.ReportSummaryDataDto dto) {
    return ReportAiSummary(
      range: _mapRange(dto.range),
      startDate: dto.startDate,
      endDate: dto.endDate,
      generatedAt: parseDateTimeOrEpoch(dto.generatedAt),
      summary: dto.summary,
      coverage: _mapCoverage(dto.coverage),
      observedPattern: _mapObservedPattern(dto.observedPattern),
      lowRiskAction: _mapLowRiskAction(dto.lowRiskAction),
      disclaimer: dto.disclaimer,
    );
  }

  ReportAiSummaryCoverage _mapCoverage(lucent.ReportCoverageDto dto) {
    return ReportAiSummaryCoverage(
      medication: _mapCoverageDimension(dto.medication),
      water: _mapCoverageDimension(dto.water),
      sleep: _mapCoverageDimension(dto.sleep),
    );
  }

  ReportAiSummaryCoverageDimension _mapCoverageDimension(
    lucent.ReportCoverageDimensionDto dto,
  ) {
    return ReportAiSummaryCoverageDimension(
      trackedDays: dto.trackedDays.toInt(),
      totalDays: dto.totalDays.toInt(),
    );
  }

  ReportAiSummaryObservedPattern? _mapObservedPattern(
    lucent.ReportObservedPatternDto? dto,
  ) {
    if (dto == null) return null;
    return ReportAiSummaryObservedPattern(
      kind: _mapPatternKind(dto.kind),
      text: dto.text,
      source: dto.source_,
    );
  }

  ReportAiSummaryPatternKind _mapPatternKind(
    lucent.ReportObservedPatternDtoKindEnum kind,
  ) {
    switch (kind) {
      case lucent.ReportObservedPatternDtoKindEnum.medication:
        return ReportAiSummaryPatternKind.medication;
      case lucent.ReportObservedPatternDtoKindEnum.hydration:
        return ReportAiSummaryPatternKind.hydration;
      case lucent.ReportObservedPatternDtoKindEnum.sleep:
        return ReportAiSummaryPatternKind.sleep;
      // The OpenAPI generator emits this sentinel for any value the server
      // returns that the generated client does not know about. Log a
      // warning and fall back to `medication` rather than throwing,
      // so a single unknown pattern kind does not break the entire summary.
      case lucent.ReportObservedPatternDtoKindEnum.unknownDefaultOpenApi:
        appTalker.warning('Unknown pattern kind from API: $kind');
        return ReportAiSummaryPatternKind.medication;
    }
  }

  ReportAiSummaryLowRiskAction? _mapLowRiskAction(
    lucent.ReportLowRiskActionDto? dto,
  ) {
    if (dto == null) return null;
    return ReportAiSummaryLowRiskAction(label: dto.label, text: dto.text);
  }

  ReportAiSummaryRange _mapRange(lucent.ReportSummaryDataDtoRangeEnum range) {
    switch (range) {
      case lucent.ReportSummaryDataDtoRangeEnum.last7Days:
        return ReportAiSummaryRange.last7Days;
      case lucent.ReportSummaryDataDtoRangeEnum.last30Days:
        return ReportAiSummaryRange.last30Days;
      case lucent.ReportSummaryDataDtoRangeEnum.custom:
        return ReportAiSummaryRange.custom;
      // The OpenAPI generator emits this sentinel for any value the server
      // returns that the generated client does not know about. Log a
      // warning and fall back to `last7Days` rather than throwing.
      case lucent.ReportSummaryDataDtoRangeEnum.unknownDefaultOpenApi:
        appTalker.warning('Unknown summary range from API: $range');
        return ReportAiSummaryRange.last7Days;
    }
  }
}

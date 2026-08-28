import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/features/review/data/datasources/ai_summary_remote.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/repositories/ai_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent_ai_summary.g.dart';

@riverpod
ReviewAiSummaryRemoteDataSource reviewAiSummaryRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).reports;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return ReviewAiSummaryRemoteDataSource(api: api, dio: dio);
}

@riverpod
ReviewAiSummaryRepository reviewAiSummaryRepository(Ref ref) {
  final dataSource = ref.watch(reviewAiSummaryRemoteDataSourceProvider);
  return LucentReviewAiSummaryRepository(dataSource: dataSource);
}

class LucentReviewAiSummaryRepository implements ReviewAiSummaryRepository {
  LucentReviewAiSummaryRepository({required this.dataSource});

  final ReviewAiSummaryRemoteDataSource dataSource;

  @override
  Stream<ReviewAiGenerationEvent> generateStream(
    ReviewAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    await for (final event in dataSource.generateStream(
      range,
      startDate: startDate,
      endDate: endDate,
    )) {
      switch (event) {
        case ReviewAiRemoteSummaryEvent():
          yield ReviewAiGenerationSummaryEvent(event.summary);
        case ReviewAiRemoteResultEvent():
          yield ReviewAiGenerationResultEvent(_mapSummary(event.dto));
      }
    }
  }

  ReviewAiSummary _mapSummary(lucent.ReportSummaryResponseDto dto) {
    return ReviewAiSummary(
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

  ReviewAiSummaryCoverage _mapCoverage(lucent.ReportCoverageDto dto) {
    return ReviewAiSummaryCoverage(
      medication: _mapCoverageDimension(dto.medication),
      water: _mapCoverageDimension(dto.water),
      sleep: _mapCoverageDimension(dto.sleep),
    );
  }

  ReviewAiSummaryCoverageDimension _mapCoverageDimension(
    lucent.ReportCoverageDimensionDto dto,
  ) {
    return ReviewAiSummaryCoverageDimension(
      trackedDays: dto.trackedDays.toInt(),
      totalDays: dto.totalDays.toInt(),
    );
  }

  ReviewAiSummaryObservedPattern? _mapObservedPattern(
    lucent.ReportObservedPatternDto? dto,
  ) {
    if (dto == null) return null;
    return ReviewAiSummaryObservedPattern(
      kind: _mapPatternKind(dto.kind),
      text: dto.text,
      source: dto.source_,
    );
  }

  ReviewAiSummaryPatternKind _mapPatternKind(
    lucent.ReportObservedPatternDtoKindEnum kind,
  ) {
    switch (kind) {
      case lucent.ReportObservedPatternDtoKindEnum.medication:
        return ReviewAiSummaryPatternKind.medication;
      case lucent.ReportObservedPatternDtoKindEnum.hydration:
        return ReviewAiSummaryPatternKind.hydration;
      case lucent.ReportObservedPatternDtoKindEnum.sleep:
        return ReviewAiSummaryPatternKind.sleep;
      // The OpenAPI generator emits this sentinel for any value the server
      // returns that the generated client does not know about. Log a
      // warning and fall back to `medication` rather than throwing,
      // so a single unknown pattern kind does not break the entire summary.
      case lucent.ReportObservedPatternDtoKindEnum.unknownDefaultOpenApi:
        appTalker.warning('Unknown pattern kind from API: $kind');
        return ReviewAiSummaryPatternKind.medication;
    }
  }

  ReviewAiSummaryLowRiskAction? _mapLowRiskAction(
    lucent.ReportLowRiskActionDto? dto,
  ) {
    if (dto == null) return null;
    return ReviewAiSummaryLowRiskAction(label: dto.label, text: dto.text);
  }

  ReviewAiSummaryRange _mapRange(
    lucent.ReportSummaryResponseDtoRangeEnum range,
  ) {
    switch (range) {
      case lucent.ReportSummaryResponseDtoRangeEnum.last7Days:
        return ReviewAiSummaryRange.last7Days;
      case lucent.ReportSummaryResponseDtoRangeEnum.last30Days:
        return ReviewAiSummaryRange.last30Days;
      case lucent.ReportSummaryResponseDtoRangeEnum.custom:
        return ReviewAiSummaryRange.custom;
      // The OpenAPI generator emits this sentinel for any value the server
      // returns that the generated client does not know about. Log a
      // warning and fall back to `last7Days` rather than throwing.
      case lucent.ReportSummaryResponseDtoRangeEnum.unknownDefaultOpenApi:
        appTalker.warning('Unknown summary range from API: $range');
        return ReviewAiSummaryRange.last7Days;
    }
  }
}

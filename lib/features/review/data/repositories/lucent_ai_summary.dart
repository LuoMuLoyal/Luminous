import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/utils/date_format.dart';
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

  ReviewAiSummary _mapSummary(lucent.ReportSummaryResponse dto) {
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

  ReviewAiSummaryCoverage _mapCoverage(
    lucent.ReportSummaryResponseCoverage dto,
  ) {
    return ReviewAiSummaryCoverage(
      medication: _mapCoverageDimension(dto.medication),
      // 新客户端为 water/sleep 生成独立类型（JSON 形状一致），经 JSON
      // 往返复用 _mapCoverageDimension。
      water: _mapCoverageDimension(
        lucent.ReportSummaryResponseCoverageMedication.fromJson(
          dto.water.toJson(),
        ),
      ),
      sleep: _mapCoverageDimension(
        lucent.ReportSummaryResponseCoverageMedication.fromJson(
          dto.sleep.toJson(),
        ),
      ),
    );
  }

  ReviewAiSummaryCoverageDimension _mapCoverageDimension(
    lucent.ReportSummaryResponseCoverageMedication dto,
  ) {
    return ReviewAiSummaryCoverageDimension(
      trackedDays: dto.trackedDays.toInt(),
      totalDays: dto.totalDays.toInt(),
    );
  }

  ReviewAiSummaryObservedPattern? _mapObservedPattern(
    lucent.ReportSummaryResponseObservedPattern? dto,
  ) {
    if (dto == null) return null;
    return ReviewAiSummaryObservedPattern(
      kind: _mapPatternKind(dto.kind),
      text: dto.text,
      source: dto.source_,
    );
  }

  ReviewAiSummaryPatternKind _mapPatternKind(
    lucent.ReportSummaryResponseObservedPatternKindEnum kind,
  ) {
    switch (kind) {
      case lucent.ReportSummaryResponseObservedPatternKindEnum.medication:
        return ReviewAiSummaryPatternKind.medication;
      case lucent.ReportSummaryResponseObservedPatternKindEnum.hydration:
        return ReviewAiSummaryPatternKind.hydration;
      case lucent.ReportSummaryResponseObservedPatternKindEnum.sleep:
        return ReviewAiSummaryPatternKind.sleep;
      // The OpenAPI generator emits this sentinel for any value the server
      // returns that the generated client does not know about. Log a
      // warning and fall back to `medication` rather than throwing,
      // so a single unknown pattern kind does not break the entire summary.
      case lucent
          .ReportSummaryResponseObservedPatternKindEnum
          .unknownDefaultOpenApi:
        appTalker.warning('Unknown pattern kind from API: $kind');
        return ReviewAiSummaryPatternKind.medication;
    }
  }

  ReviewAiSummaryLowRiskAction? _mapLowRiskAction(
    lucent.ReportSummaryResponseLowRiskAction? dto,
  ) {
    if (dto == null) return null;
    return ReviewAiSummaryLowRiskAction(label: dto.label, text: dto.text);
  }

  ReviewAiSummaryRange _mapRange(lucent.ReportSummaryResponseRangeEnum range) {
    switch (range) {
      case lucent.ReportSummaryResponseRangeEnum.last7Days:
        return ReviewAiSummaryRange.last7Days;
      case lucent.ReportSummaryResponseRangeEnum.last30Days:
        return ReviewAiSummaryRange.last30Days;
      case lucent.ReportSummaryResponseRangeEnum.custom:
        return ReviewAiSummaryRange.custom;
      // The OpenAPI generator emits this sentinel for any value the server
      // returns that the generated client does not know about. Log a
      // warning and fall back to `last7Days` rather than throwing.
      case lucent.ReportSummaryResponseRangeEnum.unknownDefaultOpenApi:
        appTalker.warning('Unknown summary range from API: $range');
        return ReviewAiSummaryRange.last7Days;
    }
  }
}

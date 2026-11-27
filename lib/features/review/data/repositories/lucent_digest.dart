import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/wire_time.dart';
import 'package:luminous/features/review/data/datasources/digest_remote.dart';
import 'package:luminous/features/review/domain/entities/digest.dart';
import 'package:luminous/features/review/domain/repositories/digest.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent_digest.g.dart';

@riverpod
ReviewDigestRemoteDataSource reviewDigestRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).reports;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return ReviewDigestRemoteDataSource(api: api, dio: dio);
}

@riverpod
ReviewDigestRepository reviewDigestRepository(Ref ref) {
  final dataSource = ref.watch(reviewDigestRemoteDataSourceProvider);
  return LucentReviewDigestRepository(dataSource: dataSource);
}

class LucentReviewDigestRepository implements ReviewDigestRepository {
  LucentReviewDigestRepository({required this.dataSource});

  final ReviewDigestRemoteDataSource dataSource;

  @override
  Stream<ReviewDigestEvent> generateStream(
    ReviewDigestRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    await for (final event in dataSource.generateStream(
      range,
      startDate: startDate,
      endDate: endDate,
    )) {
      switch (event) {
        case ReviewDigestRemoteSummaryEvent():
          yield ReviewDigestSummaryEvent(event.summary);
        case ReviewDigestRemoteResultEvent():
          yield ReviewDigestResultEvent(_mapSummary(event.dto));
      }
    }
  }

  ReviewDigest _mapSummary(lucent.ReportSummaryResponse dto) {
    return ReviewDigest(
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

  ReviewDigestCoverage _mapCoverage(lucent.ReportSummaryResponseCoverage dto) {
    return ReviewDigestCoverage(
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

  ReviewDigestCoverageDimension _mapCoverageDimension(
    lucent.ReportSummaryResponseCoverageMedication dto,
  ) {
    return ReviewDigestCoverageDimension(
      trackedDays: dto.trackedDays.toInt(),
      totalDays: dto.totalDays.toInt(),
    );
  }

  ReviewDigestObservedPattern? _mapObservedPattern(
    lucent.ReportSummaryResponseObservedPattern? dto,
  ) {
    if (dto == null) return null;
    return ReviewDigestObservedPattern(
      kind: _mapPatternKind(dto.kind),
      text: dto.text,
      source: dto.source_,
    );
  }

  ReviewDigestPatternKind _mapPatternKind(
    lucent.ReportSummaryResponseObservedPatternKindEnum kind,
  ) {
    switch (kind) {
      case lucent.ReportSummaryResponseObservedPatternKindEnum.medication:
        return ReviewDigestPatternKind.medication;
      case lucent.ReportSummaryResponseObservedPatternKindEnum.hydration:
        return ReviewDigestPatternKind.hydration;
      case lucent.ReportSummaryResponseObservedPatternKindEnum.sleep:
        return ReviewDigestPatternKind.sleep;
      // The OpenAPI generator emits this sentinel for any value the server
      // returns that the generated client does not know about. Log a
      // warning and fall back to `medication` rather than throwing,
      // so a single unknown pattern kind does not break the entire summary.
      case lucent
          .ReportSummaryResponseObservedPatternKindEnum
          .unknownDefaultOpenApi:
        appLog.warning('Unknown pattern kind from API: $kind');
        return ReviewDigestPatternKind.medication;
    }
  }

  ReviewDigestLowRiskAction? _mapLowRiskAction(
    lucent.ReportSummaryResponseLowRiskAction? dto,
  ) {
    if (dto == null) return null;
    return ReviewDigestLowRiskAction(label: dto.label, text: dto.text);
  }

  ReviewDigestRange _mapRange(lucent.ReportSummaryResponseRangeEnum range) {
    switch (range) {
      case lucent.ReportSummaryResponseRangeEnum.last7Days:
        return ReviewDigestRange.last7Days;
      case lucent.ReportSummaryResponseRangeEnum.last30Days:
        return ReviewDigestRange.last30Days;
      case lucent.ReportSummaryResponseRangeEnum.custom:
        return ReviewDigestRange.custom;
      // The OpenAPI generator emits this sentinel for any value the server
      // returns that the generated client does not know about. Log a
      // warning and fall back to `last7Days` rather than throwing.
      case lucent.ReportSummaryResponseRangeEnum.unknownDefaultOpenApi:
        appLog.warning('Unknown summary range from API: $range');
        return ReviewDigestRange.last7Days;
    }
  }
}

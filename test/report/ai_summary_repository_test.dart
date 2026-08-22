import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/features/report/data/datasources/ai_summary_remote.dart';
import 'package:luminous/features/report/data/repositories/lucent_ai_summary.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';
import 'package:luminous/features/report/domain/repositories/ai_summary.dart';

void main() {
  test('Lucent report ai summary repository maps summary dto', () async {
    final repository = LucentReportAiSummaryRepository(
      dataSource: _FakeReportAiSummaryRemoteDataSource(
        lucent.ReportSummaryResponseDto(
          range: lucent.ReportSummaryResponseDtoRangeEnum.last30Days,
          startDate: '2026-06-06',
          endDate: '2026-06-12',
          generatedAt: '2026-06-12T10:00:00.000Z',
          summary: '本周用药记录整体稳定，饮水仍有少数低点。',
          coverage: lucent.ReportCoverageDto(
            medication: lucent.ReportCoverageDimensionDto(
              trackedDays: 5,
              totalDays: 7,
            ),
            water: lucent.ReportCoverageDimensionDto(
              trackedDays: 3,
              totalDays: 7,
            ),
            sleep: lucent.ReportCoverageDimensionDto(
              trackedDays: 0,
              totalDays: 7,
            ),
          ),
          observedPattern: lucent.ReportObservedPatternDto(
            kind: lucent.ReportObservedPatternDtoKindEnum.medication,
            text: '近 5 天用药完成率保持在 80% 以上。',
            source_: '用药提醒记录',
          ),
          lowRiskAction: lucent.ReportLowRiskActionDto(
            label: '继续记录',
            text: '建议继续按当前节奏保持用药记录。',
          ),
          disclaimer: '仅基于近 7 天已记录数据生成，不构成诊断或治疗建议。',
        ),
      ),
    );

    final events = await repository
        .generateStream(ReportAiSummaryRange.last30Days)
        .toList();

    expect(events, hasLength(1));
    expect(events[0], isA<ReportAiGenerationResultEvent>());

    final summary = (events[0] as ReportAiGenerationResultEvent).summary;
    expect(summary.range, ReportAiSummaryRange.last30Days);
    expect(summary.generatedAt, DateTime.parse('2026-06-12T10:00:00.000Z'));
    expect(summary.coverage.medication.trackedDays, 5);
    expect(summary.coverage.water.trackedDays, 3);
    expect(summary.coverage.sleep.trackedDays, 0);
    expect(summary.observedPattern, isNotNull);
    expect(
      summary.observedPattern!.kind,
      ReportAiSummaryPatternKind.medication,
    );
    expect(summary.observedPattern!.text, '近 5 天用药完成率保持在 80% 以上。');
    expect(summary.observedPattern!.source, '用药提醒记录');
    expect(summary.lowRiskAction, isNotNull);
    expect(summary.lowRiskAction!.label, '继续记录');
    expect(summary.disclaimer, '仅基于近 7 天已记录数据生成，不构成诊断或治疗建议。');
  });
}

class _FakeReportAiSummaryRemoteDataSource
    extends ReportAiSummaryRemoteDataSource {
  _FakeReportAiSummaryRemoteDataSource(this._dto)
    : super(
        api: lucent.ReportsApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  final lucent.ReportSummaryResponseDto _dto;

  @override
  Stream<ReportAiRemoteEvent> generateStream(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    yield ReportAiRemoteResultEvent(_dto);
  }
}

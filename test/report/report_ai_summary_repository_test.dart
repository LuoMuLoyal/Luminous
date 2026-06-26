import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/report/data/datasources/report_ai_summary_remote_data_source.dart';
import 'package:luminous/features/report/data/repositories/lucent_report_ai_summary_repository.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';

void main() {
  test('Lucent report ai summary repository maps summary dto', () async {
    final repository = LucentReportAiSummaryRepository(
      dataSource: _FakeReportAiSummaryRemoteDataSource(
        lucent.ReportSummaryDataDto(
          range: lucent.ReportSummaryDataDtoRangeEnum.last30Days,
          startDate: '2026-06-06',
          endDate: '2026-06-12',
          generatedAt: '2026-06-12T10:00:00.000Z',
          summary: '本周用药记录整体稳定，饮水仍有少数低点。',
          bullets: [
            lucent.ReportSummaryBulletDto(
              kind: lucent.ReportSummaryBulletDtoKindEnum.medication,
              text: '本周大多数天都有用药记录。',
            ),
            lucent.ReportSummaryBulletDto(
              kind: lucent.ReportSummaryBulletDtoKindEnum.hydration,
              text: '饮水均值接近目标线。',
            ),
            lucent.ReportSummaryBulletDto(
              kind: lucent.ReportSummaryBulletDtoKindEnum.sleep,
              text: '睡眠数据仍待补充。',
            ),
          ],
          actionLabel: '查看报告',
          action: 'today',
          confidenceNote: '仅基于近 7 天已记录数据生成，不构成诊断或治疗建议。',
        ),
      ),
    );

    final summary = await repository.generate(ReportAiSummaryRange.last30Days);

    expect(summary.range, ReportAiSummaryRange.last30Days);
    expect(summary.generatedAt, DateTime.parse('2026-06-12T10:00:00.000Z'));
    expect(summary.bullets, hasLength(3));
    expect(summary.bullets.first.kind, ReportAiSummaryBulletKind.medication);
    expect(summary.bullets[1].kind, ReportAiSummaryBulletKind.hydration);
    expect(summary.bullets[2].kind, ReportAiSummaryBulletKind.sleep);
    expect(summary.actionLabel, '查看报告');
  });
}

class _FakeReportAiSummaryRemoteDataSource
    extends ReportAiSummaryRemoteDataSource {
  _FakeReportAiSummaryRemoteDataSource(this._dto)
    : super(
        api: lucent.ReportsApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  final lucent.ReportSummaryDataDto _dto;

  @override
  Future<lucent.ReportSummaryDataDto> generate(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async => _dto;

  @override
  Stream<ReportAiRemoteEvent> generateStream(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  }) async* {
    yield ReportAiRemoteResultEvent(_dto);
  }
}

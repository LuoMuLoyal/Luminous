import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/report/data/datasources/report_remote_data_source.dart';
import 'package:luminous/features/report/data/repositories/lucent_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';

void main() {
  test(
    'Lucent report repository maps insufficient sleep data into domain state',
    () async {
      final repository = LucentReportRepository(
        dataSource: _FakeReportRemoteDataSource(
          _dashboardDto(
            aiSummaryEnabled: false,
            findings: [
              lucent.ReportFindingDto(
                kind: lucent.ReportFindingDtoKindEnum.sleep,
                title: '睡眠数据不足',
                body: '最近 7 天还没有睡眠记录。',
              ),
            ],
            metrics: [
              lucent.ReportMetricDto(
                kind: lucent.ReportMetricDtoKindEnum.sleep,
                value: '--',
                unit: 'h',
                status: lucent.ReportMetricDtoStatusEnum.insufficientData,
                delta: '--',
                direction: lucent.ReportMetricDtoDirectionEnum.flat,
                sparkline: const [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
            patterns: [
              lucent.ReportPatternDto(
                kind: lucent.ReportPatternDtoKindEnum.sleep,
                title: '等待睡眠数据',
                status: lucent.ReportPatternDtoStatusEnum.insufficientData,
                body: '补齐睡眠合同后再输出睡眠模式。',
                sparkline: const [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
            trends: [
              lucent.ReportTrendDto(
                kind: lucent.ReportTrendDtoKindEnum.sleep,
                unit: 'h',
                currentValue: '--',
                values: const [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
          ),
        ),
      );

      final dashboard = await repository.fetchDashboard();

      expect(dashboard.score.status, ReportStatus.stable);
      expect(dashboard.metrics.single.kind, ReportDataKind.sleep);
      expect(dashboard.metrics.single.status, ReportStatus.insufficientData);
      expect(dashboard.metrics.single.direction, ReportMetricDirection.flat);
      expect(dashboard.trends.single.kind, ReportDataKind.sleep);
      expect(dashboard.trends.single.currentValue, '--');
      expect(dashboard.findings.single.kind, ReportInsightKind.sleep);
      expect(dashboard.patterns.single.status, ReportStatus.insufficientData);
      expect(dashboard.aiSummaryEnabled, isFalse);
    },
  );

  test(
    'Lucent report repository uses ai summary mode and truncates summary findings',
    () async {
      final repository = LucentReportRepository(
        dataSource: _FakeReportRemoteDataSource(
          _dashboardDto(
            aiSummaryEnabled: true,
            findings: [
              for (var index = 1; index <= 4; index += 1)
                lucent.ReportFindingDto(
                  kind: lucent.ReportFindingDtoKindEnum.hydration,
                  title: '发现$index',
                  body: '正文$index',
                ),
            ],
            metrics: [
              lucent.ReportMetricDto(
                kind: lucent.ReportMetricDtoKindEnum.medication,
                value: '93',
                unit: '%',
                status: lucent.ReportMetricDtoStatusEnum.good,
                delta: '9%',
                direction: lucent.ReportMetricDtoDirectionEnum.up,
                sparkline: const [80, 88, 92, 89, 93, 88, 93],
              ),
            ],
            patterns: [
              lucent.ReportPatternDto(
                kind: lucent.ReportPatternDtoKindEnum.medication,
                title: '用药依从性稳定',
                status: lucent.ReportPatternDtoStatusEnum.good,
                body: '近 7 天按计划完成率较高。',
                sparkline: const [48, 50, 47, 52, 49, 51, 58],
              ),
            ],
            trends: [
              lucent.ReportTrendDto(
                kind: lucent.ReportTrendDtoKindEnum.medication,
                unit: '%',
                currentValue: '93%',
                values: const [80, 88, 92, 89, 93, 88, 93],
              ),
            ],
          ),
        ),
      );

      final dashboard = await repository.fetchDashboard();

      expect(dashboard.aiSummaryEnabled, isTrue);
      expect(
        dashboard.exportActions.map((action) => action.kind).toList(),
        const [
          ReportExportKind.hospital,
          ReportExportKind.monthly,
          ReportExportKind.print,
        ],
      );
      expect(dashboard.metrics.single.status, ReportStatus.good);
      expect(dashboard.metrics.single.direction, ReportMetricDirection.up);
      expect(dashboard.patterns.single.kind, ReportInsightKind.medication);
    },
  );
}

class _FakeReportRemoteDataSource extends ReportRemoteDataSource {
  _FakeReportRemoteDataSource(this._dto)
    : super(
        api: lucent.ReportsApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  final lucent.ReportDashboardDataDto _dto;

  @override
  Future<lucent.ReportDashboardDataDto> fetchDashboard() async => _dto;
}

lucent.ReportDashboardDataDto _dashboardDto({
  required bool aiSummaryEnabled,
  required List<lucent.ReportMetricDto> metrics,
  required List<lucent.ReportTrendDto> trends,
  required List<lucent.ReportFindingDto> findings,
  required List<lucent.ReportPatternDto> patterns,
}) {
  return lucent.ReportDashboardDataDto(
    range: lucent.ReportDashboardDataDtoRangeEnum.last7Days,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    generatedAt: '2026-06-12T10:00:00.000Z',
    score: lucent.ReportDashboardScoreDto(
      value: 78,
      maxValue: 100,
      status: lucent.ReportDashboardScoreDtoStatusEnum.stable,
      summary: '本周整体稳定，睡眠暂缺真实数据。',
    ),
    metrics: metrics,
    trends: trends,
    findings: findings,
    patterns: patterns,
    aiSummaryEnabled: aiSummaryEnabled,
  );
}

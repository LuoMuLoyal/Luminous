import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart' as lucent;
import 'package:luminous/features/report/data/datasources/report.dart';
import 'package:luminous/features/report/data/repositories/lucent.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';

void main() {
  test(
    'Lucent report repository maps insufficient sleep data into domain state',
    () async {
      final repository = LucentReportRepository(
        dataSource: _FakeReportRemoteDataSource(
          _dashboardDto(
            aiSummaryEnabled: false,
            findings: [
              const lucent.ReportFindingDto(
                kind: lucent.ReportFindingDtoKindKind.sleep,
                title: '睡眠数据不足',
                body: '最近 7 天还没有睡眠记录。',
              ),
            ],
            metrics: [
              const lucent.ReportMetricDto(
                kind: lucent.ReportMetricDtoKindKind.sleep,
                value: '--',
                unit: 'h',
                status: lucent.ReportMetricDtoStatusStatus.insufficientData,
                delta: '--',
                direction: lucent.ReportMetricDtoDirectionDirection.flat,
                sparkline: [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
            patterns: [
              const lucent.ReportPatternDto(
                kind: lucent.ReportPatternDtoKindKind.sleep,
                title: '等待睡眠数据',
                status: lucent.ReportPatternDtoStatusStatus.insufficientData,
                body: '补齐睡眠合同后再输出睡眠模式。',
                sparkline: [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
            trends: [
              const lucent.ReportTrendDto(
                kind: lucent.ReportTrendDtoKindKind.sleep,
                unit: 'h',
                currentValue: '--',
                valuesField: [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
          ),
        ),
      );

      final dashboard = await repository.fetchDashboard(
        const ReportDashboardQuery(range: ReportDashboardRange.last7Days),
      );

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
                  kind: lucent.ReportFindingDtoKindKind.hydration,
                  title: '发现$index',
                  body: '正文$index',
                ),
            ],
            metrics: [
              const lucent.ReportMetricDto(
                kind: lucent.ReportMetricDtoKindKind.medication,
                value: '93',
                unit: '%',
                status: lucent.ReportMetricDtoStatusStatus.good,
                delta: '9%',
                direction: lucent.ReportMetricDtoDirectionDirection.up,
                sparkline: [80, 88, 92, 89, 93, 88, 93],
              ),
            ],
            patterns: [
              const lucent.ReportPatternDto(
                kind: lucent.ReportPatternDtoKindKind.medication,
                title: '用药依从性稳定',
                status: lucent.ReportPatternDtoStatusStatus.good,
                body: '近 7 天按计划完成率较高。',
                sparkline: [48, 50, 47, 52, 49, 51, 58],
              ),
            ],
            trends: [
              const lucent.ReportTrendDto(
                kind: lucent.ReportTrendDtoKindKind.medication,
                unit: '%',
                currentValue: '93%',
                valuesField: [80, 88, 92, 89, 93, 88, 93],
              ),
            ],
          ),
        ),
      );

      final dashboard = await repository.fetchDashboard(
        const ReportDashboardQuery(range: ReportDashboardRange.last7Days),
      );

      expect(dashboard.aiSummaryEnabled, isTrue);
      expect(
        dashboard.exportActions.map((action) => action.kind).toList(),
        const [
          ReportExportKind.hospital,
          ReportExportKind.monthly,
          ReportExportKind.print,
          ReportExportKind.clinicShare,
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
  Future<lucent.ReportDashboardDataDto> fetchDashboard(
    ReportDashboardQuery query,
  ) async => _dto;
}

lucent.ReportDashboardDataDto _dashboardDto({
  required bool aiSummaryEnabled,
  required List<lucent.ReportMetricDto> metrics,
  required List<lucent.ReportTrendDto> trends,
  required List<lucent.ReportFindingDto> findings,
  required List<lucent.ReportPatternDto> patterns,
}) {
  return lucent.ReportDashboardDataDto(
    range: lucent.ReportDashboardDataDtoRangeRange.last7Days,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    generatedAt: '2026-06-12T10:00:00.000Z',
    score: const lucent.ReportDashboardScoreDto(
      value: 78,
      maxValue: 100,
      status: lucent.ReportDashboardScoreDtoStatusStatus.stable,
      summary: '本周整体稳定，睡眠暂缺真实数据。',
    ),
    metrics: metrics,
    trends: trends,
    findings: findings,
    patterns: patterns,
    aiSummaryEnabled: aiSummaryEnabled,
  );
}

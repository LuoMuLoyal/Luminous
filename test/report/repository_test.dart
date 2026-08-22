import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
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
                sparkline: [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
            patterns: [
              lucent.ReportPatternDto(
                kind: lucent.ReportPatternDtoKindEnum.sleep,
                title: '等待睡眠数据',
                status: lucent.ReportPatternDtoStatusEnum.insufficientData,
                body: '补齐睡眠合同后再输出睡眠模式。',
                sparkline: [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
            trends: [
              lucent.ReportTrendDto(
                kind: lucent.ReportTrendDtoKindEnum.sleep,
                unit: 'h',
                currentValue: '--',
                values: [0, 0, 0, 0, 0, 0, 0],
              ),
            ],
          ),
        ),
      );

      final dashboard = await repository.fetchDashboard(
        const ReportDashboardQuery(range: ReportDashboardRange.last7Days),
      );

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
                sparkline: [80, 88, 92, 89, 93, 88, 93],
              ),
            ],
            patterns: [
              lucent.ReportPatternDto(
                kind: lucent.ReportPatternDtoKindEnum.medication,
                title: '用药依从性稳定',
                status: lucent.ReportPatternDtoStatusEnum.good,
                body: '近 7 天按计划完成率较高。',
                sparkline: [48, 50, 47, 52, 49, 51, 58],
              ),
            ],
            trends: [
              lucent.ReportTrendDto(
                kind: lucent.ReportTrendDtoKindEnum.medication,
                unit: '%',
                currentValue: '93%',
                values: [80, 88, 92, 89, 93, 88, 93],
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

  test('Lucent report repository prefers generated observed metric', () async {
    final repository = LucentReportRepository(
      dataSource: _FakeReportRemoteDataSource(
        _dashboardDto(
          aiSummaryEnabled: false,
          findings: const [],
          patterns: const [],
          trends: const [],
          metrics: [
            lucent.ReportMetricDto(
              kind: lucent.ReportMetricDtoKindEnum.water,
              value: '999',
              unit: 'ml',
              status: lucent.ReportMetricDtoStatusEnum.good,
              delta: '999',
              direction: lucent.ReportMetricDtoDirectionEnum.up,
              sparkline: [999],
              observedMetric: lucent.ReportObservedMetricDto(
                value: 0,
                state: lucent.ReportObservedMetricDtoStateEnum.observed,
                coverage: lucent.ReportObservedMetricDtoCoverageEnum.sufficient,
                sources: [lucent.ReportObservedMetricDtoSourcesEnum.manual],
                observedCount: 1,
                expectedCount: null,
                windowStart: '2026-08-05',
                windowEnd: '2026-08-11',
              ),
            ),
          ],
        ),
      ),
    );

    final dashboard = await repository.fetchDashboard(
      const ReportDashboardQuery(range: ReportDashboardRange.last7Days),
    );

    final metric = dashboard.metrics.single;
    expect(metric.value, '999');
    expect(metric.observedMetric?.value, 0);
    expect(
      metric.observedMetric?.coverage,
      ReportObservedMetricCoverage.sufficient,
    );
  });

  test(
    'Lucent report repository keeps scalar fallback when observed metric is absent',
    () async {
      final repository = LucentReportRepository(
        dataSource: _FakeReportRemoteDataSource(
          _dashboardDto(
            aiSummaryEnabled: false,
            findings: const [],
            patterns: const [],
            trends: const [],
            metrics: [
              lucent.ReportMetricDto(
                kind: lucent.ReportMetricDtoKindEnum.water,
                value: '500',
                unit: 'ml',
                status: lucent.ReportMetricDtoStatusEnum.good,
                delta: '10%',
                direction: lucent.ReportMetricDtoDirectionEnum.up,
                sparkline: [500],
              ),
            ],
          ),
        ),
      );

      final dashboard = await repository.fetchDashboard(
        const ReportDashboardQuery(range: ReportDashboardRange.last7Days),
      );

      expect(dashboard.metrics.single.value, '500');
      expect(dashboard.metrics.single.observedMetric, isNull);
    },
  );
}

class _FakeReportRemoteDataSource extends ReportRemoteDataSource {
  _FakeReportRemoteDataSource(this._dto)
    : super(
        api: lucent.ReportsApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  final lucent.ReportDashboardResponseDto _dto;

  @override
  Future<lucent.ReportDashboardResponseDto> fetchDashboard(
    ReportDashboardQuery query,
  ) async => _dto;
}

lucent.ReportDashboardResponseDto _dashboardDto({
  required bool aiSummaryEnabled,
  required List<lucent.ReportMetricDto> metrics,
  required List<lucent.ReportTrendDto> trends,
  required List<lucent.ReportFindingDto> findings,
  required List<lucent.ReportPatternDto> patterns,
}) {
  return lucent.ReportDashboardResponseDto(
    range: lucent.ReportDashboardResponseDtoRangeEnum.last7Days,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    generatedAt: '2026-06-12T10:00:00.000Z',
    metrics: metrics,
    trends: trends,
    findings: findings,
    patterns: patterns,
    aiSummaryEnabled: aiSummaryEnabled,
  );
}

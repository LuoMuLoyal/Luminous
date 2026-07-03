import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/report/data/datasources/report_remote_data_source.dart';
import 'package:luminous/features/report/data/repositories/lucent_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report_repository.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  final api = ref.watch(lucentReportsApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return ReportRemoteDataSource(api: api, dio: dio);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dataSource = ref.watch(reportRemoteDataSourceProvider);
  return LucentReportRepository(dataSource: dataSource);
});

class MockReportRepository implements ReportRepository {
  const MockReportRepository();

  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) async {
    return _dashboardForQuery(query);
  }

  static ReportDashboard _dashboardForQuery(ReportDashboardQuery query) {
    final startDate = query.startDate ?? DateTime(2026, 6, 6);
    final endDate = query.endDate ?? DateTime(2026, 6, 12);
    final startIso = _dateOnly(startDate);
    final endIso = _dateOnly(endDate);
    return previewDashboard.copyWith(
      range: query.range,
      startDate: startIso,
      endDate: endIso,
    );
  }

  static String _dateOnly(DateTime date) {
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  static final previewDashboard = ReportDashboard(
    range: ReportDashboardRange.last7Days,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    score: ReportHealthScore(
      value: 0,
      maxValue: 100,
      status: ReportStatus.stable,
      summary: 'Loading latest report snapshot...',
    ),
    metrics: <ReportMetric>[
      ReportMetric(
        kind: ReportDataKind.medication,
        icon: FLucideIcons.pill,
        color: AppColors.primary,
        value: '--',
        unit: '%',
        status: ReportStatus.stable,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.sleep,
        icon: FLucideIcons.moon,
        color: AppColors.primary,
        value: '--',
        unit: 'h',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.water,
        icon: FLucideIcons.droplets,
        color: AppColors.primary,
        value: '--',
        unit: 'L',
        status: ReportStatus.stable,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    trends: <ReportTrendSeries>[
      ReportTrendSeries(
        kind: ReportDataKind.sleep,
        color: AppColors.primary,
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.water,
        color: AppColors.primary,
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.medication,
        color: AppColors.primary,
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReportFinding>[
      ReportFinding(
        kind: ReportInsightKind.general,
        icon: FLucideIcons.chartLine,
        color: AppColors.primary,
        title: 'Preparing report',
        body: 'The latest contract-backed report is loading.',
      ),
    ],
    exportActions: <ReportExportAction>[
      ReportExportAction(
        kind: ReportExportKind.hospital,
        icon: FLucideIcons.hospital,
        color: AppColors.primary,
      ),
      ReportExportAction(
        kind: ReportExportKind.monthly,
        icon: FLucideIcons.barChart,
        color: AppColors.primary,
      ),
      ReportExportAction(
        kind: ReportExportKind.print,
        icon: FLucideIcons.printer,
        color: AppColors.primary,
      ),
    ],
    patterns: <ReportPatternCard>[
      ReportPatternCard(
        kind: ReportInsightKind.general,
        icon: FLucideIcons.chartLine,
        color: AppColors.primary,
        title: 'Preparing report',
        status: ReportStatus.stable,
        body: 'Pattern cards will appear after the latest report loads.',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );

  static final signedOutDashboard = ReportDashboard(
    range: ReportDashboardRange.last7Days,
    startDate: '2026-06-06',
    endDate: '2026-06-12',
    score: ReportHealthScore(
      value: 0,
      maxValue: 100,
      status: ReportStatus.insufficientData,
      summary: '登录后可查看最近 7 天的真实报告聚合。',
    ),
    metrics: <ReportMetric>[
      ReportMetric(
        kind: ReportDataKind.medication,
        icon: FLucideIcons.pill,
        color: AppColors.primary,
        value: '--',
        unit: '%',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.sleep,
        icon: FLucideIcons.moon,
        color: AppColors.primary,
        value: '--',
        unit: 'h',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.water,
        icon: FLucideIcons.droplets,
        color: AppColors.primary,
        value: '--',
        unit: 'L',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    trends: <ReportTrendSeries>[
      ReportTrendSeries(
        kind: ReportDataKind.sleep,
        color: AppColors.primary,
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.water,
        color: AppColors.primary,
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.medication,
        color: AppColors.primary,
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReportFinding>[
      ReportFinding(
        kind: ReportInsightKind.general,
        icon: FLucideIcons.lock,
        color: AppColors.primary,
        title: '登录后解锁报告',
        body: '报告会基于你的真实记录生成最近 7 天的聚合结果。',
      ),
    ],
    exportActions: <ReportExportAction>[
      ReportExportAction(
        kind: ReportExportKind.hospital,
        icon: FLucideIcons.hospital,
        color: AppColors.primary,
      ),
      ReportExportAction(
        kind: ReportExportKind.monthly,
        icon: FLucideIcons.barChart,
        color: AppColors.primary,
      ),
      ReportExportAction(
        kind: ReportExportKind.print,
        icon: FLucideIcons.printer,
        color: AppColors.primary,
      ),
    ],
    patterns: <ReportPatternCard>[
      ReportPatternCard(
        kind: ReportInsightKind.general,
        icon: FLucideIcons.lock,
        color: AppColors.primary,
        title: '等待登录',
        status: ReportStatus.insufficientData,
        body: '登录后显示真实模式卡片。',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );
}

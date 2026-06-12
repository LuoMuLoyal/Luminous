import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
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
  Future<ReportDashboard> fetchDashboard() async {
    return previewDashboard;
  }

  static const previewDashboard = ReportDashboard(
    score: ReportHealthScore(
      value: 0,
      maxValue: 100,
      status: ReportStatus.stable,
      summary: 'Loading latest report snapshot...',
    ),
    metrics: <ReportMetric>[
      ReportMetric(
        kind: ReportDataKind.medication,
        icon: Icons.medication_rounded,
        color: AppColorTokens.cyanDeep,
        value: '--',
        unit: '%',
        status: ReportStatus.stable,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.sleep,
        icon: Icons.nightlight_round,
        color: AppColorTokens.violet,
        value: '--',
        unit: 'h',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.water,
        icon: Icons.water_drop_rounded,
        color: AppColorTokens.link,
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
        color: AppColorTokens.violet,
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.water,
        color: AppColorTokens.link,
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.medication,
        color: AppColorTokens.cyanDeep,
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReportFinding>[
      ReportFinding(
        kind: ReportInsightKind.general,
        icon: Icons.insights_rounded,
        color: AppColorTokens.health,
        title: 'Preparing report',
        body: 'The latest contract-backed report is loading.',
      ),
    ],
    exportActions: <ReportExportAction>[
      ReportExportAction(
        kind: ReportExportKind.hospital,
        icon: Icons.local_hospital_rounded,
        color: AppColorTokens.link,
      ),
      ReportExportAction(
        kind: ReportExportKind.monthly,
        icon: Icons.bar_chart_rounded,
        color: AppColorTokens.link,
      ),
      ReportExportAction(
        kind: ReportExportKind.print,
        icon: Icons.print_rounded,
        color: AppColorTokens.warning,
      ),
    ],
    patterns: <ReportPatternCard>[
      ReportPatternCard(
        kind: ReportInsightKind.general,
        icon: Icons.insights_rounded,
        color: AppColorTokens.health,
        title: 'Preparing report',
        status: ReportStatus.stable,
        body: 'Pattern cards will appear after the latest report loads.',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );

  static const signedOutDashboard = ReportDashboard(
    score: ReportHealthScore(
      value: 0,
      maxValue: 100,
      status: ReportStatus.insufficientData,
      summary: '登录后可查看最近 7 天的真实报告聚合。',
    ),
    metrics: <ReportMetric>[
      ReportMetric(
        kind: ReportDataKind.medication,
        icon: Icons.medication_rounded,
        color: AppColorTokens.cyanDeep,
        value: '--',
        unit: '%',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.sleep,
        icon: Icons.nightlight_round,
        color: AppColorTokens.violet,
        value: '--',
        unit: 'h',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.water,
        icon: Icons.water_drop_rounded,
        color: AppColorTokens.link,
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
        color: AppColorTokens.violet,
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.water,
        color: AppColorTokens.link,
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.medication,
        color: AppColorTokens.cyanDeep,
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReportFinding>[
      ReportFinding(
        kind: ReportInsightKind.general,
        icon: Icons.lock_outline_rounded,
        color: AppColorTokens.warning,
        title: '登录后解锁报告',
        body: '报告会基于你的真实记录生成最近 7 天的聚合结果。',
      ),
    ],
    exportActions: <ReportExportAction>[
      ReportExportAction(
        kind: ReportExportKind.hospital,
        icon: Icons.local_hospital_rounded,
        color: AppColorTokens.link,
      ),
      ReportExportAction(
        kind: ReportExportKind.monthly,
        icon: Icons.bar_chart_rounded,
        color: AppColorTokens.link,
      ),
      ReportExportAction(
        kind: ReportExportKind.print,
        icon: Icons.print_rounded,
        color: AppColorTokens.warning,
      ),
    ],
    patterns: <ReportPatternCard>[
      ReportPatternCard(
        kind: ReportInsightKind.general,
        icon: Icons.lock_outline_rounded,
        color: AppColorTokens.warning,
        title: '等待登录',
        status: ReportStatus.insufficientData,
        body: '登录后显示真实模式卡片。',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );
}

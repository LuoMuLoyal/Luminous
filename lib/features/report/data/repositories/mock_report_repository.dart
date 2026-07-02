import 'package:luminous/core/design/app_design.dart';
import 'package:flutter/material.dart';
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

  static const previewDashboard = ReportDashboard(
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
        icon: Icons.medication_rounded,
        color: Color(0xFF0F766E),
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
        color: Color(0xFF7C3AED),
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
        color: Color(0xFF16A34A),
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
        color: Color(0xFF7C3AED),
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.water,
        color: Color(0xFF16A34A),
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.medication,
        color: Color(0xFF0F766E),
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReportFinding>[
      ReportFinding(
        kind: ReportInsightKind.general,
        icon: Icons.insights_rounded,
        color: Color(0xFF15803D),
        title: 'Preparing report',
        body: 'The latest contract-backed report is loading.',
      ),
    ],
    exportActions: <ReportExportAction>[
      ReportExportAction(
        kind: ReportExportKind.hospital,
        icon: Icons.local_hospital_rounded,
        color: Color(0xFF16A34A),
      ),
      ReportExportAction(
        kind: ReportExportKind.monthly,
        icon: Icons.bar_chart_rounded,
        color: Color(0xFF16A34A),
      ),
      ReportExportAction(
        kind: ReportExportKind.print,
        icon: Icons.print_rounded,
        color: Color(0xFFF59E0B),
      ),
    ],
    patterns: <ReportPatternCard>[
      ReportPatternCard(
        kind: ReportInsightKind.general,
        icon: Icons.insights_rounded,
        color: Color(0xFF15803D),
        title: 'Preparing report',
        status: ReportStatus.stable,
        body: 'Pattern cards will appear after the latest report loads.',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );

  static const signedOutDashboard = ReportDashboard(
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
        icon: Icons.medication_rounded,
        color: Color(0xFF0F766E),
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
        color: Color(0xFF7C3AED),
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
        color: Color(0xFF16A34A),
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
        color: Color(0xFF7C3AED),
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.water,
        color: Color(0xFF16A34A),
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.medication,
        color: Color(0xFF0F766E),
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReportFinding>[
      ReportFinding(
        kind: ReportInsightKind.general,
        icon: Icons.lock_outline_rounded,
        color: Color(0xFFF59E0B),
        title: '登录后解锁报告',
        body: '报告会基于你的真实记录生成最近 7 天的聚合结果。',
      ),
    ],
    exportActions: <ReportExportAction>[
      ReportExportAction(
        kind: ReportExportKind.hospital,
        icon: Icons.local_hospital_rounded,
        color: Color(0xFF16A34A),
      ),
      ReportExportAction(
        kind: ReportExportKind.monthly,
        icon: Icons.bar_chart_rounded,
        color: Color(0xFF16A34A),
      ),
      ReportExportAction(
        kind: ReportExportKind.print,
        icon: Icons.print_rounded,
        color: Color(0xFFF59E0B),
      ),
    ],
    patterns: <ReportPatternCard>[
      ReportPatternCard(
        kind: ReportInsightKind.general,
        icon: Icons.lock_outline_rounded,
        color: Color(0xFFF59E0B),
        title: '等待登录',
        status: ReportStatus.insufficientData,
        body: '登录后显示真实模式卡片。',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );
}

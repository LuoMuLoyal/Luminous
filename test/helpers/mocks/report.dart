// ignore_for_file: prefer_const_constructors
import 'package:clock/clock.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report.dart';

/// Test-only mock implementation of [ReportRepository].
class MockReportRepository implements ReportRepository {
  const MockReportRepository();

  @override
  Future<ReportDashboard> get signedOutDashboard =>
      Future.value(_signedOutDashboard);

  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) async {
    return _dashboardForQuery(query);
  }

  static ReportDashboard _dashboardForQuery(ReportDashboardQuery query) {
    final startDate =
        query.startDate ?? clock.now().subtract(const Duration(days: 7));
    final endDate = query.endDate ?? clock.now();
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
    startDate: _dateOnly(clock.now().subtract(const Duration(days: 7))),
    endDate: _dateOnly(clock.now()),
    generatedAt: clock.now().toIso8601String(),
    score: ReportHealthScore(
      value: 0,
      maxValue: 100,
      status: ReportStatus.stable,
      summary: 'Loading latest report snapshot...',
    ),
    metrics: <ReportMetric>[
      ReportMetric(
        kind: ReportDataKind.medication,
        icon: SemanticIcons.recordMedicine,
        color: SemanticColor.primary,
        value: '--',
        unit: '%',
        status: ReportStatus.stable,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.sleep,
        icon: SemanticIcons.recordMoon,
        color: SemanticColor.primary,
        value: '--',
        unit: 'h',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.water,
        icon: SemanticIcons.recordWater,
        color: SemanticColor.primary,
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
        color: SemanticColor.primary,
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.water,
        color: SemanticColor.primary,
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.medication,
        color: SemanticColor.primary,
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReportFinding>[
      ReportFinding(
        kind: ReportInsightKind.general,
        icon: SemanticIcons.reportChart,
        color: SemanticColor.primary,
        title: 'Preparing report',
        body: 'The latest contract-backed report is loading.',
      ),
    ],
    exportActions: <ReportExportAction>[
      ReportExportAction(
        kind: ReportExportKind.hospital,
        icon: SemanticIcons.medicineKit,
        color: SemanticColor.primary,
      ),
      ReportExportAction(
        kind: ReportExportKind.monthly,
        icon: FLucideIcons.barChart,
        color: SemanticColor.primary,
      ),
      ReportExportAction(
        kind: ReportExportKind.print,
        icon: SemanticIcons.actionExport,
        color: SemanticColor.primary,
      ),
    ],
    patterns: <ReportPatternCard>[
      ReportPatternCard(
        kind: ReportInsightKind.general,
        icon: SemanticIcons.reportChart,
        color: SemanticColor.primary,
        title: 'Preparing report',
        status: ReportStatus.stable,
        body: 'Pattern cards will appear after the latest report loads.',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );

  static final _signedOutDashboard = ReportDashboard(
    range: ReportDashboardRange.last7Days,
    startDate: _dateOnly(clock.now().subtract(const Duration(days: 7))),
    endDate: _dateOnly(clock.now()),
    generatedAt: clock.now().toIso8601String(),
    score: ReportHealthScore(
      value: 0,
      maxValue: 100,
      status: ReportStatus.insufficientData,
      summary: '登录后可查看最近 7 天的真实报告聚合。',
    ),
    metrics: <ReportMetric>[
      ReportMetric(
        kind: ReportDataKind.medication,
        icon: SemanticIcons.recordMedicine,
        color: SemanticColor.primary,
        value: '--',
        unit: '%',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.sleep,
        icon: SemanticIcons.recordMoon,
        color: SemanticColor.primary,
        value: '--',
        unit: 'h',
        status: ReportStatus.insufficientData,
        delta: '--',
        direction: ReportMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReportMetric(
        kind: ReportDataKind.water,
        icon: SemanticIcons.recordWater,
        color: SemanticColor.primary,
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
        color: SemanticColor.primary,
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.water,
        color: SemanticColor.primary,
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReportTrendSeries(
        kind: ReportDataKind.medication,
        color: SemanticColor.primary,
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReportFinding>[
      ReportFinding(
        kind: ReportInsightKind.general,
        icon: SemanticIcons.statusBlocked,
        color: SemanticColor.primary,
        title: '登录后解锁报告',
        body: '报告会基于你的真实记录生成最近 7 天的聚合结果。',
      ),
    ],
    exportActions: <ReportExportAction>[
      ReportExportAction(
        kind: ReportExportKind.hospital,
        icon: SemanticIcons.medicineKit,
        color: SemanticColor.primary,
      ),
      ReportExportAction(
        kind: ReportExportKind.monthly,
        icon: FLucideIcons.barChart,
        color: SemanticColor.primary,
      ),
      ReportExportAction(
        kind: ReportExportKind.print,
        icon: SemanticIcons.actionExport,
        color: SemanticColor.primary,
      ),
    ],
    patterns: <ReportPatternCard>[
      ReportPatternCard(
        kind: ReportInsightKind.general,
        icon: SemanticIcons.statusBlocked,
        color: SemanticColor.primary,
        title: '等待登录',
        status: ReportStatus.insufficientData,
        body: '登录后显示真实模式卡片。',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );
}

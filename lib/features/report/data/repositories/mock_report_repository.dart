import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report_repository.dart';

class MockReportRepository implements ReportRepository {
  const MockReportRepository();

  @override
  Future<ReportDashboard> fetchDashboard() async {
    return dashboard;
  }

  static const dashboard = ReportDashboard(
    score: ReportHealthScore(
      value: 82,
      maxValue: 100,
      statusKey: ReportCopyKey.statusOverallStable,
      bodyKey: ReportCopyKey.scoreBody,
    ),
    metrics: <ReportMetric>[
      ReportMetric(
        icon: Icons.medication_rounded,
        color: AppColorTokens.cyanDeep,
        titleKey: ReportCopyKey.metricMedicationTitle,
        value: '93',
        unitKey: ReportCopyKey.unitPercent,
        statusKey: ReportCopyKey.statusGood,
        deltaKey: ReportCopyKey.deltaMedication,
        direction: ReportMetricDirection.up,
        sparkline: <double>[61, 72, 66, 76, 69, 78],
      ),
      ReportMetric(
        icon: Icons.nightlight_round,
        color: AppColorTokens.violet,
        titleKey: ReportCopyKey.metricSleepTitle,
        value: '7.2',
        unitKey: ReportCopyKey.unitHour,
        statusKey: ReportCopyKey.statusGood,
        deltaKey: ReportCopyKey.deltaSleep,
        direction: ReportMetricDirection.up,
        sparkline: <double>[52, 66, 58, 50, 63, 59],
      ),
      ReportMetric(
        icon: Icons.water_drop_rounded,
        color: AppColorTokens.link,
        titleKey: ReportCopyKey.metricWaterTitle,
        value: '1.6',
        unitKey: ReportCopyKey.unitLiter,
        statusKey: ReportCopyKey.statusNeedsImprove,
        deltaKey: ReportCopyKey.deltaWater,
        direction: ReportMetricDirection.down,
        sparkline: <double>[43, 49, 42, 48, 41, 39],
      ),
    ],
    trends: <ReportTrendSeries>[
      ReportTrendSeries(
        labelKey: ReportCopyKey.trendSleepLabel,
        color: AppColorTokens.violet,
        values: <double>[5.2, 5.4, 6.0, 5.5, 6.0, 5.4, 7.2],
        currentValue: '7.2',
      ),
      ReportTrendSeries(
        labelKey: ReportCopyKey.trendWaterLabel,
        color: AppColorTokens.link,
        values: <double>[1.5, 1.9, 1.6, 1.9, 1.6, 1.6, 1.6],
        currentValue: '1.6',
      ),
      ReportTrendSeries(
        labelKey: ReportCopyKey.trendMedicationLabel,
        color: AppColorTokens.cyanDeep,
        values: <double>[80, 88, 92, 89, 93, 88, 93],
        currentValue: '93%',
      ),
    ],
    findings: <ReportFinding>[
      ReportFinding(
        icon: Icons.coffee_rounded,
        color: AppColorTokens.warning,
        titleKey: ReportCopyKey.findingCoffeeTitle,
        bodyKey: ReportCopyKey.findingCoffeeBody,
      ),
      ReportFinding(
        icon: Icons.verified_rounded,
        color: AppColorTokens.cyanDeep,
        titleKey: ReportCopyKey.findingMedicineTitle,
        bodyKey: ReportCopyKey.findingMedicineBody,
      ),
    ],
    aiBullets: <ReportAiBullet>[
      ReportAiBullet(
        color: AppColorTokens.link,
        bodyKey: ReportCopyKey.aiBulletSleep,
      ),
      ReportAiBullet(
        color: AppColorTokens.cyanDeep,
        bodyKey: ReportCopyKey.aiBulletWater,
      ),
      ReportAiBullet(
        color: AppColorTokens.cyanDeep,
        bodyKey: ReportCopyKey.aiBulletMedicine,
      ),
      ReportAiBullet(
        color: AppColorTokens.warning,
        bodyKey: ReportCopyKey.aiBulletDiet,
      ),
    ],
    exportActions: <ReportExportAction>[
      ReportExportAction(
        icon: Icons.local_hospital_rounded,
        color: AppColorTokens.link,
        titleKey: ReportCopyKey.exportHospitalTitle,
        subtitleKey: ReportCopyKey.exportHospitalSubtitle,
      ),
      ReportExportAction(
        icon: Icons.bar_chart_rounded,
        color: AppColorTokens.link,
        titleKey: ReportCopyKey.exportMonthlyTitle,
        subtitleKey: ReportCopyKey.exportMonthlySubtitle,
      ),
      ReportExportAction(
        icon: Icons.print_rounded,
        color: AppColorTokens.warning,
        titleKey: ReportCopyKey.exportPrintTitle,
        subtitleKey: ReportCopyKey.exportPrintSubtitle,
      ),
    ],
    patterns: <ReportPatternCard>[
      ReportPatternCard(
        icon: Icons.nightlight_round,
        color: AppColorTokens.link,
        titleKey: ReportCopyKey.patternSleepTitle,
        statusKey: ReportCopyKey.patternSleepStatus,
        bodyKey: ReportCopyKey.patternSleepBody,
        sparkline: <double>[42, 36, 44, 40, 46, 43, 52],
      ),
      ReportPatternCard(
        icon: Icons.restaurant_rounded,
        color: AppColorTokens.cyanDeep,
        titleKey: ReportCopyKey.patternDietWaterTitle,
        statusKey: ReportCopyKey.patternDietWaterStatus,
        bodyKey: ReportCopyKey.patternDietWaterBody,
        sparkline: <double>[38, 46, 39, 41, 49, 43, 51],
      ),
      ReportPatternCard(
        icon: Icons.medication_rounded,
        color: AppColorTokens.cyanDeep,
        titleKey: ReportCopyKey.patternMedicationTitle,
        statusKey: ReportCopyKey.patternMedicationStatus,
        bodyKey: ReportCopyKey.patternMedicationBody,
        sparkline: <double>[48, 50, 47, 52, 49, 51, 58],
      ),
    ],
    privacyActions: <ReportPrivacyAction>[
      ReportPrivacyAction(
        icon: Icons.privacy_tip_outlined,
        color: AppColorTokens.link,
        titleKey: ReportCopyKey.privacyExportControls,
      ),
    ],
  );
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return const MockReportRepository();
});

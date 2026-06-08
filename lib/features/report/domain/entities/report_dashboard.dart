import 'package:flutter/material.dart';

class ReportDashboard {
  const ReportDashboard({
    required this.score,
    required this.metrics,
    required this.trends,
    required this.findings,
    required this.aiBullets,
    required this.exportActions,
    required this.patterns,
    required this.privacyActions,
  });

  final ReportHealthScore score;
  final List<ReportMetric> metrics;
  final List<ReportTrendSeries> trends;
  final List<ReportFinding> findings;
  final List<ReportAiBullet> aiBullets;
  final List<ReportExportAction> exportActions;
  final List<ReportPatternCard> patterns;
  final List<ReportPrivacyAction> privacyActions;
}

class ReportHealthScore {
  const ReportHealthScore({
    required this.value,
    required this.maxValue,
    required this.statusKey,
    required this.bodyKey,
  });

  final int value;
  final int maxValue;
  final ReportCopyKey statusKey;
  final ReportCopyKey bodyKey;
}

class ReportMetric {
  const ReportMetric({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.value,
    this.valueKey,
    this.unitKey,
    required this.statusKey,
    required this.deltaKey,
    required this.direction,
    required this.sparkline,
  });

  final IconData icon;
  final Color color;
  final ReportCopyKey titleKey;
  final String value;
  final ReportCopyKey? valueKey;
  final ReportCopyKey? unitKey;
  final ReportCopyKey statusKey;
  final ReportCopyKey deltaKey;
  final ReportMetricDirection direction;
  final List<double> sparkline;
}

enum ReportMetricDirection { up, down, flat }

class ReportTrendSeries {
  const ReportTrendSeries({
    required this.labelKey,
    required this.color,
    required this.values,
    required this.currentValue,
  });

  final ReportCopyKey labelKey;
  final Color color;
  final List<double> values;
  final String currentValue;
}

class ReportFinding {
  const ReportFinding({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.bodyKey,
  });

  final IconData icon;
  final Color color;
  final ReportCopyKey titleKey;
  final ReportCopyKey bodyKey;
}

class ReportAiBullet {
  const ReportAiBullet({required this.color, required this.bodyKey});

  final Color color;
  final ReportCopyKey bodyKey;
}

class ReportExportAction {
  const ReportExportAction({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.subtitleKey,
  });

  final IconData icon;
  final Color color;
  final ReportCopyKey titleKey;
  final ReportCopyKey subtitleKey;
}

class ReportPatternCard {
  const ReportPatternCard({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.statusKey,
    required this.bodyKey,
    required this.sparkline,
  });

  final IconData icon;
  final Color color;
  final ReportCopyKey titleKey;
  final ReportCopyKey statusKey;
  final ReportCopyKey bodyKey;
  final List<double> sparkline;
}

class ReportPrivacyAction {
  const ReportPrivacyAction({
    required this.icon,
    required this.color,
    required this.titleKey,
  });

  final IconData icon;
  final Color color;
  final ReportCopyKey titleKey;
}

enum ReportCopyKey {
  statusOverallStable,
  scoreBody,
  metricMedicationTitle,
  metricSleepTitle,
  metricWaterTitle,
  unitPercent,
  unitHour,
  unitLiter,
  statusGood,
  statusNeedsImprove,
  statusStable,
  deltaMedication,
  deltaSleep,
  deltaWater,
  trendSleepLabel,
  trendWaterLabel,
  trendMedicationLabel,
  findingCoffeeTitle,
  findingCoffeeBody,
  findingMedicineTitle,
  findingMedicineBody,
  aiBulletSleep,
  aiBulletWater,
  aiBulletMedicine,
  aiBulletDiet,
  exportHospitalTitle,
  exportHospitalSubtitle,
  exportMonthlyTitle,
  exportMonthlySubtitle,
  exportPrintTitle,
  exportPrintSubtitle,
  patternSleepTitle,
  patternSleepStatus,
  patternSleepBody,
  patternDietWaterTitle,
  patternDietWaterStatus,
  patternDietWaterBody,
  patternMedicationTitle,
  patternMedicationStatus,
  patternMedicationBody,
  privacyExportControls,
}

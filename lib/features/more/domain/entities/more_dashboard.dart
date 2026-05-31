import 'package:flutter/material.dart';

class MoreDashboard {
  const MoreDashboard({
    required this.emergencyTools,
    required this.familyTools,
    required this.aiTools,
    required this.deviceTools,
    required this.knowledgeTools,
    required this.environment,
    required this.recentItems,
    required this.quickEntries,
    required this.careNoteBodyKey,
  });

  final List<MoreToolItem> emergencyTools;
  final List<MoreToolItem> familyTools;
  final List<MoreToolItem> aiTools;
  final List<MoreToolItem> deviceTools;
  final List<MoreToolItem> knowledgeTools;
  final MoreEnvironmentSnapshot environment;
  final List<MoreRecentItem> recentItems;
  final List<MoreToolItem> quickEntries;
  final MoreCopyKey careNoteBodyKey;
}

class MoreToolItem {
  const MoreToolItem({
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.titleKey,
    required this.subtitleKey,
  });

  final IconData icon;
  final Color accent;
  final Color softColor;
  final MoreCopyKey titleKey;
  final MoreCopyKey subtitleKey;
}

class MoreEnvironmentSnapshot {
  const MoreEnvironmentSnapshot({
    required this.metrics,
    required this.adviceCard,
  });

  final List<MoreEnvironmentMetric> metrics;
  final MoreInfoCard adviceCard;
}

class MoreEnvironmentMetric {
  const MoreEnvironmentMetric({
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.titleKey,
    required this.valueKey,
    required this.valueColor,
  });

  final IconData icon;
  final Color accent;
  final Color softColor;
  final MoreCopyKey titleKey;
  final MoreCopyKey valueKey;
  final Color valueColor;
}

class MoreRecentItem {
  const MoreRecentItem({
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.titleKey,
    required this.timeKey,
  });

  final IconData icon;
  final Color accent;
  final Color softColor;
  final MoreCopyKey titleKey;
  final MoreCopyKey timeKey;
}

class MoreInfoCard {
  const MoreInfoCard({
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.titleKey,
    required this.bodyKey,
    this.actionKey,
  });

  final IconData icon;
  final Color accent;
  final Color softColor;
  final MoreCopyKey titleKey;
  final MoreCopyKey bodyKey;
  final MoreCopyKey? actionKey;
}

enum MoreCopyKey {
  emergencySosTitle,
  emergencySosSubtitle,
  emergencyMentalHotlineTitle,
  emergencyMentalHotlineSubtitle,
  emergencyLockscreenTitle,
  emergencyLockscreenSubtitle,
  familyProfilesTitle,
  familyProfilesSubtitle,
  familyVaccinationTitle,
  familyVaccinationSubtitle,
  familyAlertTitle,
  familyAlertSubtitle,
  aiSkinTitle,
  aiSkinSubtitle,
  aiMentalScaleTitle,
  aiMentalScaleSubtitle,
  aiReportImportTitle,
  aiReportImportSubtitle,
  deviceMineTitle,
  deviceMineSubtitle,
  deviceAddTitle,
  deviceAddSubtitle,
  deviceSyncTitle,
  deviceSyncSubtitle,
  knowledgeSleepTitle,
  knowledgeSleepSubtitle,
  knowledgeMindfulnessTitle,
  knowledgeMindfulnessSubtitle,
  knowledgeWomenTitle,
  knowledgeWomenSubtitle,
  environmentPollenTitle,
  environmentPollenValue,
  environmentUvTitle,
  environmentUvValue,
  environmentAirTitle,
  environmentAirValue,
  environmentAdviceTitle,
  environmentAdviceBody,
  environmentAdviceAction,
  recentSkinTime,
  recentVaccinationTime,
  recentDeviceTime,
  recentHotlineTime,
  quickCalculatorTitle,
  quickCalculatorSubtitle,
  quickBarcodeTitle,
  quickBarcodeSubtitle,
  quickConverterTitle,
  quickConverterSubtitle,
  quickExportTitle,
  quickExportSubtitle,
  careNoteBody,
}

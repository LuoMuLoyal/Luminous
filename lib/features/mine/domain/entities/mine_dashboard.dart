import 'package:flutter/material.dart';

class MineDashboard {
  const MineDashboard({
    required this.account,
    required this.completion,
    required this.summary,
    required this.profileEntries,
    required this.planEntries,
    required this.reportCard,
    required this.privacyCard,
    required this.statusEntries,
    required this.onboardingEntries,
    required this.quickEntries,
    required this.settings,
  });

  final MineAccount account;
  final MineCompletion completion;
  final MineSummary summary;
  final List<MineProfileEntry> profileEntries;
  final List<MinePlanEntry> planEntries;
  final MineActionCard reportCard;
  final MineActionCard privacyCard;
  final List<MineStatusEntry> statusEntries;
  final List<MineOnboardingEntry> onboardingEntries;
  final List<MineQuickEntry> quickEntries;
  final List<MineSettingItem> settings;
}

class MineAccount {
  const MineAccount({
    required this.isAuthenticated,
    required this.displayNameKey,
    this.displayName,
    required this.email,
    required this.statusKey,
    required this.metaKey,
  });

  final bool isAuthenticated;
  final MineCopyKey displayNameKey;
  final String? displayName;
  final String email;
  final MineCopyKey statusKey;
  final MineCopyKey metaKey;
}

class MineCompletion {
  const MineCompletion({
    required this.progress,
    required this.percentLabel,
    required this.titleKey,
    required this.subtitleKey,
  });

  final double progress;
  final String percentLabel;
  final MineCopyKey titleKey;
  final MineCopyKey subtitleKey;
}

class MineSummary {
  const MineSummary({
    required this.updatedAtKey,
    required this.metrics,
    required this.missingInfoKey,
    required this.completeActionKey,
  });

  final MineCopyKey updatedAtKey;
  final List<MineSummaryMetric> metrics;
  final MineCopyKey missingInfoKey;
  final MineCopyKey completeActionKey;
}

class MineSummaryMetric {
  const MineSummaryMetric({
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.value,
    required this.titleKey,
  });

  final IconData icon;
  final Color accent;
  final Color softColor;
  final String value;
  final MineCopyKey titleKey;
}

class MineProfileEntry {
  const MineProfileEntry({
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.titleKey,
    required this.subtitleKey,
  });

  final IconData icon;
  final Color accent;
  final Color softColor;
  final MineCopyKey titleKey;
  final MineCopyKey subtitleKey;
}

class MinePlanEntry {
  const MinePlanEntry({
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.titleKey,
    required this.statusKey,
    required this.detailKey,
  });

  final IconData icon;
  final Color accent;
  final Color softColor;
  final MineCopyKey titleKey;
  final MineCopyKey statusKey;
  final MineCopyKey detailKey;
}

class MineActionCard {
  const MineActionCard({
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.titleKey,
    required this.bodyKey,
    required this.metaKey,
    required this.actionKey,
  });

  final IconData icon;
  final Color accent;
  final Color softColor;
  final MineCopyKey titleKey;
  final MineCopyKey bodyKey;
  final MineCopyKey metaKey;
  final MineCopyKey actionKey;
}

class MineStatusEntry {
  const MineStatusEntry({
    required this.titleKey,
    required this.valueKey,
    required this.color,
  });

  final MineCopyKey titleKey;
  final MineCopyKey valueKey;
  final Color color;
}

class MineOnboardingEntry {
  const MineOnboardingEntry({required this.titleKey, required this.completed});

  final MineCopyKey titleKey;
  final bool completed;
}

class MineQuickEntry {
  const MineQuickEntry({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
  });

  final IconData icon;
  final MineCopyKey titleKey;
  final MineCopyKey subtitleKey;
}

class MineSettingItem {
  const MineSettingItem({
    required this.icon,
    required this.titleKey,
    this.valueKey,
  });

  final IconData icon;
  final MineCopyKey titleKey;
  final MineCopyKey? valueKey;
}

enum MineCopyKey {
  accountDisplayName,
  accountGuestDisplayName,
  accountSignedIn,
  accountSignedOut,
  accountMeta,
  accountSignedOutMeta,
  signedOutNoticeTitle,
  signedOutNoticeDescription,
  completionTitle,
  completionSubtitle,
  summaryUpdatedAt,
  summaryAge,
  summaryAllergies,
  summaryConditions,
  summaryMedicines,
  summaryMissingInfo,
  summaryCompleteAction,
  profileBasicInfoTitle,
  profileBasicInfoSubtitle,
  profileAllergiesTitle,
  profileAllergiesSubtitle,
  profileConditionsTitle,
  profileConditionsSubtitle,
  profileMedicinesTitle,
  profileMedicinesSubtitle,
  profileWomenTitle,
  profileWomenSubtitle,
  profileSpecialistTitle,
  profileSpecialistSubtitle,
  profileLifestyleTitle,
  profileLifestyleSubtitle,
  profileFamilyTitle,
  profileFamilySubtitle,
  planBloodSugarTitle,
  planBloodSugarStatus,
  planBloodSugarDetail,
  planWeightTitle,
  planWeightStatus,
  planWeightDetail,
  planSleepTitle,
  planSleepStatus,
  planSleepDetail,
  planMoodTitle,
  planMoodStatus,
  planMoodDetail,
  planPregnancyTitle,
  planPregnancyStatus,
  planPregnancyDetail,
  reportTitle,
  reportBody,
  reportMeta,
  reportAction,
  privacyTitle,
  privacyBody,
  privacyMeta,
  privacyAction,
  statusBasicTitle,
  statusBasicValue,
  statusAllergiesTitle,
  statusAllergiesValue,
  statusConditionsTitle,
  statusConditionsValue,
  statusMedicinesTitle,
  statusMedicinesValue,
  statusWomenTitle,
  statusWomenValue,
  onboardingBasicTitle,
  onboardingContextTitle,
  onboardingMedicineTitle,
  onboardingGoalTitle,
  onboardingPrivacyTitle,
  quickExportTitle,
  quickExportSubtitle,
  quickDoctorTitle,
  quickDoctorSubtitle,
  quickEmergencyTitle,
  quickEmergencySubtitle,
  settingsThemeTitle,
  settingsThemeValue,
  settingsAccountTitle,
  settingsLanguageTitle,
  settingsLanguageValue,
  settingsNotificationsTitle,
  settingsMoreTitle,
}

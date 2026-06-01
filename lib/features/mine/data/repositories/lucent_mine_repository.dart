// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/mine_repository.dart';

/// Lucent-backed [MineRepository] that merges real health-context data with
/// static mock data for fields the backend does not yet provide.
class LucentMineRepository implements MineRepository {
  LucentMineRepository({required Ref ref}) : _ref = ref;

  final Ref _ref;

  @override
  Future<MineDashboard> fetchDashboard() async {
    final snapshot =
        await _ref.watch(healthContextSnapshotProvider.future);

    return MineDashboard(
      account: _buildAccount(snapshot),
      completion: _staticCompletion,
      summary: _buildSummary(snapshot),
      profileEntries: _buildProfileEntries(snapshot),
      planEntries: _staticPlanEntries,
      reportCard: _staticReportCard,
      privacyCard: _staticPrivacyCard,
      statusEntries: _buildStatusEntries(snapshot),
      onboardingEntries: _buildOnboardingEntries(snapshot),
      quickEntries: _staticQuickEntries,
      settings: _staticSettings,
    );
  }

  MineAccount _buildAccount(HealthContextSnapshot snapshot) {
    return const MineAccount(
      isAuthenticated: true,
      displayNameKey: MineCopyKey.accountDisplayName,
      email: '',
      statusKey: MineCopyKey.accountSignedIn,
      metaKey: MineCopyKey.accountMeta,
    );
  }

  MineSummary _buildSummary(HealthContextSnapshot snapshot) {
    final s = snapshot.summary;
    return MineSummary(
      updatedAtKey: MineCopyKey.summaryUpdatedAt,
      metrics: [
        MineSummaryMetric(
          icon: Icons.person_outline_rounded,
          accent: _blue,
          softColor: _blueSoft,
          value: s.age?.toString() ?? '--',
          titleKey: MineCopyKey.summaryAge,
        ),
        MineSummaryMetric(
          icon: Icons.accessibility_new_rounded,
          accent: _green,
          softColor: _greenSoft,
          value: s.activeAllergyCount.toString(),
          titleKey: MineCopyKey.summaryAllergies,
        ),
        MineSummaryMetric(
          icon: Icons.favorite_border_rounded,
          accent: _orange,
          softColor: _orangeSoft,
          value: s.conditionCount.toString(),
          titleKey: MineCopyKey.summaryConditions,
        ),
        MineSummaryMetric(
          icon: Icons.medication_outlined,
          accent: _link,
          softColor: _linkSoft,
          value: s.currentMedicineCount.toString(),
          titleKey: MineCopyKey.summaryMedicines,
        ),
      ],
      missingInfoKey: MineCopyKey.summaryMissingInfo,
      completeActionKey: MineCopyKey.summaryCompleteAction,
    );
  }

  List<MineProfileEntry> _buildProfileEntries(HealthContextSnapshot snapshot) {
    return const [
      MineProfileEntry(
        icon: Icons.person_outline_rounded,
        accent: _green,
        softColor: _greenSoft,
        titleKey: MineCopyKey.profileBasicInfoTitle,
        subtitleKey: MineCopyKey.profileBasicInfoSubtitle,
      ),
      MineProfileEntry(
        icon: Icons.accessibility_new_rounded,
        accent: _green,
        softColor: _greenSoft,
        titleKey: MineCopyKey.profileAllergiesTitle,
        subtitleKey: MineCopyKey.profileAllergiesSubtitle,
      ),
      MineProfileEntry(
        icon: Icons.favorite_border_rounded,
        accent: _orange,
        softColor: _orangeSoft,
        titleKey: MineCopyKey.profileConditionsTitle,
        subtitleKey: MineCopyKey.profileConditionsSubtitle,
      ),
      MineProfileEntry(
        icon: Icons.medication_outlined,
        accent: _link,
        softColor: _linkSoft,
        titleKey: MineCopyKey.profileMedicinesTitle,
        subtitleKey: MineCopyKey.profileMedicinesSubtitle,
      ),
      MineProfileEntry(
        icon: Icons.woman_rounded,
        accent: _pink,
        softColor: _pinkSoft,
        titleKey: MineCopyKey.profileWomenTitle,
        subtitleKey: MineCopyKey.profileWomenSubtitle,
      ),
      MineProfileEntry(
        icon: Icons.folder_outlined,
        accent: _teal,
        softColor: _tealSoft,
        titleKey: MineCopyKey.profileSpecialistTitle,
        subtitleKey: MineCopyKey.profileSpecialistSubtitle,
      ),
      MineProfileEntry(
        icon: Icons.delete_outline_rounded,
        accent: _link,
        softColor: _linkSoft,
        titleKey: MineCopyKey.profileLifestyleTitle,
        subtitleKey: MineCopyKey.profileLifestyleSubtitle,
      ),
      MineProfileEntry(
        icon: Icons.people_outline_rounded,
        accent: _purple,
        softColor: _purpleSoft,
        titleKey: MineCopyKey.profileFamilyTitle,
        subtitleKey: MineCopyKey.profileFamilySubtitle,
      ),
    ];
  }

  List<MineStatusEntry> _buildStatusEntries(HealthContextSnapshot snapshot) {
    final s = snapshot.summary;
    return [
      const MineStatusEntry(
        titleKey: MineCopyKey.statusBasicTitle,
        valueKey: MineCopyKey.statusBasicValue,
        color: _green,
      ),
      MineStatusEntry(
        titleKey: MineCopyKey.statusAllergiesTitle,
        valueKey: MineCopyKey.statusAllergiesValue,
        color: s.activeAllergyCount > 0 ? _green : _orange,
      ),
      MineStatusEntry(
        titleKey: MineCopyKey.statusConditionsTitle,
        valueKey: MineCopyKey.statusConditionsValue,
        color: s.conditionCount > 0 ? _green : _orange,
      ),
      MineStatusEntry(
        titleKey: MineCopyKey.statusMedicinesTitle,
        valueKey: MineCopyKey.statusMedicinesValue,
        color: s.currentMedicineCount > 0 ? _green : _orange,
      ),
      const MineStatusEntry(
        titleKey: MineCopyKey.statusWomenTitle,
        valueKey: MineCopyKey.statusWomenValue,
        color: _orange,
      ),
    ];
  }

  List<MineOnboardingEntry> _buildOnboardingEntries(
    HealthContextSnapshot snapshot,
  ) {
    final completed = snapshot.summary.onboardingCompleted;
    return [
      MineOnboardingEntry(
        titleKey: MineCopyKey.onboardingBasicTitle,
        completed: completed,
      ),
      MineOnboardingEntry(
        titleKey: MineCopyKey.onboardingContextTitle,
        completed: completed,
      ),
      MineOnboardingEntry(
        titleKey: MineCopyKey.onboardingMedicineTitle,
        completed: completed,
      ),
      MineOnboardingEntry(
        titleKey: MineCopyKey.onboardingGoalTitle,
        completed: completed,
      ),
      const MineOnboardingEntry(
        titleKey: MineCopyKey.onboardingPrivacyTitle,
        completed: false,
      ),
    ];
  }

  // --- static mock data for fields the backend does not yet provide ---

  static const _staticCompletion = MineCompletion(
    progress: 0.72,
    percentLabel: '72%',
    titleKey: MineCopyKey.completionTitle,
    subtitleKey: MineCopyKey.completionSubtitle,
  );

  static const _staticPlanEntries = [
    MinePlanEntry(
      icon: Icons.assignment_turned_in_outlined,
      accent: _green,
      softColor: _greenSoft,
      titleKey: MineCopyKey.planBloodSugarTitle,
      statusKey: MineCopyKey.planBloodSugarStatus,
      detailKey: MineCopyKey.planBloodSugarDetail,
    ),
    MinePlanEntry(
      icon: Icons.scale_outlined,
      accent: _link,
      softColor: _linkSoft,
      titleKey: MineCopyKey.planWeightTitle,
      statusKey: MineCopyKey.planWeightStatus,
      detailKey: MineCopyKey.planWeightDetail,
    ),
    MinePlanEntry(
      icon: Icons.dark_mode_outlined,
      accent: _purple,
      softColor: _purpleSoft,
      titleKey: MineCopyKey.planSleepTitle,
      statusKey: MineCopyKey.planSleepStatus,
      detailKey: MineCopyKey.planSleepDetail,
    ),
    MinePlanEntry(
      icon: Icons.mood_outlined,
      accent: _orange,
      softColor: _orangeSoft,
      titleKey: MineCopyKey.planMoodTitle,
      statusKey: MineCopyKey.planMoodStatus,
      detailKey: MineCopyKey.planMoodDetail,
    ),
    MinePlanEntry(
      icon: Icons.child_friendly_outlined,
      accent: _pink,
      softColor: _pinkSoft,
      titleKey: MineCopyKey.planPregnancyTitle,
      statusKey: MineCopyKey.planPregnancyStatus,
      detailKey: MineCopyKey.planPregnancyDetail,
    ),
  ];

  static const _staticReportCard = MineActionCard(
    icon: Icons.description_outlined,
    accent: _link,
    softColor: _linkSoft,
    titleKey: MineCopyKey.reportTitle,
    bodyKey: MineCopyKey.reportBody,
    metaKey: MineCopyKey.reportMeta,
    actionKey: MineCopyKey.reportAction,
  );

  static const _staticPrivacyCard = MineActionCard(
    icon: Icons.shield_outlined,
    accent: _green,
    softColor: _greenSoft,
    titleKey: MineCopyKey.privacyTitle,
    bodyKey: MineCopyKey.privacyBody,
    metaKey: MineCopyKey.privacyMeta,
    actionKey: MineCopyKey.privacyAction,
  );

  static const _staticQuickEntries = [
    MineQuickEntry(
      icon: Icons.upload_file_outlined,
      titleKey: MineCopyKey.quickExportTitle,
      subtitleKey: MineCopyKey.quickExportSubtitle,
    ),
    MineQuickEntry(
      icon: Icons.person_search_outlined,
      titleKey: MineCopyKey.quickDoctorTitle,
      subtitleKey: MineCopyKey.quickDoctorSubtitle,
    ),
    MineQuickEntry(
      icon: Icons.warning_amber_rounded,
      titleKey: MineCopyKey.quickEmergencyTitle,
      subtitleKey: MineCopyKey.quickEmergencySubtitle,
    ),
  ];

  static const _staticSettings = [
    MineSettingItem(
      icon: Icons.dark_mode_outlined,
      titleKey: MineCopyKey.settingsThemeTitle,
      valueKey: MineCopyKey.settingsThemeValue,
    ),
    MineSettingItem(
      icon: Icons.verified_user_outlined,
      titleKey: MineCopyKey.settingsAccountTitle,
    ),
    MineSettingItem(
      icon: Icons.language_outlined,
      titleKey: MineCopyKey.settingsLanguageTitle,
      valueKey: MineCopyKey.settingsLanguageValue,
    ),
    MineSettingItem(
      icon: Icons.notifications_none_rounded,
      titleKey: MineCopyKey.settingsNotificationsTitle,
    ),
    MineSettingItem(
      icon: Icons.tune_rounded,
      titleKey: MineCopyKey.settingsMoreTitle,
    ),
  ];

  static const _green = Color(0xFF159B55);
  static const _greenSoft = Color(0xFFEAF8EE);
  static const _blue = Color(0xFF428BFF);
  static const _blueSoft = Color(0xFFEFF5FF);
  static const _orange = Color(0xFFFF8A00);
  static const _orangeSoft = Color(0xFFFFF3E6);
  static const _pink = Color(0xFFFF6F91);
  static const _pinkSoft = Color(0xFFFFEEF3);
  static const _purple = Color(0xFF8B5CF6);
  static const _purpleSoft = Color(0xFFF1EAFF);
  static const _teal = Color(0xFF2FBF8C);
  static const _tealSoft = Color(0xFFE9FAF4);
  static const _link = AppColorTokens.link;
  static const _linkSoft = AppColorTokens.linkSoft;
}

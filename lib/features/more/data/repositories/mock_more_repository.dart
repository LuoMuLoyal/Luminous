import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/more/domain/entities/more_dashboard.dart';
import 'package:luminous/features/more/domain/repositories/more_repository.dart';

class MockMoreRepository implements MoreRepository {
  const MockMoreRepository();

  @override
  Future<MoreDashboard> fetchDashboard() async {
    return dashboard;
  }

  static const dashboard = MoreDashboard(
    emergencyTools: <MoreToolItem>[
      MoreToolItem(
        icon: Icons.sos_rounded,
        accent: _red,
        softColor: _redSoft,
        titleKey: MoreCopyKey.emergencySosTitle,
        subtitleKey: MoreCopyKey.emergencySosSubtitle,
      ),
      MoreToolItem(
        icon: Icons.favorite_rounded,
        accent: _pink,
        softColor: _pinkSoft,
        titleKey: MoreCopyKey.emergencyMentalHotlineTitle,
        subtitleKey: MoreCopyKey.emergencyMentalHotlineSubtitle,
      ),
      MoreToolItem(
        icon: Icons.medical_information_outlined,
        accent: _orange,
        softColor: _orangeSoft,
        titleKey: MoreCopyKey.emergencyLockscreenTitle,
        subtitleKey: MoreCopyKey.emergencyLockscreenSubtitle,
      ),
    ],
    familyTools: <MoreToolItem>[
      MoreToolItem(
        icon: Icons.groups_2_outlined,
        accent: _green,
        softColor: _greenSoft,
        titleKey: MoreCopyKey.familyProfilesTitle,
        subtitleKey: MoreCopyKey.familyProfilesSubtitle,
      ),
      MoreToolItem(
        icon: Icons.shield_outlined,
        accent: _green,
        softColor: _greenSoft,
        titleKey: MoreCopyKey.familyVaccinationTitle,
        subtitleKey: MoreCopyKey.familyVaccinationSubtitle,
      ),
      MoreToolItem(
        icon: Icons.notification_important_outlined,
        accent: _orange,
        softColor: _orangeSoft,
        titleKey: MoreCopyKey.familyAlertTitle,
        subtitleKey: MoreCopyKey.familyAlertSubtitle,
      ),
    ],
    aiTools: <MoreToolItem>[
      MoreToolItem(
        icon: Icons.camera_alt_outlined,
        accent: _green,
        softColor: _greenSoft,
        titleKey: MoreCopyKey.aiSkinTitle,
        subtitleKey: MoreCopyKey.aiSkinSubtitle,
      ),
      MoreToolItem(
        icon: Icons.mood_outlined,
        accent: _purple,
        softColor: _purpleSoft,
        titleKey: MoreCopyKey.aiMentalScaleTitle,
        subtitleKey: MoreCopyKey.aiMentalScaleSubtitle,
      ),
      MoreToolItem(
        icon: Icons.description_outlined,
        accent: _blue,
        softColor: _blueSoft,
        titleKey: MoreCopyKey.aiReportImportTitle,
        subtitleKey: MoreCopyKey.aiReportImportSubtitle,
      ),
    ],
    deviceTools: <MoreToolItem>[
      MoreToolItem(
        icon: Icons.watch_outlined,
        accent: _blue,
        softColor: _blueSoft,
        titleKey: MoreCopyKey.deviceMineTitle,
        subtitleKey: MoreCopyKey.deviceMineSubtitle,
      ),
      MoreToolItem(
        icon: Icons.add_circle_outline_rounded,
        accent: _blue,
        softColor: _blueSoft,
        titleKey: MoreCopyKey.deviceAddTitle,
        subtitleKey: MoreCopyKey.deviceAddSubtitle,
      ),
      MoreToolItem(
        icon: Icons.sync_rounded,
        accent: _blue,
        softColor: _blueSoft,
        titleKey: MoreCopyKey.deviceSyncTitle,
        subtitleKey: MoreCopyKey.deviceSyncSubtitle,
      ),
    ],
    knowledgeTools: <MoreToolItem>[
      MoreToolItem(
        icon: Icons.nightlight_round,
        accent: _green,
        softColor: _greenSoft,
        titleKey: MoreCopyKey.knowledgeSleepTitle,
        subtitleKey: MoreCopyKey.knowledgeSleepSubtitle,
      ),
      MoreToolItem(
        icon: Icons.self_improvement_rounded,
        accent: _orange,
        softColor: _orangeSoft,
        titleKey: MoreCopyKey.knowledgeMindfulnessTitle,
        subtitleKey: MoreCopyKey.knowledgeMindfulnessSubtitle,
      ),
      MoreToolItem(
        icon: Icons.wc_outlined,
        accent: _pink,
        softColor: _pinkSoft,
        titleKey: MoreCopyKey.knowledgeWomenTitle,
        subtitleKey: MoreCopyKey.knowledgeWomenSubtitle,
      ),
    ],
    environment: MoreEnvironmentSnapshot(
      metrics: <MoreEnvironmentMetric>[
        MoreEnvironmentMetric(
          icon: Icons.spa_outlined,
          accent: _green,
          softColor: _greenSoft,
          titleKey: MoreCopyKey.environmentPollenTitle,
          valueKey: MoreCopyKey.environmentPollenValue,
          valueColor: _orange,
        ),
        MoreEnvironmentMetric(
          icon: Icons.wb_sunny_outlined,
          accent: _orange,
          softColor: _orangeSoft,
          titleKey: MoreCopyKey.environmentUvTitle,
          valueKey: MoreCopyKey.environmentUvValue,
          valueColor: _orange,
        ),
        MoreEnvironmentMetric(
          icon: Icons.cloud_outlined,
          accent: _blue,
          softColor: _blueSoft,
          titleKey: MoreCopyKey.environmentAirTitle,
          valueKey: MoreCopyKey.environmentAirValue,
          valueColor: _green,
        ),
      ],
      adviceCard: MoreInfoCard(
        icon: Icons.verified_user_outlined,
        accent: _purple,
        softColor: _purpleSoft,
        titleKey: MoreCopyKey.environmentAdviceTitle,
        bodyKey: MoreCopyKey.environmentAdviceBody,
        actionKey: MoreCopyKey.environmentAdviceAction,
      ),
    ),
    recentItems: <MoreRecentItem>[
      MoreRecentItem(
        icon: Icons.camera_alt_outlined,
        accent: _green,
        softColor: _greenSoft,
        titleKey: MoreCopyKey.aiSkinTitle,
        timeKey: MoreCopyKey.recentSkinTime,
      ),
      MoreRecentItem(
        icon: Icons.shield_outlined,
        accent: _green,
        softColor: _greenSoft,
        titleKey: MoreCopyKey.familyVaccinationTitle,
        timeKey: MoreCopyKey.recentVaccinationTime,
      ),
      MoreRecentItem(
        icon: Icons.watch_outlined,
        accent: _blue,
        softColor: _blueSoft,
        titleKey: MoreCopyKey.deviceMineTitle,
        timeKey: MoreCopyKey.recentDeviceTime,
      ),
      MoreRecentItem(
        icon: Icons.favorite_rounded,
        accent: _pink,
        softColor: _pinkSoft,
        titleKey: MoreCopyKey.emergencyMentalHotlineTitle,
        timeKey: MoreCopyKey.recentHotlineTime,
      ),
    ],
    quickEntries: <MoreToolItem>[
      MoreToolItem(
        icon: Icons.calculate_outlined,
        accent: _blue,
        softColor: _blueSoft,
        titleKey: MoreCopyKey.quickCalculatorTitle,
        subtitleKey: MoreCopyKey.quickCalculatorSubtitle,
      ),
      MoreToolItem(
        icon: Icons.qr_code_scanner_rounded,
        accent: _green,
        softColor: _greenSoft,
        titleKey: MoreCopyKey.quickBarcodeTitle,
        subtitleKey: MoreCopyKey.quickBarcodeSubtitle,
      ),
      MoreToolItem(
        icon: Icons.straighten_outlined,
        accent: _purple,
        softColor: _purpleSoft,
        titleKey: MoreCopyKey.quickConverterTitle,
        subtitleKey: MoreCopyKey.quickConverterSubtitle,
      ),
      MoreToolItem(
        icon: Icons.file_upload_outlined,
        accent: _orange,
        softColor: _orangeSoft,
        titleKey: MoreCopyKey.quickExportTitle,
        subtitleKey: MoreCopyKey.quickExportSubtitle,
      ),
    ],
    careNoteBodyKey: MoreCopyKey.careNoteBody,
  );

  static const _green = Color(0xFF159B55);
  static const _greenSoft = Color(0xFFEAF8EE);
  static const _blue = Color(0xFF2F74FF);
  static const _blueSoft = Color(0xFFEFF5FF);
  static const _orange = Color(0xFFFF9800);
  static const _orangeSoft = Color(0xFFFFF4E6);
  static const _pink = Color(0xFFFF6F91);
  static const _pinkSoft = Color(0xFFFFEEF3);
  static const _purple = Color(0xFF8B5CF6);
  static const _purpleSoft = Color(0xFFF1EAFF);
  static const _red = Color(0xFFFF5A5F);
  static const _redSoft = Color(0xFFFFECEE);
}

final moreRepositoryProvider = Provider<MoreRepository>((ref) {
  return const MockMoreRepository();
});

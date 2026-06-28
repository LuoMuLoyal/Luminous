import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/mine/data/repositories/lucent_mine_repository.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/mine_repository.dart';

/// Demo-only mock implementation of [MineRepository] used for tests.
///
/// Account/profile values are intentionally placeholder so they cannot be
/// mistaken for real user data.
class MockMineRepository implements MineRepository {
  const MockMineRepository();

  static MineDashboard get signedOutDashboard {
    return buildDashboard(
      account: const MineAccount(
        isAuthenticated: false,
        displayNameKey: MineCopyKey.accountGuestDisplayName,
        displayName: null,
        email: '',
        statusKey: MineCopyKey.accountSignedOut,
        roleKey: MineCopyKey.accountStudentRole,
      ),
      profile: _guestProfile,
      completion: const MineCompletion(
        progress: 0,
        percentLabel: '0%',
        titleKey: MineCopyKey.completionTitle,
      ),
      alerts: _mockAlerts,
      archiveEntries: _mockArchiveEntries,
    );
  }

  @override
  Future<MineDashboard> fetchDashboard() async {
    return buildDashboard(
      account: MineAccount(
        isAuthenticated: true,
        displayNameKey: MineCopyKey.accountDisplayName,
        displayName: '[DEMO] User',
        email: 'demo@example.com',
        statusKey: MineCopyKey.accountSignedIn,
        roleKey: MineCopyKey.accountStudentRole,
        emailVerified: true,
        hasPassword: true,
        linkedIdentityCount: 1,
        lastLoginAt: DateTime.utc(2099, 1, 1, 0, 0),
      ),
      profile: _mockProfile,
      completion: const MineCompletion(
        progress: 0.82,
        percentLabel: '82%',
        titleKey: MineCopyKey.completionTitle,
      ),
      alerts: _mockAlerts,
      archiveEntries: _mockArchiveEntries,
    );
  }

  static const _guestProfile = MineProfileSnapshot(
    age: null,
    heightCm: null,
    allergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    basicInfoCompleted: false,
  );

  static const _mockProfile = MineProfileSnapshot(
    age: 20,
    heightCm: 165,
    allergyCount: 2,
    conditionCount: 0,
    currentMedicineCount: 2,
    basicInfoCompleted: true,
  );

  static const _mockAlerts = [
    MineStatusCard(
      icon: Icons.warning_rounded,
      accent: AppColorTokens.gradientShipStart,
      titleKey: MineCopyKey.alertAllergyTitle,
      subtitleKey: MineCopyKey.alertAllergySubtitle,
      badgeKey: MineCopyKey.alertAllergyBadge,
    ),
    MineStatusCard(
      icon: Icons.medication_rounded,
      accent: AppColorTokens.link,
      titleKey: MineCopyKey.alertMedicineTitle,
      subtitleKey: MineCopyKey.alertMedicineSubtitle,
      badgeKey: MineCopyKey.alertMedicineBadge,
    ),
    MineStatusCard(
      icon: Icons.verified_user_rounded,
      accent: AppColorTokens.cyanDeep,
      titleKey: MineCopyKey.alertPrivacyTitle,
      subtitleKey: MineCopyKey.alertPrivacySubtitle,
      badgeKey: MineCopyKey.alertPrivacyBadge,
    ),
  ];

  static const _mockArchiveEntries = [
    MineArchiveEntry(
      icon: Icons.badge_rounded,
      accent: AppColorTokens.cyanDeep,
      titleKey: MineCopyKey.archiveBasicTitle,
      subtitleKey: MineCopyKey.archiveBasicSubtitle,
      statusKey: MineCopyKey.archiveCompleted,
      route: '/mine/profile/edit',
    ),
    MineArchiveEntry(
      icon: Icons.water_drop_rounded,
      accent: AppColorTokens.highlightMagenta,
      titleKey: MineCopyKey.archiveAllergyTitle,
      subtitleKey: MineCopyKey.archiveAllergySubtitle,
      statusKey: MineCopyKey.archiveCompleted,
      route: '/mine/allergy/new',
    ),
    MineArchiveEntry(
      icon: Icons.medication_rounded,
      accent: AppColorTokens.link,
      titleKey: MineCopyKey.archiveMedicineTitle,
      subtitleKey: MineCopyKey.archiveMedicineSubtitle,
      route: '/mine/medicine/new',
    ),
    MineArchiveEntry(
      icon: Icons.contact_emergency_rounded,
      accent: AppColorTokens.warning,
      titleKey: MineCopyKey.archiveEmergencyTitle,
      subtitleKey: MineCopyKey.archiveEmergencySubtitle,
      statusKey: MineCopyKey.archiveNeedsFill,
    ),
  ];
}

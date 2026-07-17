import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/mine/data/repositories/lucent.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/profile.dart';

/// Test-only mock implementation of [MineRepository].
class MockMineRepository implements MineRepository {
  const MockMineRepository();

  @override
  Future<MineDashboard> get signedOutDashboard =>
      Future.value(_signedOutDashboard);

  static MineDashboard get _signedOutDashboard {
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

  static final _mockAlerts = [
    const MineStatusCard(
      icon: FLucideIcons.triangleAlert,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.alertAllergyTitle,
      subtitleKey: MineCopyKey.alertAllergySubtitle,
      badgeKey: MineCopyKey.alertAllergyBadge,
    ),
    const MineStatusCard(
      icon: FLucideIcons.pill,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.alertMedicineTitle,
      subtitleKey: MineCopyKey.alertMedicineSubtitle,
      badgeKey: MineCopyKey.alertMedicineBadge,
    ),
    const MineStatusCard(
      icon: FLucideIcons.userCheck,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.alertPrivacyTitle,
      subtitleKey: MineCopyKey.alertPrivacySubtitle,
      badgeKey: MineCopyKey.alertPrivacyBadge,
    ),
  ];

  static final _mockArchiveEntries = [
    const MineArchiveEntry(
      icon: FLucideIcons.badge,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.archiveBasicTitle,
      subtitleKey: MineCopyKey.archiveBasicSubtitle,
      statusKey: MineCopyKey.archiveCompleted,
      route: '/mine/profile/edit',
    ),
    const MineArchiveEntry(
      icon: FLucideIcons.droplets,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.archiveAllergyTitle,
      subtitleKey: MineCopyKey.archiveAllergySubtitle,
      statusKey: MineCopyKey.archiveCompleted,
      route: '/mine/allergy/new',
    ),
    const MineArchiveEntry(
      icon: FLucideIcons.pill,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.archiveMedicineTitle,
      subtitleKey: MineCopyKey.archiveMedicineSubtitle,
      route: AppRoutes.mineMedicineNew,
    ),
    const MineArchiveEntry(
      icon: FLucideIcons.contact,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.archiveEmergencyTitle,
      subtitleKey: MineCopyKey.archiveEmergencySubtitle,
      statusKey: MineCopyKey.archiveNeedsFill,
    ),
  ];
}

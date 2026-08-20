import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
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
    weightKg: null,
    sexAtBirth: null,
    unitSystem: null,
    allergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    basicInfoCompleted: false,
  );

  static const _mockProfile = MineProfileSnapshot(
    age: 20,
    heightCm: 165,
    weightKg: 55,
    sexAtBirth: 'female',
    unitSystem: null,
    allergyCount: 2,
    conditionCount: 0,
    currentMedicineCount: 2,
    basicInfoCompleted: true,
  );

  static final _mockAlerts = [
    const MineStatusCard(
      icon: SemanticIcons.statusWarning,
      accent: SemanticColor.destructive,
      titleKey: MineCopyKey.alertAllergyTitle,
      kind: MineStatusCardKind.allergy,
      items: ['花粉', '青霉素'],
      count: 2,
    ),
    const MineStatusCard(
      icon: SemanticIcons.recordMedicine,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.alertMedicineTitle,
      kind: MineStatusCardKind.medicine,
      items: ['布洛芬', '阿莫西林'],
      count: 2,
    ),
    const MineStatusCard(
      icon: SemanticIcons.profileUser,
      accent: SemanticColor.neutral,
      titleKey: MineCopyKey.alertPrivacyTitle,
      kind: MineStatusCardKind.privacy,
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
      icon: SemanticIcons.recordWater,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.archiveAllergyTitle,
      subtitleKey: MineCopyKey.archiveAllergySubtitle,
      statusKey: MineCopyKey.archiveCompleted,
      route: '/mine/allergy/new',
    ),
    const MineArchiveEntry(
      icon: SemanticIcons.recordMedicine,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.archiveMedicineTitle,
      subtitleKey: MineCopyKey.archiveMedicineSubtitle,
      route: Routes.mineMedicineNew,
    ),
    const MineArchiveEntry(
      icon: SemanticIcons.profileContact,
      accent: SemanticColor.primary,
      titleKey: MineCopyKey.archiveEmergencyTitle,
      subtitleKey: MineCopyKey.archiveEmergencySubtitle,
      statusKey: MineCopyKey.archiveNeedsFill,
    ),
  ];
}

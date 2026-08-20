import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/profile.dart';

/// Lucent-backed aggregate [MineRepository].
///
/// This repository intentionally has no dedicated datasource/mappers. It
/// composes the Mine dashboard from existing data sources:
/// - user profile / health archive / current medicines / allergies / conditions
///   come from [healthContextSnapshotProvider].
///
/// Mine is therefore a presentation-facing aggregation layer rather than a
/// standalone data owner.
class LucentMineRepository implements MineRepository {
  LucentMineRepository(this._ref);

  final Ref _ref;

  @override
  Future<MineDashboard> fetchDashboard() async {
    final snapshot = await _ref.watch(healthContextSnapshotProvider.future);
    return buildDashboard(
      account: _buildAccount(),
      profile: _buildProfile(snapshot),
      completion: _buildCompletion(snapshot),
      alerts: _buildAlerts(snapshot),
      archiveEntries: _buildArchiveEntries(snapshot),
    );
  }

  MineAccount _buildAccount() {
    final currentUser = _ref.read(authSessionProvider).user;
    final nick = currentUser?.nickname?.trim();
    final displayName = nick != null && nick.isNotEmpty
        ? nick
        : currentUser?.email ?? currentUser?.id ?? '';

    return MineAccount(
      isAuthenticated: true,
      displayNameKey: MineCopyKey.accountDisplayName,
      displayName: displayName,
      email: currentUser?.email ?? '',
      statusKey: MineCopyKey.accountSignedIn,
      roleKey: MineCopyKey.accountStudentRole,
      emailVerified: currentUser?.emailVerified ?? false,
      hasPassword: currentUser?.hasPassword ?? false,
      linkedIdentityCount: currentUser?.linkedIdentities.length ?? 0,
      lastLoginAt: currentUser?.lastLoginAt,
    );
  }

  @override
  Future<MineDashboard> get signedOutDashboard =>
      Future.value(MineDashboard.signedOut());
}

MineDashboard buildDashboard({
  required MineAccount account,
  required MineProfileSnapshot profile,
  required MineCompletion completion,
  required List<MineStatusCard> alerts,
  required List<MineArchiveEntry> archiveEntries,
}) {
  return MineDashboard(
    account: account,
    completion: completion,
    profile: profile,
    alerts: alerts,
    archiveEntries: archiveEntries,
    privacyNotice: const MinePrivacyNotice(
      icon: SemanticIcons.safetyNeutral,
      titleKey: MineCopyKey.privacyNoticeTitle,
      actionKey: MineCopyKey.privacyNoticeAction,
    ),
  );
}

MineProfileSnapshot _buildProfile(HealthContextSnapshot snapshot) {
  final summary = snapshot.summary;
  final profile = snapshot.profile;
  final hasBasicInfo =
      profile.birthDate?.isNotEmpty == true &&
      profile.heightCm != null &&
      profile.sexAtBirth != null;

  return MineProfileSnapshot(
    age: summary.age,
    heightCm: profile.heightCm,
    weightKg: profile.weightKg,
    sexAtBirth: profile.sexAtBirth,
    allergyCount: summary.activeAllergyCount,
    conditionCount: summary.conditionCount,
    currentMedicineCount: summary.currentMedicineCount,
    basicInfoCompleted: hasBasicInfo,
  );
}

/// Builds the Mine completion from the real health-context snapshot.
///
/// 口径:完成度按「有用」而非「有值」计,共 6 项——过敏史 / 当前用药 / 出生日期
/// / 身高 / 生理性别 / 体重。`onboardingCompleted` 是引导流程状态字段,当前无
/// 任何写入方(无 onboarding 流程),暂不纳入完成度;待有真实引导流程写入方后
/// 再纳入(见 `plans/2026-08-16-remediation-decision-register.md` 与计划文件 C-1 处置清单)。
MineCompletion _buildCompletion(HealthContextSnapshot snapshot) {
  const total = 6;
  final completed =
      (snapshot.summary.activeAllergyCount > 0 ? 1 : 0) +
      (snapshot.summary.currentMedicineCount > 0 ? 1 : 0) +
      (snapshot.profile.birthDate?.isNotEmpty == true ? 1 : 0) +
      (snapshot.profile.heightCm != null ? 1 : 0) +
      (snapshot.profile.sexAtBirth != null ? 1 : 0) +
      (snapshot.profile.weightKg != null ? 1 : 0);
  final progress = (completed / total).clamp(0.0, 1.0);

  return MineCompletion(
    progress: progress,
    percentLabel: '${(progress * 100).round()}%',
    titleKey: MineCopyKey.completionTitle,
  );
}

List<MineStatusCard> _buildAlerts(HealthContextSnapshot snapshot) {
  return [
    const MineStatusCard(
      icon: SemanticIcons.statusWarning,
      accent: _red,
      titleKey: MineCopyKey.alertAllergyTitle,
      subtitleKey: MineCopyKey.alertAllergySubtitle,
      badgeKey: MineCopyKey.alertAllergyBadge,
    ),
    MineStatusCard(
      icon: SemanticIcons.recordMedicine,
      accent: _blue,
      titleKey: MineCopyKey.alertMedicineTitle,
      subtitleKey: MineCopyKey.alertMedicineSubtitle,
      badgeKey: snapshot.summary.currentMedicineCount > 0
          ? MineCopyKey.alertMedicineBadge
          : MineCopyKey.archiveNeedsFill,
    ),
    const MineStatusCard(
      icon: SemanticIcons.profileUser,
      accent: _green,
      titleKey: MineCopyKey.alertPrivacyTitle,
      subtitleKey: MineCopyKey.alertPrivacySubtitle,
      badgeKey: MineCopyKey.alertPrivacyBadge,
    ),
  ];
}

List<MineArchiveEntry> _buildArchiveEntries(HealthContextSnapshot snapshot) {
  final profile = _buildProfile(snapshot);

  return [
    MineArchiveEntry(
      icon: SemanticIcons.reportAdherence,
      accent: _green,
      titleKey: MineCopyKey.archiveBasicTitle,
      subtitleKey: MineCopyKey.archiveBasicSubtitle,
      statusKey: profile.basicInfoCompleted
          ? MineCopyKey.archiveCompleted
          : MineCopyKey.archiveNeedsFill,
      route: '/mine/profile/edit',
    ),
    MineArchiveEntry(
      icon: SemanticIcons.recordWater,
      accent: _pink,
      titleKey: MineCopyKey.archiveAllergyTitle,
      subtitleKey: MineCopyKey.archiveAllergySubtitle,
      statusKey: profile.allergyCount > 0
          ? MineCopyKey.archiveCompleted
          : MineCopyKey.archiveNeedsFill,
      route: Routes.mineAllergyNew,
    ),
    MineArchiveEntry(
      icon: SemanticIcons.profileCondition,
      accent: _red,
      titleKey: MineCopyKey.archiveConditionTitle,
      subtitleKey: MineCopyKey.archiveConditionSubtitle,
      statusKey: profile.conditionCount > 0
          ? MineCopyKey.archiveCompleted
          : MineCopyKey.archiveNeedsFill,
      route: Routes.mineConditionNew,
    ),
    MineArchiveEntry(
      icon: SemanticIcons.recordMedicine,
      accent: _blue,
      titleKey: MineCopyKey.archiveMedicineTitle,
      subtitleKey: MineCopyKey.archiveMedicineSubtitle,
      statusKey: profile.currentMedicineCount > 0
          ? MineCopyKey.archiveCompleted
          : MineCopyKey.archiveNeedsFill,
      route: Routes.mineMedicineNew,
    ),
  ];
}

const _green = SemanticColor.neutral;
const _pink = SemanticColor.neutral;
const _red = SemanticColor.destructive;
const _blue = SemanticColor.primary;

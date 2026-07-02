import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/mine_repository.dart';

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
    final displayName = currentUser?.nickname?.trim().isNotEmpty == true
        ? currentUser!.nickname!.trim()
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
      icon: Icons.shield_rounded,
      titleKey: MineCopyKey.privacyNoticeTitle,
      actionKey: MineCopyKey.privacyNoticeAction,
    ),
  );
}

MineProfileSnapshot _buildProfile(HealthContextSnapshot snapshot) {
  final summary = snapshot.summary;
  final profile = snapshot.profile;
  final hasBasicInfo =
      profile.birthDate?.isNotEmpty == true && profile.heightCm != null;
  // Deferred by Product_Vision MVP: keep pregnancy/lactation status because it
  // is useful for medication safety, but do not surface it as a standalone
  // women-health or period-management module.

  return MineProfileSnapshot(
    age: summary.age,
    heightCm: profile.heightCm,
    allergyCount: summary.activeAllergyCount,
    conditionCount: summary.conditionCount,
    currentMedicineCount: summary.currentMedicineCount,
    basicInfoCompleted: hasBasicInfo,
  );
}

MineCompletion _buildCompletion(HealthContextSnapshot snapshot) {
  final total = 5;
  final completed =
      (snapshot.summary.onboardingCompleted ? 1 : 0) +
      (snapshot.summary.activeAllergyCount > 0 ? 1 : 0) +
      (snapshot.summary.currentMedicineCount > 0 ? 1 : 0) +
      (snapshot.profile.birthDate?.isNotEmpty == true ? 1 : 0) +
      (snapshot.profile.heightCm != null ? 1 : 0);
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
      icon: Icons.warning_rounded,
      accent: _red,
      titleKey: MineCopyKey.alertAllergyTitle,
      subtitleKey: MineCopyKey.alertAllergySubtitle,
      badgeKey: MineCopyKey.alertAllergyBadge,
    ),
    MineStatusCard(
      icon: Icons.medication_rounded,
      accent: _blue,
      titleKey: MineCopyKey.alertMedicineTitle,
      subtitleKey: MineCopyKey.alertMedicineSubtitle,
      badgeKey: snapshot.summary.currentMedicineCount > 0
          ? MineCopyKey.alertMedicineBadge
          : MineCopyKey.archiveNeedsFill,
    ),
    const MineStatusCard(
      icon: Icons.verified_user_rounded,
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
      icon: Icons.badge_rounded,
      accent: _green,
      titleKey: MineCopyKey.archiveBasicTitle,
      subtitleKey: MineCopyKey.archiveBasicSubtitle,
      statusKey: profile.basicInfoCompleted
          ? MineCopyKey.archiveCompleted
          : MineCopyKey.archiveNeedsFill,
      route: '/mine/profile/edit',
    ),
    MineArchiveEntry(
      icon: Icons.water_drop_rounded,
      accent: _pink,
      titleKey: MineCopyKey.archiveAllergyTitle,
      subtitleKey: MineCopyKey.archiveAllergySubtitle,
      statusKey: profile.allergyCount > 0
          ? MineCopyKey.archiveCompleted
          : MineCopyKey.archiveNeedsFill,
      route: '/mine/allergy/new',
    ),
    const MineArchiveEntry(
      icon: Icons.medication_rounded,
      accent: _blue,
      titleKey: MineCopyKey.archiveMedicineTitle,
      subtitleKey: MineCopyKey.archiveMedicineSubtitle,
      route: '/mine/medicine/new',
    ),
  ];
}

const _green = Color(0xFF0F766E);
const _pink = Color(0xFFE11D48);
const _red = Color(0xFFDC2626);
const _blue = Color(0xFF16A34A);

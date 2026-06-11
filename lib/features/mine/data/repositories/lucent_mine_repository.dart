import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/settings/data/providers/support_resources_providers.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/mine_repository.dart';

/// Lucent-backed [MineRepository] that keeps account and health-context fields
/// real while campus services are fetched from
/// `GET /api/v1/public/support-resources?scope=campus`.
class LucentMineRepository implements MineRepository {
  LucentMineRepository(this._ref);

  final Ref _ref;

  @override
  Future<MineDashboard> fetchDashboard() async {
    final snapshot = await _ref.watch(healthContextSnapshotProvider.future);
    final campusServices = await _fetchCampusServices();
    return buildDashboard(
      account: _buildAccount(),
      profile: _buildProfile(snapshot),
      completion: _buildCompletion(snapshot),
      alerts: _buildAlerts(snapshot),
      archiveEntries: _buildArchiveEntries(snapshot),
      campusServices: campusServices,
    );
  }

  Future<List<MineActionEntry>> _fetchCampusServices() async {
    try {
      final resources =
          await _ref.watch(supportResourcesProvider('campus').future);
      return resources
          .where((r) => r.available)
          .map(_mapSupportResource)
          .toList();
    } catch (_) {
      return _fallbackCampusServices;
    }
  }

  MineActionEntry _mapSupportResource(SupportResourceDto resource) {
    final (titleKey, subtitleKey) = _parseCopyKey(resource.icon);
    return MineActionEntry(
      icon: _parseIcon(resource.icon),
      accent: _parseColor(resource.icon),
      titleKey: titleKey,
      subtitleKey: subtitleKey,
      rawTitle: resource.title,
      rawSubtitle: resource.subtitle,
      route: resource.actionType == SupportResourceActionType.internal
          ? resource.actionUrl
          : null,
    );
  }

  (MineCopyKey, MineCopyKey) _parseCopyKey(String? name) {
    return switch (name) {
      'favorite' || 'heart' || 'support' || 'help' => (
        MineCopyKey.campusSupportTitle,
        MineCopyKey.campusSupportSubtitle,
      ),
      'medical_services' || 'pharmacy' => (
        MineCopyKey.campusPharmacyTitle,
        MineCopyKey.campusPharmacySubtitle,
      ),
      'emergency' => (
        MineCopyKey.campusEmergencyTitle,
        MineCopyKey.campusEmergencySubtitle,
      ),
      _ => (
        MineCopyKey.campusHospitalTitle,
        MineCopyKey.campusHospitalSubtitle,
      ),
    };
  }

  IconData _parseIcon(String? name) {
    return switch (name) {
      'local_hospital' || 'hospital' => Icons.local_hospital_rounded,
      'favorite' || 'heart' => Icons.favorite_rounded,
      'medical_services' || 'pharmacy' => Icons.medical_services_rounded,
      'emergency' => Icons.emergency_rounded,
      'school' || 'campus' => Icons.school_rounded,
      'support' || 'help' => Icons.support_agent_rounded,
      'phone' => Icons.phone_rounded,
      _ => Icons.help_outline_rounded,
    };
  }

  Color _parseColor(String? name) {
    return switch (name) {
      'local_hospital' || 'hospital' => _blue,
      'favorite' || 'heart' => _purple,
      'medical_services' || 'pharmacy' => _green,
      'emergency' => _red,
      'school' || 'campus' => _blue,
      'support' || 'help' => _purple,
      _ => _blue,
    };
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
  List<MineActionEntry>? campusServices,
}) {
  return MineDashboard(
    account: account,
    completion: completion,
    profile: profile,
    alerts: alerts,
    archiveEntries: archiveEntries,
    campusServices: campusServices ?? _fallbackCampusServices,
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
    MineStatusCard(
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
    MineArchiveEntry(
      icon: Icons.medication_rounded,
      accent: _blue,
      titleKey: MineCopyKey.archiveMedicineTitle,
      subtitleKey: MineCopyKey.archiveMedicineSubtitle,
      route: '/mine/medicine/new',
    ),
  ];
}

const _fallbackCampusServices = [
  MineActionEntry(
    icon: Icons.local_hospital_rounded,
    accent: _blue,
    titleKey: MineCopyKey.campusHospitalTitle,
    subtitleKey: MineCopyKey.campusHospitalSubtitle,
  ),
  MineActionEntry(
    icon: Icons.favorite_rounded,
    accent: _purple,
    titleKey: MineCopyKey.campusSupportTitle,
    subtitleKey: MineCopyKey.campusSupportSubtitle,
  ),
  MineActionEntry(
    icon: Icons.medical_services_rounded,
    accent: _green,
    titleKey: MineCopyKey.campusPharmacyTitle,
    subtitleKey: MineCopyKey.campusPharmacySubtitle,
  ),
  MineActionEntry(
    icon: Icons.emergency_rounded,
    accent: _red,
    titleKey: MineCopyKey.campusEmergencyTitle,
    subtitleKey: MineCopyKey.campusEmergencySubtitle,
  ),
];

const _green = AppColorTokens.cyanDeep;
const _blue = AppColorTokens.link;
const _red = AppColorTokens.gradientShipStart;
const _pink = AppColorTokens.highlightMagenta;
const _purple = AppColorTokens.violet;

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mine_dashboard.freezed.dart';

@freezed
abstract class MineDashboard with _$MineDashboard {
  const factory MineDashboard({
    required MineAccount account,
    required MineCompletion completion,
    required MineProfileSnapshot profile,
    required List<MineStatusCard> alerts,
    required List<MineArchiveEntry> archiveEntries,
    required MinePrivacyNotice privacyNotice,
  }) = _MineDashboard;

  /// A minimal dashboard for signed-out users with no real or mock data.
  static MineDashboard signedOut() => const MineDashboard(
    account: MineAccount(
      isAuthenticated: false,
      displayNameKey: MineCopyKey.accountGuestDisplayName,
      email: '',
      statusKey: MineCopyKey.accountSignedOut,
      roleKey: MineCopyKey.accountStudentRole,
    ),
    completion: MineCompletion(
      progress: 0,
      percentLabel: '0%',
      titleKey: MineCopyKey.completionTitle,
    ),
    profile: MineProfileSnapshot(
      age: null,
      heightCm: null,
      allergyCount: 0,
      conditionCount: 0,
      currentMedicineCount: 0,
      basicInfoCompleted: false,
    ),
    alerts: <MineStatusCard>[],
    archiveEntries: <MineArchiveEntry>[],
    privacyNotice: MinePrivacyNotice(
      icon: Icons.shield_rounded,
      titleKey: MineCopyKey.privacyNoticeTitle,
      actionKey: MineCopyKey.privacyNoticeAction,
    ),
  );
}

@freezed
abstract class MineProfileSnapshot with _$MineProfileSnapshot {
  const factory MineProfileSnapshot({
    required int? age,
    required double? heightCm,
    required int allergyCount,
    required int conditionCount,
    required int currentMedicineCount,
    required bool basicInfoCompleted,
  }) = _MineProfileSnapshot;
}

@freezed
abstract class MineAccount with _$MineAccount {
  const factory MineAccount({
    required bool isAuthenticated,
    required MineCopyKey displayNameKey,
    String? displayName,
    required String email,
    required MineCopyKey statusKey,
    required MineCopyKey roleKey,
    @Default(false) bool emailVerified,
    @Default(false) bool hasPassword,
    @Default(0) int linkedIdentityCount,
    DateTime? lastLoginAt,
  }) = _MineAccount;
}

@freezed
abstract class MineCompletion with _$MineCompletion {
  const factory MineCompletion({
    required double progress,
    required String percentLabel,
    required MineCopyKey titleKey,
  }) = _MineCompletion;
}

@freezed
abstract class MineStatusCard with _$MineStatusCard {
  const factory MineStatusCard({
    required IconData icon,
    required Color accent,
    required MineCopyKey titleKey,
    required MineCopyKey subtitleKey,
    required MineCopyKey badgeKey,
  }) = _MineStatusCard;
}

@freezed
abstract class MineArchiveEntry with _$MineArchiveEntry {
  const factory MineArchiveEntry({
    required IconData icon,
    required Color accent,
    required MineCopyKey titleKey,
    required MineCopyKey subtitleKey,
    MineCopyKey? statusKey,
    String? route,
  }) = _MineArchiveEntry;
}

@freezed
abstract class MinePrivacyNotice with _$MinePrivacyNotice {
  const factory MinePrivacyNotice({
    required IconData icon,
    required MineCopyKey titleKey,
    required MineCopyKey actionKey,
  }) = _MinePrivacyNotice;
}

enum MineCopyKey {
  accountDisplayName,
  accountGuestDisplayName,
  accountSignedIn,
  accountSignedOut,
  accountStudentRole,
  signedOutNoticeTitle,
  signedOutNoticeDescription,
  completionTitle,
  alertAllergyTitle,
  alertAllergySubtitle,
  alertAllergyBadge,
  alertMedicineTitle,
  alertMedicineSubtitle,
  alertMedicineBadge,
  alertPrivacyTitle,
  alertPrivacySubtitle,
  alertPrivacyBadge,
  archiveBasicTitle,
  archiveBasicSubtitle,
  archiveAllergyTitle,
  archiveAllergySubtitle,
  archiveMedicineTitle,
  archiveMedicineSubtitle,
  archiveEmergencyTitle,
  archiveEmergencySubtitle,
  archiveCompleted,
  archiveNeedsFill,
  privacyNoticeTitle,
  privacyNoticeAction,
}

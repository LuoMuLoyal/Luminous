import 'package:flutter/material.dart';

class MineDashboard {
  const MineDashboard({
    required this.account,
    required this.completion,
    required this.profile,
    required this.alerts,
    required this.archiveEntries,
    required this.campusServices,
    required this.privacyNotice,
  });

  final MineAccount account;
  final MineCompletion completion;
  final MineProfileSnapshot profile;
  final List<MineStatusCard> alerts;
  final List<MineArchiveEntry> archiveEntries;
  final List<MineActionEntry> campusServices;
  final MinePrivacyNotice privacyNotice;
}

class MineProfileSnapshot {
  const MineProfileSnapshot({
    required this.age,
    required this.heightCm,
    required this.allergyCount,
    required this.conditionCount,
    required this.currentMedicineCount,
    required this.basicInfoCompleted,
  });

  final int? age;
  final double? heightCm;
  final int allergyCount;
  final int conditionCount;
  final int currentMedicineCount;
  final bool basicInfoCompleted;
}

class MineAccount {
  const MineAccount({
    required this.isAuthenticated,
    required this.displayNameKey,
    this.displayName,
    required this.email,
    required this.statusKey,
    required this.roleKey,
    this.emailVerified = false,
    this.hasPassword = false,
    this.linkedIdentityCount = 0,
    this.lastLoginAt,
  });

  final bool isAuthenticated;
  final MineCopyKey displayNameKey;
  final String? displayName;
  final String email;
  final MineCopyKey statusKey;
  final MineCopyKey roleKey;
  final bool emailVerified;
  final bool hasPassword;
  final int linkedIdentityCount;
  final DateTime? lastLoginAt;
}

class MineCompletion {
  const MineCompletion({
    required this.progress,
    required this.percentLabel,
    required this.titleKey,
  });

  final double progress;
  final String percentLabel;
  final MineCopyKey titleKey;
}

class MineStatusCard {
  const MineStatusCard({
    required this.icon,
    required this.accent,
    required this.titleKey,
    required this.subtitleKey,
    required this.badgeKey,
  });

  final IconData icon;
  final Color accent;
  final MineCopyKey titleKey;
  final MineCopyKey subtitleKey;
  final MineCopyKey badgeKey;
}

class MineArchiveEntry {
  const MineArchiveEntry({
    required this.icon,
    required this.accent,
    required this.titleKey,
    required this.subtitleKey,
    this.statusKey,
    this.route,
  });

  final IconData icon;
  final Color accent;
  final MineCopyKey titleKey;
  final MineCopyKey subtitleKey;
  final MineCopyKey? statusKey;
  final String? route;
}

class MineActionEntry {
  const MineActionEntry({
    required this.icon,
    required this.accent,
    required this.titleKey,
    required this.subtitleKey,
    this.route,
  });

  final IconData icon;
  final Color accent;
  final MineCopyKey titleKey;
  final MineCopyKey subtitleKey;
  final String? route;
}

class MinePrivacyNotice {
  const MinePrivacyNotice({
    required this.icon,
    required this.titleKey,
    required this.actionKey,
  });

  final IconData icon;
  final MineCopyKey titleKey;
  final MineCopyKey actionKey;
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
  campusHospitalTitle,
  campusHospitalSubtitle,
  campusSupportTitle,
  campusSupportSubtitle,
  campusPharmacyTitle,
  campusPharmacySubtitle,
  campusEmergencyTitle,
  campusEmergencySubtitle,
  privacyNoticeTitle,
  privacyNoticeAction,
}

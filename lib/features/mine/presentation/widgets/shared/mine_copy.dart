import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

String mineCopy(AppLocalizations l10n, MineCopyKey key) {
  return switch (key) {
    MineCopyKey.accountDisplayName => l10n.mineAccountDisplayName,
    MineCopyKey.accountGuestDisplayName => l10n.mineAccountGuestDisplayName,
    MineCopyKey.accountSignedIn => l10n.mineAccountSignedIn,
    MineCopyKey.accountSignedOut => l10n.mineAccountSignedOut,
    MineCopyKey.accountStudentRole => l10n.mineAccountStudentRole,
    MineCopyKey.signedOutNoticeTitle => l10n.mineSignedOutNoticeTitle,
    MineCopyKey.signedOutNoticeDescription =>
      l10n.mineSignedOutNoticeDescription,
    MineCopyKey.completionTitle => l10n.mineCompletionTitle,
    MineCopyKey.alertAllergyTitle => l10n.mineAlertAllergyTitle,
    MineCopyKey.alertAllergySubtitle => l10n.mineAlertAllergySubtitle,
    MineCopyKey.alertAllergyBadge => l10n.mineAlertAllergyBadge,
    MineCopyKey.alertMedicineTitle => l10n.mineAlertMedicineTitle,
    MineCopyKey.alertMedicineSubtitle => l10n.mineAlertMedicineSubtitle,
    MineCopyKey.alertMedicineBadge => l10n.mineAlertMedicineBadge,
    MineCopyKey.alertPrivacyTitle => l10n.mineAlertPrivacyTitle,
    MineCopyKey.alertPrivacySubtitle => l10n.mineAlertPrivacySubtitle,
    MineCopyKey.alertPrivacyBadge => l10n.mineAlertPrivacyBadge,
    MineCopyKey.archiveBasicTitle => l10n.mineArchiveBasicTitle,
    MineCopyKey.archiveBasicSubtitle => l10n.mineArchiveBasicSubtitle,
    MineCopyKey.archiveAllergyTitle => l10n.mineArchiveAllergyTitle,
    MineCopyKey.archiveAllergySubtitle => l10n.mineArchiveAllergySubtitle,
    MineCopyKey.archiveMedicineTitle => l10n.mineArchiveMedicineTitle,
    MineCopyKey.archiveMedicineSubtitle => l10n.mineArchiveMedicineSubtitle,
    MineCopyKey.archiveEmergencyTitle => l10n.mineArchiveEmergencyTitle,
    MineCopyKey.archiveEmergencySubtitle => l10n.mineArchiveEmergencySubtitle,
    MineCopyKey.archiveCompleted => l10n.mineArchiveCompleted,
    MineCopyKey.archiveNeedsFill => l10n.mineArchiveNeedsFill,
    MineCopyKey.privacyNoticeTitle => l10n.minePrivacyNoticeTitle,
    MineCopyKey.privacyNoticeAction => l10n.minePrivacyNoticeAction,
  };
}

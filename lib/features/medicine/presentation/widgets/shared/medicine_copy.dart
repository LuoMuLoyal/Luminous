import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/l10n/app_localizations.dart';

String medicineCopy(AppLocalizations l10n, MedicineCopyKey key) {
  return switch (key) {
    MedicineCopyKey.quickActionCameraTitle =>
      l10n.medicineQuickActionCameraTitle,
    MedicineCopyKey.quickActionCameraSubtitle =>
      l10n.medicineQuickActionCameraSubtitle,
    MedicineCopyKey.quickActionBarcodeTitle =>
      l10n.medicineQuickActionBarcodeTitle,
    MedicineCopyKey.quickActionBarcodeSubtitle =>
      l10n.medicineQuickActionBarcodeSubtitle,
    MedicineCopyKey.quickActionSearchTitle =>
      l10n.medicineQuickActionSearchTitle,
    MedicineCopyKey.quickActionSearchSubtitle =>
      l10n.medicineQuickActionSearchSubtitle,
    MedicineCopyKey.quickActionPrescriptionTitle =>
      l10n.medicineQuickActionPrescriptionTitle,
    MedicineCopyKey.quickActionPrescriptionSubtitle =>
      l10n.medicineQuickActionPrescriptionSubtitle,
    MedicineCopyKey.genericName => l10n.medicineGenericName,
    MedicineCopyKey.genericDosage => l10n.medicineGenericDosage,
    MedicineCopyKey.genericSchedule => l10n.medicineGenericSchedule,
    MedicineCopyKey.doseStatusTaken => l10n.medicineDoseStatusTaken,
    MedicineCopyKey.doseStatusSkipped => l10n.medicineDoseStatusSkipped,
    MedicineCopyKey.doseStatusPending => l10n.medicineDoseStatusPending,
    MedicineCopyKey.statusStable => l10n.medicineStatusStable,
    MedicineCopyKey.statusNeedsCheckin => l10n.medicineStatusNeedsCheckin,
    MedicineCopyKey.alertInteractionTitle => l10n.medicineAlertInteractionTitle,
    MedicineCopyKey.alertInteractionBody => l10n.medicineAlertInteractionBody,
    MedicineCopyKey.alertInteractionDetail =>
      l10n.medicineAlertInteractionDetail,
    MedicineCopyKey.alertInteractionAction =>
      l10n.medicineAlertInteractionAction,
    MedicineCopyKey.alertOtherTitle => l10n.medicineAlertOtherTitle,
    MedicineCopyKey.alertOtherBody => l10n.medicineAlertOtherBody,
    MedicineCopyKey.alertOtherDetail => l10n.medicineAlertOtherDetail,
    MedicineCopyKey.alertOtherAction => l10n.medicineAlertOtherAction,
    MedicineCopyKey.alertAlcoholRiskTitle => l10n.medicineAlertAlcoholRiskTitle,
    MedicineCopyKey.alertAlcoholRiskBody => l10n.medicineAlertAlcoholRiskBody,
    MedicineCopyKey.alertAlcoholRiskDetail =>
      l10n.medicineAlertAlcoholRiskDetail,
    MedicineCopyKey.alertAlcoholRiskStatus =>
      l10n.medicineAlertAlcoholRiskStatus,
    MedicineCopyKey.alertCoffeeReminderTitle =>
      l10n.medicineAlertCoffeeReminderTitle,
    MedicineCopyKey.alertCoffeeReminderBody =>
      l10n.medicineAlertCoffeeReminderBody,
    MedicineCopyKey.alertCoffeeReminderDetail =>
      l10n.medicineAlertCoffeeReminderDetail,
    MedicineCopyKey.alertCoffeeReminderStatus =>
      l10n.medicineAlertCoffeeReminderStatus,
    MedicineCopyKey.alertDuplicateCheckTitle =>
      l10n.medicineAlertDuplicateCheckTitle,
    MedicineCopyKey.alertDuplicateCheckBody =>
      l10n.medicineAlertDuplicateCheckBody,
    MedicineCopyKey.alertDuplicateCheckDetail =>
      l10n.medicineAlertDuplicateCheckDetail,
    MedicineCopyKey.alertDuplicateCheckStatus =>
      l10n.medicineAlertDuplicateCheckStatus,
    MedicineCopyKey.alertSpecialGroupSafetyTitle =>
      l10n.medicineAlertSpecialGroupSafetyTitle,
    MedicineCopyKey.alertSpecialGroupSafetyBody =>
      l10n.medicineAlertSpecialGroupSafetyBody,
    MedicineCopyKey.alertSpecialGroupSafetyDetail =>
      l10n.medicineAlertSpecialGroupSafetyDetail,
    MedicineCopyKey.alertSpecialGroupSafetyStatus =>
      l10n.medicineAlertSpecialGroupSafetyStatus,
    MedicineCopyKey.promisePointBoundary => l10n.medicinePromisePointBoundary,
    MedicineCopyKey.promisePointSpecialGroup =>
      l10n.medicinePromisePointSpecialGroup,
    MedicineCopyKey.promisePointPrivacy => l10n.medicinePromisePointPrivacy,
    MedicineCopyKey.promisePointDiagnosis => l10n.medicinePromisePointDiagnosis,
  };
}

String medicineAlertTitle(AppLocalizations l10n, MedicineAlert alert) {
  final raw = alert.rawTitle?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  final key = alert.titleKey;
  return key == null ? l10n.medicineSafetyEngineTitle : medicineCopy(l10n, key);
}

String medicineAlertBody(AppLocalizations l10n, MedicineAlert alert) {
  final raw = alert.rawBody?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  final key = alert.bodyKey;
  return key == null ? l10n.medicineSafetyEngineTitle : medicineCopy(l10n, key);
}

String medicineAlertDetail(AppLocalizations l10n, MedicineAlert alert) {
  final raw = alert.rawDetail?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  final key = alert.detailKey;
  return key == null ? l10n.medicineSafetyEngineTitle : medicineCopy(l10n, key);
}

String medicineAlertAction(AppLocalizations l10n, MedicineAlert alert) {
  final raw = alert.rawAction?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  final key = alert.actionKey;
  return key == null ? l10n.todayRetryAction : medicineCopy(l10n, key);
}

List<MedicineAlert> medicineAlertsFromRiskCheck(
  AppLocalizations l10n,
  MedicineRiskCheckResult? result,
) {
  if (result == null) {
    return const [];
  }

  final alerts = <MedicineAlert>[
    for (final finding in result.findings.take(4))
      MedicineAlert(
        icon: medicineRiskFindingIcon(finding),
        color: medicineRiskSeverityColor(finding.severity),
        softColor: medicineRiskSeveritySoftColor(finding.severity),
        rawTitle: medicineRiskFindingTitle(l10n, finding),
        rawBody: medicineRiskFindingBody(l10n, finding),
        rawDetail: medicineRiskFindingEvidence(l10n, finding),
        rawAction: l10n.medicineRiskCheckViewAction,
      ),
  ];

  if (result.coverageIssues.isNotEmpty) {
    final names = result.coverageIssues
        .take(3)
        .map((issue) => issue.medicineName.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    final detail = names.isEmpty
        ? l10n.medicineRiskCheckCoverageReasonDetailUnavailable
        : result.coverageIssues.length > names.length
        ? l10n.medicineRiskCheckCoverageAlertDetailWithMore(names.join('、'))
        : l10n.medicineRiskCheckCoverageAlertDetail(names.join('、'));
    final summaryLine = result.coverageSummary.isNotEmpty
        ? result.coverageSummary
        : null;
    final coverageAlert = MedicineAlert(
      icon: Icons.info_outline_rounded,
      color: AppColorTokens.warningDeep,
      softColor: AppColorTokens.warningSoft,
      rawTitle: summaryLine ?? l10n.medicineRiskCheckCoverageAlertTitle,
      rawBody: l10n.medicineRiskCheckCoverageAlertBody(
        result.coverageIssues.length,
      ),
      rawDetail: detail,
      rawAction: l10n.medicineRiskCheckViewAction,
    );

    if (alerts.isNotEmpty) {
      return [...alerts.take(3), coverageAlert];
    }

    return [
      MedicineAlert(
        icon: coverageAlert.icon,
        color: coverageAlert.color,
        softColor: coverageAlert.softColor,
        rawTitle: coverageAlert.rawTitle,
        rawBody: coverageAlert.rawBody,
        rawDetail: coverageAlert.rawDetail,
        rawAction: coverageAlert.rawAction,
      ),
    ];
  }

  if (alerts.isNotEmpty) {
    return alerts;
  }

  return [
    MedicineAlert(
      icon: Icons.verified_outlined,
      color: AppColorTokens.success,
      softColor: AppColorTokens.linkSoft,
      rawTitle: l10n.medicineRiskCheckAllClearAlertTitle,
      rawBody: l10n.medicineRiskCheckAllClearAlertBody,
      rawDetail: l10n.medicineRiskCheckAllClearAlertDetail,
      rawAction: l10n.medicineRiskCheckViewAction,
    ),
  ];
}

IconData medicineRiskFindingIcon(MedicineRiskFinding finding) {
  return switch (finding.type) {
    MedicineRiskFindingType.interaction => Icons.sync_problem_rounded,
    MedicineRiskFindingType.duplicateIngredient => Icons.content_copy_rounded,
    MedicineRiskFindingType.allergy => Icons.warning_amber_rounded,
    MedicineRiskFindingType.specialGroup => Icons.health_and_safety_rounded,
    MedicineRiskFindingType.foodInteraction => Icons.restaurant_rounded,
  };
}

Color medicineRiskSeverityColor(MedicineRiskSeverity severity) {
  return switch (severity) {
    MedicineRiskSeverity.high => AppColorTokens.error,
    MedicineRiskSeverity.medium => AppColorTokens.warningDeep,
    MedicineRiskSeverity.info => AppColorTokens.cyanDeep,
  };
}

Color medicineRiskSeveritySoftColor(MedicineRiskSeverity severity) {
  return switch (severity) {
    MedicineRiskSeverity.high => AppColorTokens.errorSoft,
    MedicineRiskSeverity.medium => AppColorTokens.warningSoft,
    MedicineRiskSeverity.info => AppColorTokens.cyanSoft,
  };
}

String medicineRiskFindingTitle(
  AppLocalizations l10n,
  MedicineRiskFinding finding,
) {
  return switch (finding.type) {
    MedicineRiskFindingType.interaction =>
      l10n.medicineRiskCheckFindingTitleInteraction,
    MedicineRiskFindingType.duplicateIngredient =>
      l10n.medicineRiskCheckFindingTitleDuplicate,
    MedicineRiskFindingType.allergy =>
      l10n.medicineRiskCheckFindingTitleAllergy,
    MedicineRiskFindingType.foodInteraction =>
      l10n.medicineRiskCheckFindingTitleFoodInteraction,
    MedicineRiskFindingType.specialGroup =>
      l10n.medicineRiskCheckFindingTitleSpecialGroup,
  };
}

String medicineRiskFindingBody(
  AppLocalizations l10n,
  MedicineRiskFinding finding,
) {
  final primary = finding.primaryMedicineName;
  final secondary = finding.secondaryMedicineName?.trim();
  final related = finding.relatedLabel?.trim();

  return switch (finding.type) {
    MedicineRiskFindingType.interaction =>
      secondary != null && secondary.isNotEmpty
          ? l10n.medicineRiskCheckFindingBodyInteraction(primary, secondary)
          : l10n.medicineRiskCheckFindingBodyInteractionSingle(primary),
    MedicineRiskFindingType.duplicateIngredient =>
      secondary != null && secondary.isNotEmpty
          ? l10n.medicineRiskCheckFindingBodyDuplicate(primary, secondary)
          : l10n.medicineRiskCheckFindingBodyDuplicateSingle(primary),
    MedicineRiskFindingType.allergy =>
      related != null && related.isNotEmpty
          ? l10n.medicineRiskCheckFindingBodyAllergy(primary, related)
          : l10n.medicineRiskCheckFindingBodyAllergyGeneric(primary),
    MedicineRiskFindingType.specialGroup => () {
      final ctx = medicineRiskContextLabel(l10n, finding.context);
      if (ctx.isNotEmpty) {
        return '$ctx · $primary';
      }
      return l10n.medicineRiskCheckFindingBodySpecialGroup(primary);
    }(),
    MedicineRiskFindingType.foodInteraction =>
      l10n.medicineRiskCheckFindingBodyFoodInteraction(primary),
  };
}

String medicineRiskFindingEvidence(
  AppLocalizations l10n,
  MedicineRiskFinding finding,
) {
  final text = finding.evidence?.trim();
  if (text != null && text.isNotEmpty) {
    return text;
  }
  return l10n.medicineRiskCheckFindingEvidenceFallback;
}

String medicineRiskSeverityLabel(
  AppLocalizations l10n,
  MedicineRiskSeverity severity,
) {
  return switch (severity) {
    MedicineRiskSeverity.high => l10n.medicineRiskCheckSeverityHigh,
    MedicineRiskSeverity.medium => l10n.medicineRiskCheckSeverityMedium,
    MedicineRiskSeverity.info => l10n.medicineRiskCheckSeverityInfo,
  };
}

String medicineRiskContextLabel(
  AppLocalizations l10n,
  MedicineRiskFindingContext context,
) {
  return switch (context) {
    MedicineRiskFindingContext.none => '',
    MedicineRiskFindingContext.alcohol => l10n.medicineRiskCheckContextAlcohol,
    MedicineRiskFindingContext.caffeine =>
      l10n.medicineRiskCheckContextCaffeine,
  };
}

String medicineRiskCoverageReasonLabel(
  AppLocalizations l10n,
  MedicineRiskCoverageReason reason,
) {
  return switch (reason) {
    MedicineRiskCoverageReason.manualEntry =>
      l10n.medicineRiskCheckCoverageReasonManualEntry,
    MedicineRiskCoverageReason.missingSourceRef =>
      l10n.medicineRiskCheckCoverageReasonMissingSourceRef,
    MedicineRiskCoverageReason.detailUnavailable =>
      l10n.medicineRiskCheckCoverageReasonDetailUnavailable,
  };
}

String redFlagBannerTitle(AppLocalizations l10n) {
  return l10n.medicineRiskCheckRedFlagBannerTitle;
}

String redFlagAlertCopy(AppLocalizations l10n, RedFlagAlert alert) {
  final drug = alert.primaryMedicineName;
  final allergen = alert.relatedLabel?.trim();
  return switch (alert.rule) {
    RedFlagRule.severeAllergy =>
      allergen != null && allergen.isNotEmpty
          ? l10n.medicineRiskCheckRedFlagSevereAllergy(drug, allergen)
          : l10n.medicineRiskCheckRedFlagSevereAllergyGeneric(drug),
    RedFlagRule.informationGap => l10n.medicineRiskCheckRedFlagInformationGap(
      drug,
    ),
  };
}

String redFlagActionCopy(AppLocalizations l10n, RedFlagAlert alert) {
  return switch (alert.rule) {
    RedFlagRule.severeAllergy =>
      l10n.medicineRiskCheckRedFlagActionSevereAllergy,
    RedFlagRule.informationGap =>
      l10n.medicineRiskCheckRedFlagActionInformationGap,
  };
}

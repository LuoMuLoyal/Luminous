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
    MedicineCopyKey.mockNameMetformin => l10n.medicineMockNameMetformin,
    MedicineCopyKey.mockDoseMetformin => l10n.medicineMockDoseMetformin,
    MedicineCopyKey.mockScheduleMorningEvening =>
      l10n.medicineMockScheduleMorningEvening,
    MedicineCopyKey.mockTime0800 => l10n.medicineMockTime0800,
    MedicineCopyKey.mockTime1200 => l10n.medicineMockTime1200,
    MedicineCopyKey.mockTime2000 => l10n.medicineMockTime2000,
    MedicineCopyKey.doseStatusTaken => l10n.medicineDoseStatusTaken,
    MedicineCopyKey.doseStatusPending => l10n.medicineDoseStatusPending,
    MedicineCopyKey.mockStock7Days => l10n.medicineMockStock7Days,
    MedicineCopyKey.statusStable => l10n.medicineStatusStable,
    MedicineCopyKey.mockNameAtorvastatin => l10n.medicineMockNameAtorvastatin,
    MedicineCopyKey.mockDoseAtorvastatin => l10n.medicineMockDoseAtorvastatin,
    MedicineCopyKey.mockScheduleDailyOnce => l10n.medicineMockScheduleDailyOnce,
    MedicineCopyKey.mockStock15Days => l10n.medicineMockStock15Days,
    MedicineCopyKey.statusNeedsCheckin => l10n.medicineStatusNeedsCheckin,
    MedicineCopyKey.mockNameOmeprazole => l10n.medicineMockNameOmeprazole,
    MedicineCopyKey.mockDoseOmeprazole => l10n.medicineMockDoseOmeprazole,
    MedicineCopyKey.mockStock3Days => l10n.medicineMockStock3Days,
    MedicineCopyKey.statusNeedRefillSoon => l10n.medicineStatusNeedRefillSoon,
    MedicineCopyKey.stockWarningLow => l10n.medicineStockWarningLow,
    MedicineCopyKey.alertRefillTitle => l10n.medicineAlertRefillTitle,
    MedicineCopyKey.alertRefillBody => l10n.medicineAlertRefillBody,
    MedicineCopyKey.alertRefillDetail => l10n.medicineAlertRefillDetail,
    MedicineCopyKey.alertRefillAction => l10n.medicineAlertRefillAction,
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
    MedicineCopyKey.promisePointBoundary => l10n.medicinePromisePointBoundary,
    MedicineCopyKey.promisePointPregnancy => l10n.medicinePromisePointPregnancy,
    MedicineCopyKey.promisePointPrivacy => l10n.medicinePromisePointPrivacy,
    MedicineCopyKey.promisePointDiagnosis => l10n.medicinePromisePointDiagnosis,
  };
}

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
    MedicineCopyKey.doseStatusSkipped => l10n.medicineDoseStatusSkipped,
    MedicineCopyKey.doseStatusPending => l10n.medicineDoseStatusPending,
    MedicineCopyKey.statusStable => l10n.medicineStatusStable,
    MedicineCopyKey.mockNameAtorvastatin => l10n.medicineMockNameAtorvastatin,
    MedicineCopyKey.mockDoseAtorvastatin => l10n.medicineMockDoseAtorvastatin,
    MedicineCopyKey.mockScheduleDailyOnce => l10n.medicineMockScheduleDailyOnce,
    MedicineCopyKey.statusNeedsCheckin => l10n.medicineStatusNeedsCheckin,
    MedicineCopyKey.mockNameOmeprazole => l10n.medicineMockNameOmeprazole,
    MedicineCopyKey.mockDoseOmeprazole => l10n.medicineMockDoseOmeprazole,
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
    MedicineCopyKey.alertPeriodPregnancyTitle =>
      l10n.medicineAlertPeriodPregnancyTitle,
    MedicineCopyKey.alertPeriodPregnancyBody =>
      l10n.medicineAlertPeriodPregnancyBody,
    MedicineCopyKey.alertPeriodPregnancyDetail =>
      l10n.medicineAlertPeriodPregnancyDetail,
    MedicineCopyKey.alertPeriodPregnancyStatus =>
      l10n.medicineAlertPeriodPregnancyStatus,
    MedicineCopyKey.promisePointBoundary => l10n.medicinePromisePointBoundary,
    MedicineCopyKey.promisePointPregnancy => l10n.medicinePromisePointPregnancy,
    MedicineCopyKey.promisePointPrivacy => l10n.medicinePromisePointPrivacy,
    MedicineCopyKey.promisePointDiagnosis => l10n.medicinePromisePointDiagnosis,
  };
}

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
    MedicineCopyKey.suggestionBloodPressure =>
      l10n.medicineSearchSuggestionBloodPressure,
    MedicineCopyKey.suggestionCold => l10n.medicineSearchSuggestionCold,
    MedicineCopyKey.suggestionSupplement =>
      l10n.medicineSearchSuggestionSupplement,
    MedicineCopyKey.mockNameMetformin => l10n.medicineMockNameMetformin,
    MedicineCopyKey.mockDoseMetformin => l10n.medicineMockDoseMetformin,
    MedicineCopyKey.mockScheduleMorningEvening =>
      l10n.medicineMockScheduleMorningEvening,
    MedicineCopyKey.mockTime0800Taken => l10n.medicineMockTime0800Taken,
    MedicineCopyKey.mockTime2000Pending => l10n.medicineMockTime2000Pending,
    MedicineCopyKey.mockStock7Days => l10n.medicineMockStock7Days,
    MedicineCopyKey.statusStable => l10n.medicineStatusStable,
    MedicineCopyKey.mockNameVitaminD => l10n.medicineMockNameVitaminD,
    MedicineCopyKey.mockDoseVitaminD => l10n.medicineMockDoseVitaminD,
    MedicineCopyKey.mockScheduleDailyOnce => l10n.medicineMockScheduleDailyOnce,
    MedicineCopyKey.mockWithDinner => l10n.medicineMockWithDinner,
    MedicineCopyKey.mockStock15Days => l10n.medicineMockStock15Days,
    MedicineCopyKey.statusNeedsCheckin => l10n.medicineStatusNeedsCheckin,
    MedicineCopyKey.mockNameSertraline => l10n.medicineMockNameSertraline,
    MedicineCopyKey.mockDoseSertraline => l10n.medicineMockDoseSertraline,
    MedicineCopyKey.mockTime2200Pending => l10n.medicineMockTime2200Pending,
    MedicineCopyKey.mockStressRisk => l10n.medicineMockStressRisk,
    MedicineCopyKey.mockStock3Days => l10n.medicineMockStock3Days,
    MedicineCopyKey.statusNeedRefillSoon => l10n.medicineStatusNeedRefillSoon,
    MedicineCopyKey.alertRefillTitle => l10n.medicineAlertRefillTitle,
    MedicineCopyKey.alertRefillBody => l10n.medicineAlertRefillBody,
    MedicineCopyKey.alertRefillAction => l10n.medicineAlertRefillAction,
    MedicineCopyKey.alertInteractionTitle => l10n.medicineAlertInteractionTitle,
    MedicineCopyKey.alertInteractionBody => l10n.medicineAlertInteractionBody,
    MedicineCopyKey.alertInteractionAction =>
      l10n.medicineAlertInteractionAction,
    MedicineCopyKey.promisePointBoundary => l10n.medicinePromisePointBoundary,
    MedicineCopyKey.promisePointPregnancy => l10n.medicinePromisePointPregnancy,
    MedicineCopyKey.promisePointPrivacy => l10n.medicinePromisePointPrivacy,
  };
}

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';

part 'medicine_workspace.freezed.dart';

@freezed
abstract class MedicineWorkspace with _$MedicineWorkspace {
  const factory MedicineWorkspace({
    required MedicineHero hero,
    required List<MedicineQuickAction> quickActions,
    required MedicinePlanSurface plan,
    required List<MedicineAlert> alerts,
    required List<MedicinePromisePoint> promisePoints,
    MedicineRiskCheckResult? riskCheckResult,
  }) = _MedicineWorkspace;

  /// A minimal workspace for signed-out users with no real or mock data.
  static MedicineWorkspace signedOut() => const MedicineWorkspace(
    hero: MedicineHero(
      metricDosesToday: '0',
      metricAdherence: '--',
      metricNextDose: '--',
    ),
    quickActions: <MedicineQuickAction>[
      MedicineQuickAction(
        icon: Icons.search_rounded,
        titleKey: MedicineCopyKey.quickActionSearchTitle,
        subtitleKey: MedicineCopyKey.quickActionSearchSubtitle,
        accent: Color(0xFF00838F),
      ),
    ],
    plan: MedicinePlanSurface(items: <MedicinePlanItem>[]),
    alerts: <MedicineAlert>[],
    promisePoints: <MedicinePromisePoint>[],
  );
}

@freezed
abstract class MedicineHero with _$MedicineHero {
  const factory MedicineHero({
    required String metricDosesToday,
    required String metricAdherence,
    required String metricNextDose,
  }) = _MedicineHero;
}

// Deferred by Product_Vision MVP: keep this code because the capability is useful, but do not surface it until the matching contract/product job is ready.
@freezed
abstract class MedicineQuickAction with _$MedicineQuickAction {
  const factory MedicineQuickAction({
    required IconData icon,
    required MedicineCopyKey titleKey,
    required MedicineCopyKey subtitleKey,
    required Color accent,
  }) = _MedicineQuickAction;
}

@freezed
abstract class MedicinePlanSurface with _$MedicinePlanSurface {
  const factory MedicinePlanSurface({required List<MedicinePlanItem> items}) =
      _MedicinePlanSurface;
}

@freezed
abstract class MedicinePlanItem with _$MedicinePlanItem {
  const factory MedicinePlanItem({
    required Color color,
    required MedicineCopyKey nameKey,
    required MedicineCopyKey dosageKey,
    required MedicineCopyKey scheduleKey,
    required List<MedicineDoseSlot> slots,
    required MedicineCopyKey stateKey,
    required Color stateColor,
    MedicineDoseStatus? todayStatus,

    /// When non-null, the view should use these raw strings instead of
    /// resolving [nameKey]/[dosageKey]/[scheduleKey]/[stateKey] through
    /// [medicineCopy].
    String? rawName,
    String? rawDosage,
    String? rawSchedule,
    String? rawState,
    String? currentMedicineId,
  }) = _MedicinePlanItem;
}

@freezed
abstract class MedicineDoseSlot with _$MedicineDoseSlot {
  const factory MedicineDoseSlot({
    MedicineCopyKey? timeKey,
    String? rawTime,
    required MedicineCopyKey statusKey,
    required MedicineDoseStatus status,
  }) = _MedicineDoseSlot;
}

enum MedicineDoseStatus { taken, skipped, pending }

@freezed
abstract class MedicineAlert with _$MedicineAlert {
  const factory MedicineAlert({
    required IconData icon,
    MedicineCopyKey? titleKey,
    MedicineCopyKey? bodyKey,
    MedicineCopyKey? detailKey,
    MedicineCopyKey? actionKey,
    required Color color,
    required Color softColor,
    String? rawTitle,
    String? rawBody,
    String? rawDetail,
    String? rawAction,
  }) = _MedicineAlert;
}

@freezed
abstract class MedicinePromisePoint with _$MedicinePromisePoint {
  const factory MedicinePromisePoint({required MedicineCopyKey copyKey}) =
      _MedicinePromisePoint;
}

enum MedicineCopyKey {
  // Deferred by Product_Vision MVP: quick-action scan/OCR keys are kept but not surfaced in the MVP UI.
  quickActionCameraTitle,
  quickActionCameraSubtitle,
  quickActionBarcodeTitle,
  quickActionBarcodeSubtitle,
  quickActionSearchTitle,
  quickActionSearchSubtitle,
  quickActionPrescriptionTitle,
  quickActionPrescriptionSubtitle,
  genericName,
  genericDosage,
  genericSchedule,
  doseStatusTaken,
  doseStatusSkipped,
  doseStatusPending,
  statusStable,
  statusNeedsCheckin,
  alertInteractionTitle,
  alertInteractionBody,
  alertInteractionDetail,
  alertInteractionAction,
  alertOtherTitle,
  alertOtherBody,
  alertOtherDetail,
  alertOtherAction,
  alertAlcoholRiskTitle,
  alertAlcoholRiskBody,
  alertAlcoholRiskDetail,
  alertAlcoholRiskStatus,
  alertCoffeeReminderTitle,
  alertCoffeeReminderBody,
  alertCoffeeReminderDetail,
  alertCoffeeReminderStatus,
  alertDuplicateCheckTitle,
  alertDuplicateCheckBody,
  alertDuplicateCheckDetail,
  alertDuplicateCheckStatus,
  alertSpecialGroupSafetyTitle,
  alertSpecialGroupSafetyBody,
  alertSpecialGroupSafetyDetail,
  alertSpecialGroupSafetyStatus,
  promisePointBoundary,
  promisePointSpecialGroup,
  promisePointPrivacy,
  promisePointDiagnosis,
}

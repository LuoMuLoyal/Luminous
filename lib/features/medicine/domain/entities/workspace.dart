import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

part 'workspace.freezed.dart';

@freezed
abstract class MedicineWorkspace with _$MedicineWorkspace {
  const factory MedicineWorkspace({
    required MedicineHero hero,
    required List<MedicineQuickAction> quickActions,
    required MedicinePlanSurface plan,
    // TODO(archive): 历史占位字段，不再接入主路径——告警由 medicineAlertsFromRiskCheck
    // 从 riskCheckRecords 派生；无渲染消费方，保留为兼容，避免误用。
    required List<MedicineAlert> alerts,
    // TODO(archive): 历史 dashboard 原型残留，无渲染消费方，保留为兼容；若复用需先确认 UI 出口。
    required List<MedicinePromisePoint> promisePoints,
    MedicineRiskCheckRecords? riskCheckRecords,
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
        icon: SemanticIcons.actionSearch,
        titleKey: MedicineCopyKey.quickActionSearchTitle,
        subtitleKey: MedicineCopyKey.quickActionSearchSubtitle,
        accent: SemanticColor.primary,
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
    // TODO(archive): 历史 dashboard 原型残留，无渲染消费方，保留为兼容；若复用需先确认 UI 出口。
    required String metricDosesToday,
    required String metricAdherence,
    required String metricNextDose,
  }) = _MedicineHero;
}

@freezed
abstract class MedicineQuickAction with _$MedicineQuickAction {
  const factory MedicineQuickAction({
    required IconData icon,
    required MedicineCopyKey titleKey,
    required MedicineCopyKey subtitleKey,
    required SemanticColor accent,
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
    required SemanticColor color,
    required MedicineCopyKey nameKey,
    required MedicineCopyKey dosageKey,
    required MedicineCopyKey scheduleKey,
    required List<MedicineDoseSlot> slots,
    required MedicineCopyKey stateKey,
    required SemanticColor stateColor,
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
    String? reminderId,
    String? scheduledTime,
    MedicineCopyKey? timeKey,
    String? rawTime,
    required MedicineCopyKey statusKey,
    required MedicineDoseStatus status,
    // F-5 P1: status 仍为 pending 的槽，若已过其 HH:mm 时刻则 isOverdue 为 true
    // （「已超时未确认」），不新增 MedicineDoseStatus 枚举值；overdue 槽仍可补卡。
    @Default(false) bool isOverdue,
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
    required SemanticColor color,
    required SemanticColor softColor,
    String? rawTitle,
    String? rawBody,
    String? rawDetail,
    String? rawAction,
  }) = _MedicineAlert;
}

// TODO(archive): 历史 dashboard 原型残留，无渲染消费方，保留为兼容；若复用需先确认 UI 出口。
@freezed
abstract class MedicinePromisePoint with _$MedicinePromisePoint {
  const factory MedicinePromisePoint({required MedicineCopyKey copyKey}) =
      _MedicinePromisePoint;
}

enum MedicineCopyKey {
  quickActionCameraTitle,
  quickActionCameraSubtitle,
  quickActionBarcodeTitle,
  quickActionBarcodeSubtitle,
  quickActionSearchTitle,
  quickActionSearchSubtitle,
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
  // TODO(archive): 历史 dashboard 原型残留，无渲染消费方，保留为兼容；若复用需先确认 UI 出口。
  promisePointBoundary,
  promisePointSpecialGroup,
  promisePointPrivacy,
  promisePointDiagnosis,
}

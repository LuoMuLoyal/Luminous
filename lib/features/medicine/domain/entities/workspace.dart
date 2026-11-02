import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/shared/domain/semantic.dart';

part 'workspace.freezed.dart';
part 'workspace.g.dart';

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

  factory MedicineWorkspace.fromJson(Map<String, dynamic> json) =>
      _$MedicineWorkspaceFromJson(json);

  /// A minimal workspace for signed-out users with no real or mock data.
  static MedicineWorkspace signedOut() => const MedicineWorkspace(
    hero: MedicineHero(
      metricDosesToday: '0',
      metricAdherence: '--',
      metricNextDose: '--',
    ),
    quickActions: <MedicineQuickAction>[
      MedicineQuickAction(
        titleKey: MedicineCopyKey.quickActionSearchTitle,
        subtitleKey: MedicineCopyKey.quickActionSearchSubtitle,
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

  factory MedicineHero.fromJson(Map<String, dynamic> json) =>
      _$MedicineHeroFromJson(json);
}

@freezed
abstract class MedicineQuickAction with _$MedicineQuickAction {
  const factory MedicineQuickAction({
    required MedicineCopyKey titleKey,
    required MedicineCopyKey subtitleKey,
  }) = _MedicineQuickAction;

  factory MedicineQuickAction.fromJson(Map<String, dynamic> json) =>
      _$MedicineQuickActionFromJson(json);
}

@freezed
abstract class MedicinePlanSurface with _$MedicinePlanSurface {
  const factory MedicinePlanSurface({required List<MedicinePlanItem> items}) =
      _MedicinePlanSurface;

  factory MedicinePlanSurface.fromJson(Map<String, dynamic> json) =>
      _$MedicinePlanSurfaceFromJson(json);
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
    String? source,
    String? sourceRefId,
  }) = _MedicinePlanItem;

  factory MedicinePlanItem.fromJson(Map<String, dynamic> json) =>
      _$MedicinePlanItemFromJson(json);
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

  factory MedicineDoseSlot.fromJson(Map<String, dynamic> json) =>
      _$MedicineDoseSlotFromJson(json);
}

enum MedicineDoseStatus { taken, skipped, pending }

/// Icon identity for a [MedicineAlert], resolvable to an [IconData] in the
/// presentation layer.
///
/// The alert used to carry a raw `IconData`, which cannot be JSON-encoded and
/// therefore blocked caching the workspace. The key keeps the semantic identity
/// and stays serializable.
enum MedicineAlertIcon {
  statusError,
  statusWarning,
  statusInfo,
  safetyDuplicate,
  recordMeal,
  safetyLongTermUse,
  dosePlanned,
  safetySafe,
  safetySpecialPopulation,
  safetyFoodInteraction,
  safetyAllClear,
  safetyAlcohol,
  recordCaffeine,
  recordWater,
  safetyInteraction,
  safetySpecialGroup,
}

@freezed
abstract class MedicineAlert with _$MedicineAlert {
  const factory MedicineAlert({
    required MedicineAlertIcon iconKey,
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

  factory MedicineAlert.fromJson(Map<String, dynamic> json) =>
      _$MedicineAlertFromJson(json);
}

// TODO(archive): 历史 dashboard 原型残留，无渲染消费方，保留为兼容；若复用需先确认 UI 出口。
@freezed
abstract class MedicinePromisePoint with _$MedicinePromisePoint {
  const factory MedicinePromisePoint({required MedicineCopyKey copyKey}) =
      _MedicinePromisePoint;

  factory MedicinePromisePoint.fromJson(Map<String, dynamic> json) =>
      _$MedicinePromisePointFromJson(json);
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

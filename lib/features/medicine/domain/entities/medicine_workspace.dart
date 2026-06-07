import 'package:flutter/material.dart';

class MedicineWorkspace {
  const MedicineWorkspace({
    required this.hero,
    required this.quickActions,
    required this.plan,
    required this.alerts,
    required this.promisePoints,
  });

  final MedicineHero hero;
  final List<MedicineQuickAction> quickActions;
  final MedicinePlanSurface plan;
  final List<MedicineAlert> alerts;
  final List<MedicinePromisePoint> promisePoints;
}

class MedicineHero {
  const MedicineHero({
    required this.metricDosesToday,
    required this.metricAdherence,
    required this.metricNextDose,
  });

  final String metricDosesToday;
  final String metricAdherence;
  final String metricNextDose;
}

class MedicineQuickAction {
  const MedicineQuickAction({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.accent,
  });

  final IconData icon;
  final MedicineCopyKey titleKey;
  final MedicineCopyKey subtitleKey;
  final Color accent;
}

class MedicinePlanSurface {
  const MedicinePlanSurface({required this.items});

  final List<MedicinePlanItem> items;
}

class MedicinePlanItem {
  const MedicinePlanItem({
    required this.color,
    required this.nameKey,
    required this.dosageKey,
    required this.scheduleKey,
    required this.slots,
    required this.stockKey,
    required this.stateKey,
    required this.stateColor,
    this.stockWarningKey,
    this.rawName,
    this.rawDosage,
    this.rawSchedule,
    this.rawStock,
    this.rawState,
    this.currentMedicineId,
  });

  final Color color;
  final MedicineCopyKey nameKey;
  final MedicineCopyKey dosageKey;
  final MedicineCopyKey scheduleKey;
  final List<MedicineDoseSlot> slots;
  final MedicineCopyKey stockKey;
  final MedicineCopyKey stateKey;
  final Color stateColor;
  final MedicineCopyKey? stockWarningKey;

  /// When non-null, the view should use these raw strings instead of
  /// resolving [nameKey]/[dosageKey]/[scheduleKey]/[stockKey]/[stateKey]
  /// through [medicineCopy].
  final String? rawName;
  final String? rawDosage;
  final String? rawSchedule;
  final String? rawStock;
  final String? rawState;
  final String? currentMedicineId;
}

class MedicineDoseSlot {
  const MedicineDoseSlot({
    required this.timeKey,
    required this.statusKey,
    required this.status,
  });

  final MedicineCopyKey timeKey;
  final MedicineCopyKey statusKey;
  final MedicineDoseStatus status;
}

enum MedicineDoseStatus { taken, skipped, pending }

class MedicineAlert {
  const MedicineAlert({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
    required this.detailKey,
    required this.actionKey,
    required this.color,
    required this.softColor,
  });

  final IconData icon;
  final MedicineCopyKey titleKey;
  final MedicineCopyKey bodyKey;
  final MedicineCopyKey detailKey;
  final MedicineCopyKey actionKey;
  final Color color;
  final Color softColor;
}

class MedicinePromisePoint {
  const MedicinePromisePoint({required this.copyKey});

  final MedicineCopyKey copyKey;
}

enum MedicineCopyKey {
  quickActionCameraTitle,
  quickActionCameraSubtitle,
  quickActionBarcodeTitle,
  quickActionBarcodeSubtitle,
  quickActionSearchTitle,
  quickActionSearchSubtitle,
  quickActionPrescriptionTitle,
  quickActionPrescriptionSubtitle,
  mockNameMetformin,
  mockDoseMetformin,
  mockScheduleMorningEvening,
  mockTime0800,
  mockTime1200,
  mockTime2000,
  doseStatusTaken,
  doseStatusSkipped,
  doseStatusPending,
  mockStock7Days,
  statusStable,
  mockNameAtorvastatin,
  mockDoseAtorvastatin,
  mockScheduleDailyOnce,
  mockStock15Days,
  statusNeedsCheckin,
  mockNameOmeprazole,
  mockDoseOmeprazole,
  mockStock3Days,
  statusNeedRefillSoon,
  stockWarningLow,
  alertRefillTitle,
  alertRefillBody,
  alertRefillDetail,
  alertRefillAction,
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
  alertPeriodPregnancyTitle,
  alertPeriodPregnancyBody,
  alertPeriodPregnancyDetail,
  alertPeriodPregnancyStatus,
  promisePointBoundary,
  promisePointPregnancy,
  promisePointPrivacy,
  promisePointDiagnosis,
}

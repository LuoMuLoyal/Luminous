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
    required this.nextSlotKey,
    required this.laterSlotKey,
    required this.stockKey,
    required this.stateKey,
    required this.stateColor,
  });

  final Color color;
  final MedicineCopyKey nameKey;
  final MedicineCopyKey dosageKey;
  final MedicineCopyKey scheduleKey;
  final MedicineCopyKey nextSlotKey;
  final MedicineCopyKey laterSlotKey;
  final MedicineCopyKey stockKey;
  final MedicineCopyKey stateKey;
  final Color stateColor;
}

class MedicineAlert {
  const MedicineAlert({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
    required this.actionKey,
    required this.color,
    required this.softColor,
  });

  final IconData icon;
  final MedicineCopyKey titleKey;
  final MedicineCopyKey bodyKey;
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
  mockTime0800Taken,
  mockTime2000Pending,
  mockStock7Days,
  statusStable,
  mockNameVitaminD,
  mockDoseVitaminD,
  mockScheduleDailyOnce,
  mockWithDinner,
  mockStock15Days,
  statusNeedsCheckin,
  mockNameSertraline,
  mockDoseSertraline,
  mockTime2200Pending,
  mockStressRisk,
  mockStock3Days,
  statusNeedRefillSoon,
  alertRefillTitle,
  alertRefillBody,
  alertRefillAction,
  alertInteractionTitle,
  alertInteractionBody,
  alertInteractionAction,
  promisePointBoundary,
  promisePointPregnancy,
  promisePointPrivacy,
}

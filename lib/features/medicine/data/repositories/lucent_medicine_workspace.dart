import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart' show DoseLogRemoteDataSource, DoseLogStatus;
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/medicine_workspace_repository.dart';

/// Lucent-backed [MedicineWorkspaceRepository] that derives the medicine
/// workspace from the current user's real health-context data.
class LucentMedicineWorkspaceRepository
    implements MedicineWorkspaceRepository {
  LucentMedicineWorkspaceRepository({required this.healthRepo, required this.doseLogDs});

  final HealthContextRepository healthRepo;
  final DoseLogRemoteDataSource doseLogDs;

  @override
  Future<MedicineWorkspace> fetchWorkspace() async {
    final snapshot = await healthRepo.fetchHealthContext();
    final medicines = snapshot.currentMedicines;

    // Fetch today's dose logs
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    Set<String> takenMeds = {};
    try {
      final logs = await doseLogDs.fetchForDate(dateStr);
      takenMeds = logs.where((l) => l.status == DoseLogStatus.taken && l.currentMedicineId != null)
          .map((l) => l.currentMedicineId!).toSet();
    } catch (_) {}

    final planItems = medicines.map((m) {
      final isTaken = takenMeds.contains(m.id);
      return MedicinePlanItem(
        color: AppColorTokens.link,
        nameKey: MedicineCopyKey.mockNameMetformin,
        dosageKey: MedicineCopyKey.mockDoseMetformin,
        scheduleKey: MedicineCopyKey.mockScheduleMorningEvening,
        stockKey: MedicineCopyKey.mockStock7Days,
        stateKey: MedicineCopyKey.statusStable,
        stateColor: isTaken ? AppColorTokens.success : AppColorTokens.warning,
        slots: const [],
        rawName: m.displayName,
        rawDosage: m.strengthText ?? '',
        rawSchedule: m.doseText ?? '',
        rawStock: m.route ?? '',
        rawState: isTaken ? 'Taken' : 'Pending',
      );
    }).toList();

    return MedicineWorkspace(
      hero: MedicineHero(
        metricDosesToday: '${medicines.length}',
        metricAdherence: '--',
        metricNextDose: '--',
      ),
      quickActions: _defaultQuickActions(),
      plan: MedicinePlanSurface(items: planItems),
      alerts: _defaultAlerts(),
      promisePoints: _defaultPromisePoints(),
    );
  }

  static List<MedicineQuickAction> _defaultQuickActions() => const [
    MedicineQuickAction(
      icon: Icons.photo_camera_outlined,
      titleKey: MedicineCopyKey.quickActionCameraTitle,
      subtitleKey: MedicineCopyKey.quickActionCameraSubtitle,
      accent: AppColorTokens.gradientDevelopStart,
    ),
    MedicineQuickAction(
      icon: Icons.qr_code_scanner_rounded,
      titleKey: MedicineCopyKey.quickActionBarcodeTitle,
      subtitleKey: MedicineCopyKey.quickActionBarcodeSubtitle,
      accent: AppColorTokens.cyanDeep,
    ),
    MedicineQuickAction(
      icon: Icons.receipt_long_outlined,
      titleKey: MedicineCopyKey.quickActionPrescriptionTitle,
      subtitleKey: MedicineCopyKey.quickActionPrescriptionSubtitle,
      accent: AppColorTokens.warningDeep,
    ),
  ];

  static List<MedicineAlert> _defaultAlerts() => const [
    MedicineAlert(
      icon: Icons.health_and_safety_rounded,
      titleKey: MedicineCopyKey.alertRefillTitle,
      bodyKey: MedicineCopyKey.alertRefillBody,
      detailKey: MedicineCopyKey.alertRefillDetail,
      actionKey: MedicineCopyKey.alertRefillAction,
      color: AppColorTokens.error,
      softColor: AppColorTokens.errorSoft,
    ),
    MedicineAlert(
      icon: Icons.shield_outlined,
      titleKey: MedicineCopyKey.alertInteractionTitle,
      bodyKey: MedicineCopyKey.alertInteractionBody,
      detailKey: MedicineCopyKey.alertInteractionDetail,
      actionKey: MedicineCopyKey.alertInteractionAction,
      color: AppColorTokens.warningDeep,
      softColor: AppColorTokens.warningSoft,
    ),
    MedicineAlert(
      icon: Icons.verified_user_outlined,
      titleKey: MedicineCopyKey.alertOtherTitle,
      bodyKey: MedicineCopyKey.alertOtherBody,
      detailKey: MedicineCopyKey.alertOtherDetail,
      actionKey: MedicineCopyKey.alertOtherAction,
      color: AppColorTokens.linkDeep,
      softColor: AppColorTokens.linkSoft,
    ),
  ];

  static List<MedicinePromisePoint> _defaultPromisePoints() => const [
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointBoundary),
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPregnancy),
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPrivacy),
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointDiagnosis),
  ];
}

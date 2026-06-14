import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart'
    show DoseLogRemoteDataSource, DoseLogStatus;
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/medicine_risk_check_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/medicine_workspace_repository.dart';

/// Lucent-backed [MedicineWorkspaceRepository] that derives the medicine
/// workspace from the current user's real health-context data.
class LucentMedicineWorkspaceRepository implements MedicineWorkspaceRepository {
  LucentMedicineWorkspaceRepository({
    required this.healthRepo,
    required this.doseLogDs,
    required this.reminderDs,
    required this.riskCheckRepository,
  });

  final HealthContextRepository healthRepo;
  final DoseLogRemoteDataSource doseLogDs;
  final MedicineReminderRemoteDataSource reminderDs;
  final MedicineRiskCheckRepository riskCheckRepository;

  @override
  Future<MedicineWorkspace> fetchWorkspace() async {
    final snapshot = await healthRepo.fetchHealthContext();
    final riskCheckResult = await riskCheckRepository.fetchForSnapshot(snapshot);
    final medicines = snapshot.currentMedicines
        .where((medicine) => medicine.isCurrent)
        .toList(growable: false);

    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final doseStatusByMedicine = <String, DoseLogStatus>{};
    try {
      final logs = await doseLogDs.fetchForDate(dateStr);
      for (final log in logs) {
        final medicineId = log.currentMedicineId;
        if (medicineId == null ||
            doseStatusByMedicine.containsKey(medicineId)) {
          continue;
        }
        if (log.status == DoseLogStatus.taken ||
            log.status == DoseLogStatus.skipped) {
          doseStatusByMedicine[medicineId] = log.status;
        }
      }
    } catch (_) {}

    final remindersByMedicine = <String, List<MedicineReminderItem>>{};
    try {
      final reminders = await reminderDs.fetchActive();
      for (final reminder in reminders) {
        final medicineId = reminder.currentMedicineId;
        if (medicineId == null || !reminder.matchesDate(today)) continue;
        remindersByMedicine.putIfAbsent(medicineId, () => []).add(reminder);
      }
      for (final reminders in remindersByMedicine.values) {
        reminders.sort(_compareReminderTime);
      }
    } catch (_) {}

    final planItems = medicines.map((m) {
      final doseStatus = doseStatusByMedicine[m.id];
      final todayStatus = switch (doseStatus) {
        DoseLogStatus.taken => MedicineDoseStatus.taken,
        DoseLogStatus.skipped => MedicineDoseStatus.skipped,
        _ => MedicineDoseStatus.pending,
      };
      final stateKey = switch (doseStatus) {
        DoseLogStatus.taken => MedicineCopyKey.doseStatusTaken,
        DoseLogStatus.skipped => MedicineCopyKey.doseStatusSkipped,
        _ => MedicineCopyKey.doseStatusPending,
      };
      final stateColor = switch (doseStatus) {
        DoseLogStatus.taken => AppColorTokens.success,
        DoseLogStatus.skipped => AppColorTokens.warningDeep,
        _ => AppColorTokens.warning,
      };
      return MedicinePlanItem(
        color: AppColorTokens.link,
        nameKey: MedicineCopyKey.mockNameMetformin,
        dosageKey: MedicineCopyKey.mockDoseMetformin,
        scheduleKey: MedicineCopyKey.mockScheduleMorningEvening,
        stateKey: stateKey,
        stateColor: stateColor,
        slots: (remindersByMedicine[m.id] ?? const <MedicineReminderItem>[])
            .map(
              (reminder) => MedicineDoseSlot(
                rawTime: reminder.timeLabel,
                statusKey: stateKey,
                status: todayStatus,
              ),
            )
            .toList(growable: false),
        todayStatus: todayStatus,
        rawName: m.displayName,
        rawDosage: m.strengthText ?? '',
        rawSchedule: m.doseText ?? '',
        currentMedicineId: m.id,
      );
    }).toList();

    final pendingItems = planItems
        .where((item) => item.todayStatus == MedicineDoseStatus.pending)
        .toList(growable: false);
    final completedCount = planItems.length - pendingItems.length;

    return MedicineWorkspace(
      hero: MedicineHero(
        metricDosesToday: '${planItems.length}',
        metricAdherence: _formatAdherence(completedCount, planItems.length),
        metricNextDose: _nextPendingSlotTime(pendingItems) ?? '--',
      ),
      quickActions: _defaultQuickActions(),
      plan: MedicinePlanSurface(items: planItems),
      alerts: const [],
      promisePoints: _defaultPromisePoints(),
      riskCheckResult: riskCheckResult,
    );
  }

  static String _formatAdherence(int completedCount, int totalCount) {
    if (totalCount == 0) return '--';
    return '${((completedCount / totalCount) * 100).round()}%';
  }

  static int _compareReminderTime(
    MedicineReminderItem left,
    MedicineReminderItem right,
  ) {
    final hour = left.scheduledHour.compareTo(right.scheduledHour);
    if (hour != 0) return hour;
    return left.scheduledMinute.compareTo(right.scheduledMinute);
  }

  static String? _nextPendingSlotTime(List<MedicinePlanItem> pendingItems) {
    for (final item in pendingItems) {
      for (final slot in item.slots) {
        if (slot.status == MedicineDoseStatus.pending) {
          return slot.rawTime;
        }
      }
    }
    return null;
  }

  static List<MedicineQuickAction> _defaultQuickActions() => const [
    MedicineQuickAction(
      icon: Icons.search_rounded,
      titleKey: MedicineCopyKey.quickActionSearchTitle,
      subtitleKey: MedicineCopyKey.quickActionSearchSubtitle,
      accent: AppColorTokens.cyanDeep,
    ),
  ];

  // Deferred by Product_Vision MVP: keep scan/OCR quick-action shapes because
  // they are useful later, but do not surface them until the matching camera,
  // recognition, and prescription contract/product job is ready.
  static const deferredScanQuickActions = <MedicineQuickAction>[
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

  static List<MedicinePromisePoint> _defaultPromisePoints() => const [
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointBoundary),
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointSpecialGroup),
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPrivacy),
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointDiagnosis),
  ];
}

import 'dart:io';
import 'package:clock/clock.dart';
import 'package:forui/forui.dart';

import 'package:flutter/foundation.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/logger/app_logger.dart';
import 'package:luminous/features/health_context/domain/repositories/repository.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart'
    show DoseLogItem, DoseLogRemoteDataSource, DoseLogStatus;
import 'package:luminous/features/medicine/data/datasources/reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check_repository.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace_repository.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';

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
    final riskCheckResult = await riskCheckRepository.fetchForSnapshot(
      snapshot,
    );
    final medicines = snapshot.currentMedicines
        .where((medicine) => medicine.isCurrent)
        .toList(growable: false);

    final today = clock.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final doseStatusByMedicine = <String, DoseLogStatus>{};
    final doseStatusBySlot = <String, DoseLogStatus>{};
    try {
      final logs = await doseLogDs.fetchForDate(dateStr);
      for (final log in logs) {
        final medicineId = log.currentMedicineId;
        if (log.status == DoseLogStatus.taken ||
            log.status == DoseLogStatus.skipped) {
          final slotKey = _doseLogSlotKey(log);
          if (slotKey != null) {
            doseStatusBySlot[slotKey] = log.status;
          }
          if (medicineId != null &&
              !doseStatusByMedicine.containsKey(medicineId)) {
            doseStatusByMedicine[medicineId] = log.status;
          }
        }
      }
    } catch (e) {
      appTalker.error(
        'LucentMedicineWorkspace.fetchWorkspace: dose logs failed: $e',
      );
    }

    final remindersByMedicine = <String, List<MedicineReminderItem>>{};
    try {
      final reminders = await reminderDs.fetchActive();
      for (final reminder in reminders) {
        final medicineId = reminder.currentMedicineId;
        if (medicineId == null || !reminder.matchesDate(today)) continue;
        remindersByMedicine.putIfAbsent(medicineId, () => []).add(reminder);
      }
      for (final reminders in remindersByMedicine.values) {
        reminders.sort(compareReminderTime);
      }
    } catch (e) {
      appTalker.error(
        'LucentMedicineWorkspace.fetchWorkspace: reminders failed: $e',
      );
    }

    final planItems = medicines.map((m) {
      final reminders =
          remindersByMedicine[m.id] ?? const <MedicineReminderItem>[];
      final fallbackStatus = doseStatusByMedicine[m.id];
      final slots = reminders
          .map(
            (reminder) => MedicineDoseSlot(
              reminderId: reminder.id,
              scheduledTime: reminder.timeLabel,
              rawTime: reminder.timeLabel,
              statusKey: _slotStateKey(
                _slotStatusForReminder(
                  reminder: reminder,
                  reminderCount: reminders.length,
                  doseStatusBySlot: doseStatusBySlot,
                  fallbackStatus: fallbackStatus,
                ),
              ),
              status: _slotStatusForReminder(
                reminder: reminder,
                reminderCount: reminders.length,
                doseStatusBySlot: doseStatusBySlot,
                fallbackStatus: fallbackStatus,
              ),
            ),
          )
          .toList(growable: false);
      final todayStatus = slots.isEmpty
          ? _medicineStatusFromDoseLog(fallbackStatus)
          : _aggregateSlotStatuses(slots);
      final stateKey = _slotStateKey(todayStatus);
      final stateColor = _stateColor(todayStatus);
      return MedicinePlanItem(
        color: AppColors.primary,
        nameKey: MedicineCopyKey.genericName,
        dosageKey: MedicineCopyKey.genericDosage,
        scheduleKey: MedicineCopyKey.genericSchedule,
        stateKey: stateKey,
        stateColor: stateColor,
        slots: slots,
        todayStatus: todayStatus,
        rawName: m.displayName,
        rawDosage: m.strengthText ?? '',
        rawSchedule: m.doseText ?? '',
        currentMedicineId: m.id,
      );
    }).toList();

    final totalDoseCount = planItems.fold<int>(
      0,
      (sum, item) => sum + _plannedDoseCount(item),
    );
    final completedCount = planItems.fold<int>(
      0,
      (sum, item) => sum + _completedDoseCount(item),
    );

    return MedicineWorkspace(
      hero: MedicineHero(
        metricDosesToday: '$totalDoseCount',
        metricAdherence: _formatAdherence(completedCount, totalDoseCount),
        metricNextDose: _nextPendingSlotTime(planItems) ?? '--',
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

  static String? _nextPendingSlotTime(List<MedicinePlanItem> items) {
    for (final item in items) {
      for (final slot in item.slots) {
        if (slot.status == MedicineDoseStatus.pending) {
          return slot.rawTime;
        }
      }
    }
    return null;
  }

  static List<MedicineQuickAction> _defaultQuickActions() => [
    const MedicineQuickAction(
      icon: FLucideIcons.search,
      titleKey: MedicineCopyKey.quickActionSearchTitle,
      subtitleKey: MedicineCopyKey.quickActionSearchSubtitle,
      accent: AppColors.primary,
    ),
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
      ..._mobileScanQuickActions,
  ];

  // Camera recognition and barcode scan are live on mobile devices.
  // Prescription import remains deferred pending OCR/contract work.
  static final _mobileScanQuickActions = <MedicineQuickAction>[
    const MedicineQuickAction(
      icon: FLucideIcons.camera,
      titleKey: MedicineCopyKey.quickActionCameraTitle,
      subtitleKey: MedicineCopyKey.quickActionCameraSubtitle,
      accent: AppColors.primary,
    ),
    const MedicineQuickAction(
      icon: FLucideIcons.scanLine,
      titleKey: MedicineCopyKey.quickActionBarcodeTitle,
      subtitleKey: MedicineCopyKey.quickActionBarcodeSubtitle,
      accent: AppColors.primary,
    ),
    const MedicineQuickAction(
      icon: FLucideIcons.receiptText,
      titleKey: MedicineCopyKey.quickActionPrescriptionTitle,
      subtitleKey: MedicineCopyKey.quickActionPrescriptionSubtitle,
      accent: AppColors.primary,
    ),
  ];

  static List<MedicinePromisePoint> _defaultPromisePoints() => const [
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointBoundary),
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointSpecialGroup),
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointPrivacy),
    MedicinePromisePoint(copyKey: MedicineCopyKey.promisePointDiagnosis),
  ];

  @override
  Future<MedicineWorkspace> get signedOutWorkspace =>
      Future.value(MedicineWorkspace.signedOut());
}

String? _doseLogSlotKey(DoseLogItem log) {
  final scheduledTime = log.scheduledTime?.trim();
  final reminderId = log.reminderId?.trim();
  if (reminderId != null && reminderId.isNotEmpty && scheduledTime != null) {
    return '$reminderId|$scheduledTime';
  }

  final medicineId = log.currentMedicineId?.trim();
  if (medicineId != null && medicineId.isNotEmpty && scheduledTime != null) {
    return '$medicineId|$scheduledTime';
  }
  return null;
}

String _reminderSlotKey(MedicineReminderItem reminder) {
  return '${reminder.id}|${reminder.timeLabel}';
}

MedicineDoseStatus _slotStatusForReminder({
  required MedicineReminderItem reminder,
  required int reminderCount,
  required Map<String, DoseLogStatus> doseStatusBySlot,
  required DoseLogStatus? fallbackStatus,
}) {
  final slotStatus = doseStatusBySlot[_reminderSlotKey(reminder)];
  if (slotStatus != null) {
    return _medicineStatusFromDoseLog(slotStatus);
  }

  if (reminderCount == 1 && fallbackStatus != null) {
    return _medicineStatusFromDoseLog(fallbackStatus);
  }

  return MedicineDoseStatus.pending;
}

MedicineDoseStatus _medicineStatusFromDoseLog(DoseLogStatus? status) {
  return switch (status) {
    DoseLogStatus.taken => MedicineDoseStatus.taken,
    DoseLogStatus.skipped => MedicineDoseStatus.skipped,
    _ => MedicineDoseStatus.pending,
  };
}

MedicineDoseStatus _aggregateSlotStatuses(List<MedicineDoseSlot> slots) {
  if (slots.any((slot) => slot.status == MedicineDoseStatus.pending)) {
    return MedicineDoseStatus.pending;
  }
  if (slots.every((slot) => slot.status == MedicineDoseStatus.taken)) {
    return MedicineDoseStatus.taken;
  }
  return MedicineDoseStatus.skipped;
}

MedicineCopyKey _slotStateKey(MedicineDoseStatus status) {
  return switch (status) {
    MedicineDoseStatus.taken => MedicineCopyKey.doseStatusTaken,
    MedicineDoseStatus.skipped => MedicineCopyKey.doseStatusSkipped,
    MedicineDoseStatus.pending => MedicineCopyKey.doseStatusPending,
  };
}

AppColors _stateColor(MedicineDoseStatus status) {
  return switch (status) {
    MedicineDoseStatus.taken => AppColors.primary,
    MedicineDoseStatus.skipped => AppColors.primary,
    MedicineDoseStatus.pending => AppColors.primary,
  };
}

int _plannedDoseCount(MedicinePlanItem item) {
  if (item.slots.isNotEmpty) {
    return item.slots.length;
  }
  return 1;
}

int _completedDoseCount(MedicinePlanItem item) {
  if (item.slots.isNotEmpty) {
    return item.slots
        .where((slot) => slot.status != MedicineDoseStatus.pending)
        .length;
  }
  return item.todayStatus == MedicineDoseStatus.pending ? 0 : 1;
}

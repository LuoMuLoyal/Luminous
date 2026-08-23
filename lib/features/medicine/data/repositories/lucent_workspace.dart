import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart'
    show DoseLogItem, DoseLogRemoteDataSource, DoseLogStatus;
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';

/// Lucent-backed [MedicineWorkspaceRepository] that derives the medicine
/// workspace from the current user's real health-context data.
///
/// Repository boundary: the health-context snapshot is the primary
/// dependency — its failure is a `TaskEither` Left. The risk records, dose
/// logs and reminders are secondary dashboard inputs: their failures degrade
/// to empty/null and are observed via [appTalker] (product behaviour, same as
/// the today dashboard degrade), never surfaced as a workspace failure.
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
  TaskEither<LucentFailure, MedicineWorkspace> fetchWorkspace() {
    return TaskEither.tryCatch(() async {
      final result = await healthRepo.fetchHealthContext().run();
      final snapshot = result.fold(
        (failure) => throw failure,
        (value) => value,
      );
      MedicineRiskCheckRecords? riskRecords;
      final riskResult = await riskCheckRepository.getRecords().run();
      riskResult.fold(
        (failure) => appTalker.error(
          'LucentMedicineWorkspace.fetchWorkspace: risk records failed: '
          '$failure',
        ),
        (records) => riskRecords = records,
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
      final remindersResult = await reminderDs.fetchActive().run();
      remindersResult.fold(
        (failure) => appTalker.error(
          'LucentMedicineWorkspace.fetchWorkspace: reminders failed: $failure',
        ),
        (reminders) {
          for (final reminder in reminders) {
            final medicineId = reminder.currentMedicineId;
            if (medicineId == null || !reminder.matchesDate(today)) continue;
            remindersByMedicine.putIfAbsent(medicineId, () => []).add(reminder);
          }
          for (final reminders in remindersByMedicine.values) {
            reminders.sort(compareReminderTime);
          }
        },
      );

      final planItems = medicines.map((m) {
        final reminders =
            remindersByMedicine[m.id] ?? const <MedicineReminderItem>[];
        final fallbackStatus = doseStatusByMedicine[m.id];
        final slots = reminders
            .map((reminder) {
              final status = _slotStatusForReminder(
                reminder: reminder,
                doseStatusBySlot: doseStatusBySlot,
              );
              return MedicineDoseSlot(
                reminderId: reminder.id,
                scheduledTime: reminder.timeLabel,
                rawTime: reminder.timeLabel,
                statusKey: _slotStateKey(status),
                status: status,
                // F-5 P1: 「已到期」= 当前墙钟 >= 槽位 HH:mm；不做 30 分钟宽限。
                // 宽限只影响后端漏服分类，不影响「到期」分母。未确认但未到期不判 overdue。
                isOverdue:
                    status == MedicineDoseStatus.pending &&
                    _isSlotDue(today, reminder),
              );
            })
            .toList(growable: false);
        final todayStatus = slots.isEmpty
            ? _medicineStatusFromDoseLog(fallbackStatus)
            : _aggregateSlotStatuses(slots);
        final stateKey = _slotStateKey(todayStatus);
        final stateColor = _stateColor(todayStatus);
        return MedicinePlanItem(
          color: SemanticColor.primary,
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

      // F-5 P1 统一口径：分母 = 已到期槽位（taken + skipped + overdue），
      // 分子 = taken（skipped 计入分母不计分子）；未到期槽位不计入分母。
      // metricDosesToday 为 F-17 已标注死字段，继续填「今日计划槽位总数」。
      final totalDoseCount = planItems.fold<int>(
        0,
        (sum, item) => sum + item.slots.length,
      );
      final dueTakenCount = planItems.fold<int>(
        0,
        (sum, item) => sum + _dueTakenCount(item),
      );
      final dueSkippedCount = planItems.fold<int>(
        0,
        (sum, item) => sum + _dueSkippedCount(item),
      );
      final dueOverdueCount = planItems.fold<int>(
        0,
        (sum, item) => sum + _dueOverdueCount(item),
      );
      final dueTotalCount = dueTakenCount + dueSkippedCount + dueOverdueCount;

      return MedicineWorkspace(
        hero: MedicineHero(
          metricDosesToday: '$totalDoseCount',
          metricAdherence: _formatAdherence(dueTakenCount, dueTotalCount),
          metricNextDose: _nextPendingSlotTime(planItems) ?? '--',
        ),
        quickActions: _defaultQuickActions(),
        plan: MedicinePlanSurface(items: planItems),
        // TODO(archive): 历史占位字段，不再接入主路径——告警由 medicineAlertsFromRiskCheck
        // 从 riskCheckRecords 派生；无渲染消费方，保留为兼容，避免误用。
        alerts: const [],
        // TODO(archive): 历史 dashboard 原型残留，无渲染消费方，保留为兼容；若复用需先确认 UI 出口。
        promisePoints: _defaultPromisePoints(),
        riskCheckRecords: riskRecords,
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// F-5 P1：分子 = taken、分母 = 已到期槽位（taken + skipped + overdue）；
  /// 分母为 0 显示 '--'。
  static String _formatAdherence(int takenCount, int dueTotalCount) {
    if (dueTotalCount == 0) return '--';
    return '${((takenCount / dueTotalCount) * 100).round()}%';
  }

  /// 下一「未到期」pending 槽；已过时刻的 pending 槽（isOverdue）不算下一剂。
  static String? _nextPendingSlotTime(List<MedicinePlanItem> items) {
    for (final item in items) {
      for (final slot in item.slots) {
        if (slot.status == MedicineDoseStatus.pending && !slot.isOverdue) {
          return slot.rawTime;
        }
      }
    }
    return null;
  }

  static List<MedicineQuickAction> _defaultQuickActions() => [
    const MedicineQuickAction(
      icon: SemanticIcons.actionSearch,
      titleKey: MedicineCopyKey.quickActionSearchTitle,
      subtitleKey: MedicineCopyKey.quickActionSearchSubtitle,
      accent: SemanticColor.primary,
    ),
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
      ..._mobileScanQuickActions,
  ];

  // Camera recognition and barcode scan are live on mobile devices.
  // 处方导入入口已删除；OCR 处方识别为未来能力不排期（F-19）。
  static final _mobileScanQuickActions = <MedicineQuickAction>[
    const MedicineQuickAction(
      icon: SemanticIcons.actionCamera,
      titleKey: MedicineCopyKey.quickActionCameraTitle,
      subtitleKey: MedicineCopyKey.quickActionCameraSubtitle,
      accent: SemanticColor.primary,
    ),
    const MedicineQuickAction(
      icon: SemanticIcons.actionScan,
      titleKey: MedicineCopyKey.quickActionBarcodeTitle,
      subtitleKey: MedicineCopyKey.quickActionBarcodeSubtitle,
      accent: SemanticColor.primary,
    ),
  ];

  // TODO(archive): 历史 dashboard 原型残留，无渲染消费方，保留为兼容；若复用需先确认 UI 出口。
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
  required Map<String, DoseLogStatus> doseStatusBySlot,
}) {
  final slotStatus = doseStatusBySlot[_reminderSlotKey(reminder)];
  if (slotStatus != null) {
    return _medicineStatusFromDoseLog(slotStatus);
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

SemanticColor _stateColor(MedicineDoseStatus status) {
  return switch (status) {
    MedicineDoseStatus.taken => SemanticColor.success,
    MedicineDoseStatus.skipped => SemanticColor.neutral,
    MedicineDoseStatus.pending => SemanticColor.warning,
  };
}

/// F-5 P1：「已到期」判定 = 当前墙钟 >= 槽位 HH:mm。时区沿用 `clock.now()`
/// 设备本地墙钟（与既有 `dateStr`、`reminder.matchesDate(today)` 一致）；
/// profile timezone 对齐留给 F-5 P2 后端统计对象。
bool _isSlotDue(DateTime now, MedicineReminderItem reminder) =>
    now.hour > reminder.scheduledHour ||
    (now.hour == reminder.scheduledHour &&
        now.minute >= reminder.scheduledMinute);

int _dueTakenCount(MedicinePlanItem item) {
  return item.slots
      .where((slot) => slot.status == MedicineDoseStatus.taken)
      .length;
}

int _dueSkippedCount(MedicinePlanItem item) {
  return item.slots
      .where((slot) => slot.status == MedicineDoseStatus.skipped)
      .length;
}

/// 无槽位药不计入分母（slots 为空时自然为 0）。
int _dueOverdueCount(MedicinePlanItem item) {
  return item.slots
      .where(
        (slot) => slot.isOverdue && slot.status == MedicineDoseStatus.pending,
      )
      .length;
}

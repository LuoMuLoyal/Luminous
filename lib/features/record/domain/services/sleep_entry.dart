import 'package:flutter/material.dart';

/// 睡眠类型。手动录入由用户显式选择；设备导入路径按时长推断。
enum SleepEntryKind {
  nightSleep,
  nap;

  /// payload `sleepType` 的线上取值。
  String get wireValue => switch (this) {
    SleepEntryKind.nightSleep => 'nightSleep',
    SleepEntryKind.nap => 'nap',
  };

  /// 解析 payload `sleepType`；只认 `nap`，其余（含缺失）一律视为夜间睡眠。
  static SleepEntryKind fromPayload(Object? value) {
    return value == 'nap' ? SleepEntryKind.nap : SleepEntryKind.nightSleep;
  }
}

/// 小睡时长上限，对齐业界 nap 定义 15 分钟–3 小时的上界。
const int kNapMaxDurationMinutes = 3 * 60;

/// 夜间睡眠时长上限；只用于挡住手滑，正常睡眠不会超过 16 小时。
const int kNightSleepMaxDurationMinutes = 16 * 60;

/// 由「就寝/起床时刻」解出的睡眠时段，全部为本地时间。
@immutable
class SleepWindow {
  const SleepWindow({
    required this.startedAt,
    required this.endedAt,
    required this.durationMinutes,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final int durationMinutes;
}

/// 就寝/起床时刻的纯时钟差（分钟）。
///
/// 起床时刻早于就寝时刻时按跨午夜处理；两者相同返回 null，避免退化成
/// 24 小时睡眠。
int? computeSleepDurationMinutes(TimeOfDay? bedtime, TimeOfDay? wakeTime) {
  if (bedtime == null || wakeTime == null) return null;
  final bedMinutes = bedtime.hour * 60 + bedtime.minute;
  final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;
  var diff = wakeMinutes - bedMinutes;
  if (diff < 0) diff += 24 * 60;
  if (diff == 0) return null;
  return diff;
}

/// 解出睡眠时段。
///
/// [recordDate] 的语义是**起床日**（与后端 wake-date 约定一致）：
/// - [SleepEntryKind.nightSleep]：就寝时刻不早于起床时刻时落在前一天，一次睡眠
///   最多跨一个午夜；
/// - [SleepEntryKind.nap]：就寝必须与起床同日，跨午夜返回 null。
SleepWindow? resolveSleepWindow({
  required DateTime recordDate,
  required TimeOfDay bedtime,
  required TimeOfDay wakeTime,
  required SleepEntryKind kind,
}) {
  final durationMinutes = computeSleepDurationMinutes(bedtime, wakeTime);
  if (durationMinutes == null) return null;

  final wake = DateTime(
    recordDate.year,
    recordDate.month,
    recordDate.day,
    wakeTime.hour,
    wakeTime.minute,
  );
  var bed = DateTime(
    recordDate.year,
    recordDate.month,
    recordDate.day,
    bedtime.hour,
    bedtime.minute,
  );
  if (!bed.isBefore(wake)) {
    if (kind == SleepEntryKind.nap) return null;
    bed = bed.subtract(const Duration(days: 1));
  }

  return SleepWindow(
    startedAt: bed,
    endedAt: wake,
    durationMinutes: durationMinutes,
  );
}

/// 一次性睡眠录入的校验结果。
enum SleepEntryValidationError {
  missingTimes,
  wakeNotAfterBedtime,
  napCrossesMidnight,
  napTooLong,
  nightSleepTooLong,
}

/// 校验一次性睡眠录入；通过返回 null。
SleepEntryValidationError? validateSleepEntry({
  required TimeOfDay? bedtime,
  required TimeOfDay? wakeTime,
  required SleepEntryKind kind,
}) {
  if (bedtime == null || wakeTime == null) {
    return SleepEntryValidationError.missingTimes;
  }

  final durationMinutes = computeSleepDurationMinutes(bedtime, wakeTime);
  if (durationMinutes == null) {
    return SleepEntryValidationError.wakeNotAfterBedtime;
  }

  if (kind == SleepEntryKind.nap) {
    final bedMinutes = bedtime.hour * 60 + bedtime.minute;
    final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;
    if (bedMinutes > wakeMinutes) {
      return SleepEntryValidationError.napCrossesMidnight;
    }
    if (durationMinutes > kNapMaxDurationMinutes) {
      return SleepEntryValidationError.napTooLong;
    }
    return null;
  }

  if (durationMinutes > kNightSleepMaxDurationMinutes) {
    return SleepEntryValidationError.nightSleepTooLong;
  }
  return null;
}

/// 构建睡眠 payload。
///
/// 键位固定为 `startedAt` / `endedAt` / `durationMinutes` / `sleepType`，加上可选的
/// `quality` 与设备侧分期 `deepMinutes` / `lightMinutes` / `remMinutes`。
/// 时间不合法（缺失或时长为 0）时返回 null，调用方据此阻断保存。
Map<String, dynamic>? buildSleepPayload({
  required DateTime recordDate,
  required TimeOfDay? bedtime,
  required TimeOfDay? wakeTime,
  required SleepEntryKind kind,
  String? quality,
  int? deepMinutes,
  int? lightMinutes,
  int? remMinutes,
}) {
  if (bedtime == null || wakeTime == null) return null;
  final window = resolveSleepWindow(
    recordDate: recordDate,
    bedtime: bedtime,
    wakeTime: wakeTime,
    kind: kind,
  );
  if (window == null) return null;

  return <String, dynamic>{
    'startedAt': window.startedAt.toUtc().toIso8601String(),
    'endedAt': window.endedAt.toUtc().toIso8601String(),
    'durationMinutes': window.durationMinutes,
    'sleepType': kind.wireValue,
    if (quality != null) 'quality': quality,
    if (deepMinutes != null && deepMinutes > 0) 'deepMinutes': deepMinutes,
    if (lightMinutes != null && lightMinutes > 0) 'lightMinutes': lightMinutes,
    if (remMinutes != null && remMinutes > 0) 'remMinutes': remMinutes,
  };
}

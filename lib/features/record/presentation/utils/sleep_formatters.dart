import 'package:flutter/material.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 睡眠质量选项（payload `quality` 的线上取值 + 展示文案）。
class SleepQuality {
  const SleepQuality(this.key, this.label);

  final String key;
  final String label;
}

List<SleepQuality> sleepQualityOptions(AppLocalizations l10n) => [
  SleepQuality('poor', l10n.recordSleepQualityPoor),
  SleepQuality('fair', l10n.recordSleepQualityFair),
  SleepQuality('good', l10n.recordSleepQualityGood),
  SleepQuality('excellent', l10n.recordSleepQualityExcellent),
];

/// 睡眠时长文案：`8 小时` / `7 小时 30 分钟`。
String formatSleepDurationLabel(int minutes, AppLocalizations l10n) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '$h${l10n.todayVitalSleepUnit}';
  return '$h${l10n.todayVitalSleepUnit} $m${l10n.recordSleepMinutesUnit}';
}

/// 睡眠时段文案：`23:00 – 07:00`；任一时刻缺失返回 null。
String? formatSleepTimeRange(TimeOfDay? bedtime, TimeOfDay? wakeTime) {
  if (bedtime == null || wakeTime == null) return null;
  return '${formatSleepClock(bedtime)} – ${formatSleepClock(wakeTime)}';
}

/// 时刻文案：`HH:mm`。
String formatSleepClock(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

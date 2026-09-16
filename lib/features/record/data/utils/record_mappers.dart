import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/constants/meal_calorie_range.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/utils/meal_analysis_payload_parser.dart';

import 'record_static_data.dart';

/// Maps backend daily-record summaries into the dashboard summary grid.
///
/// Sparse semantics: kinds with `count <= 0` (unknown, not zero) and kinds
/// without summary copy infrastructure (symptom / sleep / note / activity)
/// produce no item. Water shows the canonical ml total aggregated from the
/// day's water records, falling back to the record count with the "times"
/// unit when no ml-denominated record exists so the badge never renders a
/// bare 0. Vital shows the latest record's value (e.g. "72 bpm") when the
/// summary carries a `latest` item with a value, falling back to the record
/// count with the "times" unit otherwise.
RecordDaySummary toDaySummary(
  DailyRecordSummaryData data,
  List<DailyRecordItem> records,
) {
  // Aggregate canonical ml from the day's water records (ml units only,
  // parseable positive values) — same rule as the detail-page progress card.
  var waterTotalMl = 0;
  for (final record in records) {
    if (record.kind == DailyRecordKind.water && record.unit == 'ml') {
      final value = int.tryParse(record.value ?? '');
      if (value != null && value > 0) waterTotalMl += value;
    }
  }

  const accent = SemanticColor.primary;
  const soft = SemanticColor.neutral;

  final items = <RecordSummaryItem>[];
  for (final summary in data.summaries) {
    if (summary.count <= 0) continue;
    final type = recordEntryTypeForDailyRecordKind(summary.kind);
    if (!isActiveRecordEntryType(type)) continue;

    switch (summary.kind) {
      case DailyRecordKind.water:
        final useMl = waterTotalMl > 0;
        items.add(
          RecordSummaryItem(
            type: type,
            icon: SemanticIcons.recordWater,
            titleKey: RecordCopyKey.summaryWaterTitle,
            value: useMl ? waterTotalMl.toString() : summary.count.toString(),
            unitKey: useMl
                ? RecordCopyKey.summaryMlUnit
                : RecordCopyKey.summaryTimesUnit,
            detailKey: null,
            accent: accent,
            softColor: soft,
          ),
        );
      case DailyRecordKind.meal:
        items.add(
          RecordSummaryItem(
            type: type,
            icon: SemanticIcons.recordMeal,
            titleKey: RecordCopyKey.summaryMealTitle,
            value: summary.count.toString(),
            unitKey: RecordCopyKey.summaryTimesUnit,
            detailKey: null,
            accent: accent,
            softColor: soft,
          ),
        );
      case DailyRecordKind.mood:
        items.add(
          RecordSummaryItem(
            type: type,
            icon: SemanticIcons.recordMood,
            titleKey: RecordCopyKey.summaryMoodTitle,
            value: summary.count.toString(),
            unitKey: RecordCopyKey.summaryTimesUnit,
            detailKey: null,
            accent: accent,
            softColor: soft,
          ),
        );
      case DailyRecordKind.vital:
        // Title is "最新体征": prefer the latest record's value with its
        // unit (e.g. "72 bpm") when present, falling back to the record
        // count with the "times" unit.
        final latest = summary.latest;
        final hasLatestValue =
            latest != null &&
            latest.value != null &&
            latest.value!.trim().isNotEmpty;
        items.add(
          RecordSummaryItem(
            type: type,
            icon: SemanticIcons.profileCondition,
            titleKey: RecordCopyKey.summaryLatestVitalTitle,
            value: hasLatestValue
                ? '${latest.value}${latest.unit != null && latest.unit!.trim().isNotEmpty ? ' ${latest.unit}' : ''}'
                : summary.count.toString(),
            unitKey: hasLatestValue ? null : RecordCopyKey.summaryTimesUnit,
            detailKey: null,
            accent: accent,
            softColor: soft,
          ),
        );
      case DailyRecordKind.symptom:
      case DailyRecordKind.activity:
      case DailyRecordKind.note:
      case DailyRecordKind.sleep:
        // No summary copy infrastructure for these kinds — do not fabricate
        // a tile (sparse-record semantics: unknown != 0).
        break;
    }
  }

  return RecordDaySummary(items: items);
}

/// Maps a daily record item into a timeline entry for display.
RecordTimelineEntry toTimelineEntry(DailyRecordItem record) {
  final kind = record.kind;
  final timeStr = formatRecordTimeLabel(record.occurredTime);

  const accent = SemanticColor.primary;
  const soft = SemanticColor.neutral;

  final icon = switch (kind) {
    DailyRecordKind.water => SemanticIcons.recordWater,
    DailyRecordKind.meal => SemanticIcons.recordMeal,
    DailyRecordKind.vital => SemanticIcons.profileCondition,
    DailyRecordKind.mood => SemanticIcons.recordMood,
    DailyRecordKind.symptom => SemanticIcons.safetyDanger,
    DailyRecordKind.activity => SemanticIcons.recordActivity,
    DailyRecordKind.note => SemanticIcons.tabRecord,
    DailyRecordKind.sleep => SemanticIcons.recordMoon,
  };

  // Mood records created through the fast-entry dialog store the level in
  // the payload, so expose a readable subtitle such as "情绪 · 不错".
  final moodValueKey = moodValueKeyFor(kind, record.payload);
  final mealView = kind == DailyRecordKind.meal
      ? parseMealAnalysisViewData(record.payload)
      : null;

  final titleKey = switch (kind) {
    DailyRecordKind.water => RecordCopyKey.typeWater,
    DailyRecordKind.meal => RecordCopyKey.typeMeal,
    DailyRecordKind.vital => RecordCopyKey.typeVitals,
    DailyRecordKind.mood => RecordCopyKey.typeMood,
    DailyRecordKind.symptom => RecordCopyKey.typeSymptom,
    DailyRecordKind.activity => RecordCopyKey.typeActivity,
    DailyRecordKind.note => RecordCopyKey.typeNote,
    DailyRecordKind.sleep => RecordCopyKey.typeSleep,
  };

  // For notes and mood records without a real title, leave rawTitle null so
  // the timeline resolves through the localized titleKey (or uses note
  // content as a short preview). Other kinds keep the existing "kind value"
  // fallback.
  final String? rawTitle;
  if (record.title != null) {
    rawTitle = record.title;
  } else if (kind == DailyRecordKind.meal && record.mealHeadline != null) {
    rawTitle = record.mealHeadline;
  } else if (kind == DailyRecordKind.note || kind == DailyRecordKind.mood) {
    rawTitle = null;
  } else {
    rawTitle = '${kind.name} ${record.value ?? ''}'.trim();
  }

  // 餐食条目:第二行给完整一点的那条结论,右侧角标给粗化后的热量区间
  // (数据层只给数字,文案由视图层本地化)。
  final mealInsight = kind == DailyRecordKind.meal
      ? mealView?.items.firstOrNull
      : null;
  final mealValue = kind == DailyRecordKind.meal
      ? (mealInsight?.detail ?? record.value ?? record.note)
      : null;
  final mealCalorieLabel = kind == DailyRecordKind.meal
      ? _mealCalorieLabel(record)
      : null;

  return RecordTimelineEntry(
    time: timeStr,
    type: recordEntryTypeForDailyRecordKind(kind),
    icon: icon,
    accent: accent,
    softColor: soft,
    titleKey: titleKey,
    rawTitle: rawTitle,
    value: kind == DailyRecordKind.meal
        ? mealValue
        : record.value != null
        ? '${record.value}${record.unit != null ? ' ${record.unit}' : ''}'
        : sleepPayloadValue(kind, record.payload) ?? record.note,
    valueKey: moodValueKey,
    rawDetail: null,
    detailKey: record.note != null && record.value != null ? null : null,
    badgeKey: mealBadgeKey(record),
    mealCalorieLabel: mealCalorieLabel,
    imageUrl: record.attachments
        .where(
          (attachment) => attachment.kind == DailyRecordAttachmentKind.image,
        )
        .map((attachment) => attachment.displayUrl)
        .whereType<String>()
        .firstOrNull,
    recordId: record.id,
  );
}

/// Returns a compact sleep-duration display string (e.g. "7h 30m")
/// extracted from the sleep payload, or null when the record is not a
/// sleep record or has no usable duration data.
String? sleepPayloadValue(DailyRecordKind kind, Map<String, dynamic>? payload) {
  if (kind != DailyRecordKind.sleep || payload == null) return null;
  final minutes = payload['durationMinutes'];
  if (minutes is! num || minutes <= 0) return null;
  final h = minutes ~/ 60;
  final m = minutes.round() % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

/// Returns the localized copy key for a mood record's value line
/// (e.g. "情绪 · 不错"), or null when the record is not a mood record or has
/// no usable mood data.
RecordCopyKey? moodValueKeyFor(
  DailyRecordKind kind,
  Map<String, dynamic>? payload,
) {
  if (kind != DailyRecordKind.mood || payload == null) return null;
  final label = payload['moodLabel'];
  if (label is! String) return null;
  return switch (label) {
    'great' => RecordCopyKey.timelineMoodGreat,
    'good' => RecordCopyKey.timelineMoodGood,
    'okay' => RecordCopyKey.timelineMoodOkay,
    'bad' => RecordCopyKey.timelineMoodBad,
    'terrible' => RecordCopyKey.timelineMoodTerrible,
    _ => null,
  };
}

RecordCopyKey? mealBadgeKey(DailyRecordItem record) {
  if (record.kind != DailyRecordKind.meal) return null;
  return switch (record.mealAnalysisStatus) {
    'analyzing' => RecordCopyKey.timelineMealAnalyzingBadge,
    'analysis_failed' => RecordCopyKey.timelineMealFailedBadge,
    // 「已分析」不再有角标:右侧位置留给热量区间,结论本身就在标题行。
    _ => null,
  };
}

/// 粗化到百位的区间文案(只有数字与连接符);缺任一端时返回 null。
String? _mealCalorieLabel(DailyRecordItem record) {
  final min = record.mealCalorieMin;
  final max = record.mealCalorieMax;
  if (min == null || max == null) return null;
  return formatCoarseCalorieRange(min: min, max: max);
}

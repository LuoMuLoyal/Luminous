import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';

/// Returns whether the given record entry type is currently active in the UI.
bool isActiveRecordEntryType(RecordEntryType type) {
  return switch (type) {
    RecordEntryType.symptom ||
    RecordEntryType.water ||
    RecordEntryType.meal ||
    RecordEntryType.sleep ||
    RecordEntryType.medication ||
    RecordEntryType.mood ||
    RecordEntryType.note ||
    RecordEntryType.vitals ||
    RecordEntryType.activity => true,
    _ => false,
  };
}

/// Generates a static list of calendar days for the given month.
List<RecordCalendarDay> staticMonthDays(DateTime today) {
  final first = DateTime(today.year, today.month, 1);
  final last = DateTime(today.year, today.month + 1, 0);
  final startOffset = first.weekday - 1;
  final days = <RecordCalendarDay>[];
  for (var i = 0; i < startOffset; i++) {
    days.add(
      const RecordCalendarDay(
        day: 0,
        inMonth: false,
        selected: false,
        markers: [],
      ),
    );
  }
  for (var d = 1; d <= last.day; d++) {
    days.add(
      RecordCalendarDay(
        day: d,
        inMonth: true,
        selected: d == today.day,
        markers: d == today.day ? [SemanticColor.primary] : [],
      ),
    );
  }
  return days;
}

/// Static list of quick actions for the record dashboard.
const List<RecordQuickAction> staticQuickActions = [
  RecordQuickAction(
    type: RecordEntryType.symptom,
    icon: SemanticIcons.medicineKit,
    titleKey: RecordCopyKey.typeSymptom,
    subtitleKey: RecordCopyKey.summaryRecorded,
    accent: SemanticColor.primary,
    softColor: SemanticColor.neutral,
  ),
  RecordQuickAction(
    type: RecordEntryType.medication,
    icon: SemanticIcons.recordMedicine,
    titleKey: RecordCopyKey.typeMedication,
    subtitleKey: RecordCopyKey.summaryRecorded,
    accent: SemanticColor.primary,
    softColor: SemanticColor.neutral,
  ),
  // Lightweight mood self-check-in quick action.
  RecordQuickAction(
    type: RecordEntryType.mood,
    icon: SemanticIcons.recordMood,
    titleKey: RecordCopyKey.typeMood,
    subtitleKey: RecordCopyKey.summaryRecorded,
    accent: SemanticColor.primary,
    softColor: SemanticColor.neutral,
  ),
  RecordQuickAction(
    type: RecordEntryType.meal,
    icon: SemanticIcons.recordMeal,
    titleKey: RecordCopyKey.typeMeal,
    subtitleKey: RecordCopyKey.summaryRecorded,
    accent: SemanticColor.primary,
    softColor: SemanticColor.neutral,
  ),
  RecordQuickAction(
    type: RecordEntryType.water,
    icon: SemanticIcons.recordWater,
    titleKey: RecordCopyKey.typeWater,
    subtitleKey: RecordCopyKey.summaryCupsUnit,
    accent: SemanticColor.primary,
    softColor: SemanticColor.neutral,
  ),
  RecordQuickAction(
    type: RecordEntryType.vitals,
    icon: SemanticIcons.profileCondition,
    titleKey: RecordCopyKey.typeVitals,
    subtitleKey: RecordCopyKey.summaryNormal,
    accent: SemanticColor.primary,
    softColor: SemanticColor.neutral,
  ),
  RecordQuickAction(
    type: RecordEntryType.sleep,
    icon: SemanticIcons.recordMoon,
    titleKey: RecordCopyKey.typeSleep,
    subtitleKey: RecordCopyKey.summaryRecorded,
    accent: SemanticColor.primary,
    softColor: SemanticColor.neutral,
  ),
  RecordQuickAction(
    type: RecordEntryType.note,
    icon: SemanticIcons.tabRecord,
    titleKey: RecordCopyKey.typeNote,
    subtitleKey: RecordCopyKey.summaryRecorded,
    accent: SemanticColor.primary,
    softColor: SemanticColor.neutral,
  ),
];

/// Returns the filtered list of quick actions based on active entry types.
List<RecordQuickAction> filteredQuickActions() {
  return staticQuickActions
      .where((action) => isActiveRecordEntryType(action.type))
      .toList(growable: false);
}

/// Static list of filters for the record dashboard.
const List<RecordFilter> staticFilters = [
  RecordFilter(
    type: RecordEntryType.medication,
    titleKey: RecordCopyKey.typeMedication,
    icon: SemanticIcons.recordMedicine,
    accent: SemanticColor.primary,
    selected: true,
  ),
  RecordFilter(
    type: RecordEntryType.symptom,
    titleKey: RecordCopyKey.typeSymptom,
    icon: SemanticIcons.medicineKit,
    accent: SemanticColor.primary,
    selected: true,
  ),
  RecordFilter(
    type: RecordEntryType.mood,
    titleKey: RecordCopyKey.typeMood,
    icon: SemanticIcons.recordMood,
    accent: SemanticColor.primary,
    selected: true,
  ),
  RecordFilter(
    type: RecordEntryType.water,
    titleKey: RecordCopyKey.typeWater,
    icon: SemanticIcons.recordWater,
    accent: SemanticColor.primary,
    selected: true,
  ),
  RecordFilter(
    type: RecordEntryType.meal,
    titleKey: RecordCopyKey.typeMeal,
    icon: SemanticIcons.recordMeal,
    accent: SemanticColor.primary,
    selected: true,
  ),
  RecordFilter(
    type: RecordEntryType.vitals,
    titleKey: RecordCopyKey.typeVitals,
    icon: SemanticIcons.profileCondition,
    accent: SemanticColor.primary,
    selected: true,
  ),
  RecordFilter(
    type: RecordEntryType.sleep,
    titleKey: RecordCopyKey.typeSleep,
    icon: SemanticIcons.recordMoon,
    accent: SemanticColor.primary,
    selected: true,
  ),
  RecordFilter(
    type: RecordEntryType.note,
    titleKey: RecordCopyKey.typeNote,
    icon: SemanticIcons.tabRecord,
    accent: SemanticColor.primary,
    selected: true,
  ),
];

/// Returns the filtered list of filters based on active entry types,
/// with the selected state updated according to [filterType].
List<RecordFilter> filteredFilters(RecordEntryType? filterType) {
  final filters = staticFilters.where(
    (filter) => isActiveRecordEntryType(filter.type),
  );

  return filters
      .map(
        (filter) => RecordFilter(
          type: filter.type,
          titleKey: filter.titleKey,
          icon: filter.icon,
          accent: filter.accent,
          selected: filterType == null || filter.type == filterType,
          locked: filter.locked,
        ),
      )
      .toList(growable: false);
}

/// Static list of trends for the record dashboard.
const List<RecordTrend> staticTrends = [
  RecordTrend(
    kind: RecordTrendKind.bloodSugar,
    titleKey: RecordCopyKey.trendBloodSugarTitle,
    rangeKey: RecordCopyKey.range7Days,
    color: SemanticColor.primary,
    points: [5.1, 5.8, 5.4, 6.2, 5.6, 6.5, 5.9],
    legendKey: RecordCopyKey.trendBloodSugarLegend,
  ),
];

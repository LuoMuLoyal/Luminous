import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class RecordMobileOverviewItem {
  const RecordMobileOverviewItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const mobileOverviewTypeOrder = <RecordEntryType>[
  RecordEntryType.symptom,
  RecordEntryType.water,
  RecordEntryType.meal,
  RecordEntryType.sleep,
  RecordEntryType.medication,
  RecordEntryType.note,
];

// ---------------------------------------------------------------------------
// Helper functions
// ---------------------------------------------------------------------------

bool isActiveMobileOverviewType(RecordEntryType type) {
  return mobileOverviewTypeOrder.contains(type);
}

List<RecordQuickAction> buildMobileQuickActions(
  List<RecordQuickAction> actions,
) {
  final preferredTypes = <RecordEntryType>[
    RecordEntryType.symptom,
    RecordEntryType.water,
    RecordEntryType.meal,
    RecordEntryType.sleep,
    RecordEntryType.medication,
    RecordEntryType.note,
  ];
  final byType = {for (final action in actions) action.type: action};
  final ordered = <RecordQuickAction>[
    for (final type in preferredTypes)
      if (byType[type] != null) byType[type]!,
  ];
  for (final action in actions) {
    if (!ordered.contains(action)) ordered.add(action);
  }
  return ordered.toList(growable: false);
}

List<RecordFilter> buildMobileFilters(List<RecordFilter> filters) {
  const preferredTypes = <RecordEntryType>[
    RecordEntryType.symptom,
    RecordEntryType.water,
    RecordEntryType.meal,
    RecordEntryType.sleep,
    RecordEntryType.medication,
    RecordEntryType.note,
  ];
  final byType = {for (final filter in filters) filter.type: filter};
  final ordered = <RecordFilter>[
    for (final type in preferredTypes)
      if (byType[type] != null) byType[type]!,
  ];
  for (final filter in filters) {
    if (!ordered.contains(filter)) ordered.add(filter);
  }
  return ordered.toList(growable: false);
}

List<RecordMobileOverviewItem> buildMobileOverviewItems(
  AppLocalizations l10n,
  RecordDashboard dashboard,
) {
  final activeSummaryItems = dashboard.summary.items
      .where((item) => isActiveMobileOverviewType(item.type))
      .toList(growable: false);
  final summaryByType = {
    for (final item in activeSummaryItems) item.type: item,
  };
  final countsByType = <RecordEntryType, int>{};
  for (final entry in dashboard.timeline) {
    if (!isActiveMobileOverviewType(entry.type)) continue;
    countsByType.update(entry.type, (value) => value + 1, ifAbsent: () => 1);
  }

  final items = <RecordMobileOverviewItem>[
    RecordMobileOverviewItem(
      icon: Icons.event_note_outlined,
      color: AppColorTokens.link,
      label: l10n.recordTodayOverviewEvents,
      value: l10n.recordTodayOverviewEventCount(dashboard.timeline.length),
    ),
  ];

  for (final type in mobileOverviewTypeOrder) {
    final summary = summaryByType[type];
    final count = countsByType[type] ?? 0;
    if (summary == null && count == 0) continue;
    items.add(overviewItemFor(l10n, type, summary, count));
  }

  return items;
}

RecordMobileOverviewItem overviewItemFor(
  AppLocalizations l10n,
  RecordEntryType type,
  RecordSummaryItem? summary,
  int count,
) {
  final label = summary == null
      ? overviewFallbackLabel(l10n, type)
      : recordCopy(l10n, summary.titleKey);
  final value = summary == null
      ? l10n.recordTodayOverviewEventCount(count)
      : summaryValue(l10n, summary);

  return RecordMobileOverviewItem(
    icon: summary?.icon ?? overviewFallbackIcon(type),
    color: summary?.accent ?? overviewFallbackColor(type),
    label: label,
    value: value,
  );
}

String summaryValue(AppLocalizations l10n, RecordSummaryItem item) {
  final value = item.value.trim();
  final unit = item.unitKey == null ? null : recordCopy(l10n, item.unitKey!);
  final detail = item.detailKey == null
      ? null
      : recordCopy(l10n, item.detailKey!);
  if (value.isNotEmpty) return unit == null ? value : '$value $unit';
  if (detail != null && detail.isNotEmpty) return detail;
  return l10n.recordTodayOverviewEventCount(0);
}

String overviewFallbackLabel(AppLocalizations l10n, RecordEntryType type) {
  return switch (type) {
    RecordEntryType.medication => l10n.recordTypeMedication,
    RecordEntryType.symptom => l10n.recordTypeSymptom,
    RecordEntryType.water => l10n.recordTypeWater,
    RecordEntryType.meal => l10n.recordTypeMeal,
    RecordEntryType.vitals => l10n.recordTypeVitals,
    RecordEntryType.mood => l10n.recordTypeMood,
    RecordEntryType.activity => l10n.recordTypeActivity,
    RecordEntryType.sleep => l10n.recordTypeSleep,
    RecordEntryType.heartRate => l10n.recordTypeHeartRate,
    RecordEntryType.weight => l10n.recordTypeWeight,
    RecordEntryType.note => l10n.recordCreateKindNote,
  };
}

IconData overviewFallbackIcon(RecordEntryType type) {
  return switch (type) {
    RecordEntryType.medication => Icons.medication_rounded,
    RecordEntryType.symptom => Icons.sick_outlined,
    RecordEntryType.water => Icons.local_drink_rounded,
    RecordEntryType.meal => Icons.restaurant_menu_rounded,
    RecordEntryType.vitals => Icons.favorite_rounded,
    RecordEntryType.mood => Icons.mood_rounded,
    RecordEntryType.activity => Icons.directions_run_rounded,
    RecordEntryType.sleep => Icons.dark_mode_rounded,
    RecordEntryType.heartRate => Icons.monitor_heart_outlined,
    RecordEntryType.weight => Icons.monitor_weight_outlined,
    RecordEntryType.note => Icons.notes_rounded,
  };
}

Color overviewFallbackColor(RecordEntryType type) {
  return switch (type) {
    RecordEntryType.medication => AppColorTokens.cyanDeep,
    RecordEntryType.symptom => AppColorTokens.warning,
    RecordEntryType.water => AppColorTokens.link,
    RecordEntryType.meal => AppColorTokens.cyanDeep,
    RecordEntryType.vitals => AppColorTokens.error,
    RecordEntryType.mood => AppColorTokens.violet,
    RecordEntryType.activity => AppColorTokens.gradientDevelopStart,
    RecordEntryType.sleep => AppColorTokens.violet,
    RecordEntryType.heartRate => AppColorTokens.error,
    RecordEntryType.weight => AppColorTokens.linkDeep,
    RecordEntryType.note => AppColorTokens.link,
  };
}

String mobileFilterLabel(AppLocalizations l10n, RecordFilter filter) {
  return recordCopy(l10n, filter.titleKey);
}

RecordCopyKey weekdayKeyFromDate(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => RecordCopyKey.weekdayMon,
    DateTime.tuesday => RecordCopyKey.weekdayTue,
    DateTime.wednesday => RecordCopyKey.weekdayWed,
    DateTime.thursday => RecordCopyKey.weekdayThu,
    DateTime.friday => RecordCopyKey.weekdayFri,
    DateTime.saturday => RecordCopyKey.weekdaySat,
    _ => RecordCopyKey.weekdaySun,
  };
}

String quickRecordLabel(AppLocalizations l10n, RecordQuickAction action) {
  return l10n.recordQuickActionLabel(recordCopy(l10n, action.titleKey));
}

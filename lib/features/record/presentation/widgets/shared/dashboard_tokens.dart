import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/tokens/lucide_icon_bridge.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Helper functions
// ---------------------------------------------------------------------------

/// Resolves the effective display icon for [action], applying a user-customized
/// Lucide icon when one is stored in [preferences] for the action's type.
IconData resolveQuickActionIcon(
  RecordQuickAction action,
  QuickEntryPreferences preferences,
) {
  final customName = preferences.customIcons[action.type.name];
  if (customName != null) {
    return LucideIconBridge.resolve(customName, fallback: recordIcon(action));
  }
  return recordIcon(action);
}

/// Resolves a domain icon name (a kebab-case Lucide name) to a glyph.
///
/// Domain entities store icon *identity* as a `String` so they stay free of
/// `flutter/material` (clean-layers R1/R2); the concrete `IconData` is resolved
/// here, in the presentation layer.
IconData resolveIconName(
  String? name, {
  IconData fallback = defaultRecordIcon,
}) {
  if (name == null) return fallback;
  return LucideIconBridge.resolve(name, fallback: fallback);
}

/// The glyph used when a domain entity carries no icon name.
const defaultRecordIcon = SemanticIcons.recordClipboard;

/// The display icon of a quick action.
IconData recordIcon(RecordQuickAction action) =>
    resolveIconName(action.iconName);

/// The display icon of a summary item.
IconData summaryItemIcon(RecordSummaryItem item) =>
    resolveIconName(item.iconName);

/// The display icon of a filter.
IconData filterIcon(RecordFilter filter) => resolveIconName(filter.iconName);

/// The display icon of a timeline entry.
IconData timelineEntryIcon(RecordTimelineEntry entry) =>
    resolveIconName(entry.iconName);

/// The trailing icon of a timeline entry, if any.
IconData? timelineEntryTrailingIcon(RecordTimelineEntry entry) =>
    entry.trailingIconName == null
    ? null
    : resolveIconName(entry.trailingIconName);

/// Default preferred order of quick-action types on mobile.
const defaultQuickActionOrder = <RecordEntryType>[
  RecordEntryType.symptom,
  RecordEntryType.medication,
  RecordEntryType.water,
  RecordEntryType.meal,
  RecordEntryType.sleep,
  RecordEntryType.mood,
  RecordEntryType.note,
];

/// Sorts [actions] according to [preferences].
///
/// - If `dynamicSortEnabled` is true, sorts by frequency (descending),
///   falling back to the default order for zero-frequency items.
/// - If a `customOrder` is set, uses it to order the actions.
/// - Otherwise uses [defaultQuickActionOrder].
///
/// Actions not covered by the ordering are appended at the end.
List<RecordQuickAction> buildMobileQuickActions(
  List<RecordQuickAction> actions, {
  QuickEntryPreferences preferences = const QuickEntryPreferences(),
}) {
  final byType = {for (final action in actions) action.type: action};

  List<RecordEntryType> orderTypes;
  if (preferences.dynamicSortEnabled && preferences.frequency.isNotEmpty) {
    // Sort by frequency descending; zero-frequency items keep default order.
    orderTypes = _sortByFrequency(
      defaultQuickActionOrder,
      preferences.frequency,
    );
  } else if (preferences.customOrder.isNotEmpty) {
    orderTypes = _parseCustomOrder(preferences.customOrder);
  } else {
    orderTypes = defaultQuickActionOrder;
  }

  final ordered = <RecordQuickAction>[
    for (final type in orderTypes)
      if (byType[type] != null) byType[type]!,
  ];
  for (final action in actions) {
    if (!ordered.contains(action)) ordered.add(action);
  }
  return ordered.toList(growable: false);
}

List<RecordEntryType> _sortByFrequency(
  List<RecordEntryType> types,
  Map<String, int> frequency,
) {
  final sorted = List<RecordEntryType>.from(types)
    ..sort((a, b) {
      final freqA = frequency[a.name] ?? 0;
      final freqB = frequency[b.name] ?? 0;
      if (freqA != freqB) return freqB.compareTo(freqA);
      // Preserve original order for equal frequencies.
      return types.indexOf(a).compareTo(types.indexOf(b));
    });
  return sorted;
}

List<RecordEntryType> _parseCustomOrder(List<String> names) {
  return names
      .map((name) => _tryParseRecordEntryType(name))
      .whereType<RecordEntryType>()
      .toList(growable: false);
}

RecordEntryType? _tryParseRecordEntryType(String name) {
  for (final type in RecordEntryType.values) {
    if (type.name == name) return type;
  }
  return null;
}

List<RecordFilter> buildMobileFilters(List<RecordFilter> filters) {
  const preferredTypes = <RecordEntryType>[
    RecordEntryType.symptom,
    RecordEntryType.medication,
    RecordEntryType.water,
    RecordEntryType.meal,
    RecordEntryType.sleep,
    RecordEntryType.mood,
    RecordEntryType.note,
  ];
  // Hide locked filters on mobile — they add visual noise without value.
  final available = filters.where((f) => !f.locked).toList();
  final byType = {for (final filter in available) filter.type: filter};
  final ordered = <RecordFilter>[
    for (final type in preferredTypes)
      if (byType[type] != null) byType[type]!,
  ];
  for (final filter in available) {
    if (!ordered.contains(filter)) ordered.add(filter);
  }
  return ordered.toList(growable: false);
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

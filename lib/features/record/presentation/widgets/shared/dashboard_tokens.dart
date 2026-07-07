import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Helper functions
// ---------------------------------------------------------------------------

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
    RecordEntryType.water,
    RecordEntryType.meal,
    RecordEntryType.sleep,
    RecordEntryType.medication,
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

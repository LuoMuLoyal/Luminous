import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry/grid.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry/header.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry/metrics.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordQuickEntryPanel extends ConsumerStatefulWidget {
  const RecordQuickEntryPanel({
    super.key,
    required this.actions,
    required this.l10n,
    this.summary = const RecordDaySummary(items: <RecordSummaryItem>[]),
    this.timeline = const <RecordTimelineEntry>[],
    this.onQuickAction,
    this.onQuickActionLongPress,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final RecordDaySummary summary;
  final List<RecordTimelineEntry> timeline;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  /// Long-press is a shortcut to the type-specific "more/settings" surface
  /// (per the quick-entry UX spec), never the icon picker.
  final ValueChanged<RecordQuickAction>? onQuickActionLongPress;

  @override
  ConsumerState<RecordQuickEntryPanel> createState() =>
      _RecordQuickEntryPanelState();
}

class _RecordQuickEntryPanelState extends ConsumerState<RecordQuickEntryPanel> {
  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final metrics = QuickEntryMetrics.resolve(context);

    final allActions = _applyPreferences(widget.actions, prefs);

    final noteAction = allActions
        .where((action) => action.type == RecordEntryType.note)
        .firstOrNull;
    final gridActions = allActions
        .where((action) => action.type != RecordEntryType.note)
        .take(6)
        .toList(growable: false);

    return Column(
      key: const Key('record-quick-actions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuickEntryHeader(l10n: l10n),
        SizedBox(height: metrics.sectionGap),
        if (!prefs.collapsed)
          FCard(
            child: Column(
              children: [
                QuickRecordGrid(
                  actions: gridActions,
                  l10n: l10n,
                  metrics: metrics,
                  badgeFor: (action) => _badgeFor(
                    action,
                    prefs,
                    l10n,
                    widget.summary,
                    widget.timeline,
                  ),
                  onTap: widget.onQuickAction,
                  onLongPress: widget.onQuickActionLongPress,
                ),
                if (noteAction != null) ...[
                  const AppDivider(),
                  QuickRecordNoteButton(
                    action: noteAction,
                    l10n: l10n,
                    metrics: metrics,
                    onTap: widget.onQuickAction,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  List<RecordQuickAction> _applyPreferences(
    List<RecordQuickAction> actions,
    QuickEntryPreferences prefs,
  ) {
    final ordered = buildMobileQuickActions(actions, preferences: prefs);
    return ordered
        .map(
          (action) =>
              action.copyWith(icon: resolveQuickActionIcon(action, prefs)),
        )
        .toList(growable: false);
  }

  String? _badgeFor(
    RecordQuickAction action,
    QuickEntryPreferences prefs,
    AppLocalizations l10n,
    RecordDaySummary summary,
    List<RecordTimelineEntry> timeline,
  ) {
    return switch (action.type) {
      RecordEntryType.water => _waterBadge(prefs, l10n, summary, timeline),
      RecordEntryType.sleep => _sleepBadge(prefs, l10n, timeline),
      RecordEntryType.mood => _moodBadge(prefs, l10n, timeline),
      _ => null,
    };
  }

  String? _waterBadge(
    QuickEntryPreferences prefs,
    AppLocalizations l10n,
    RecordDaySummary summary,
    List<RecordTimelineEntry> timeline,
  ) {
    if (prefs.waterBadgeMode == QuickEntryWaterBadgeMode.hidden) return null;
    if (prefs.waterBadgeMode == QuickEntryWaterBadgeMode.dailyCount) {
      final count = timeline
          .where((entry) => entry.type == RecordEntryType.water)
          .length;
      return count > 0 ? count.toString() : null;
    }
    final waterSummary = summary.items
        .where((item) => item.type == RecordEntryType.water)
        .firstOrNull;
    if (waterSummary == null || waterSummary.value.trim().isEmpty) {
      return null;
    }
    final unit = waterSummary.unitKey == null
        ? ''
        : recordCopy(l10n, waterSummary.unitKey!);
    return '${waterSummary.value}$unit';
  }

  String? _sleepBadge(
    QuickEntryPreferences prefs,
    AppLocalizations l10n,
    List<RecordTimelineEntry> timeline,
  ) {
    if (!prefs.sleepInProgressBadgeEnabled) return null;
    final inProgress = timeline.any(
      (entry) =>
          entry.type == RecordEntryType.sleep &&
          entry.value == null &&
          entry.valueKey == null,
    );
    return inProgress ? l10n.recordQuickSleepInProgressBadge : null;
  }

  String? _moodBadge(
    QuickEntryPreferences prefs,
    AppLocalizations l10n,
    List<RecordTimelineEntry> timeline,
  ) {
    if (prefs.moodBadgeMode == QuickEntryMoodBadgeMode.hidden) return null;
    final moodEntries = timeline
        .where((entry) => entry.type == RecordEntryType.mood)
        .toList();
    if (moodEntries.isEmpty) return null;
    final latest = moodEntries.first;
    if (latest.rawTitle != null) return latest.rawTitle;
    if (latest.value != null) return latest.value;
    return null;
  }
}

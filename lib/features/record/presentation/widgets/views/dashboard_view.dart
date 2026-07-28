import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/sections/date_bar.dart';
import 'package:luminous/features/record/presentation/widgets/sections/mobile_filter.dart';
import 'package:luminous/features/record/presentation/widgets/sections/mobile_timeline.dart';
import 'package:luminous/features/record/presentation/widgets/sections/new_entry_panel.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry_panel.dart';
import 'package:luminous/features/record/presentation/widgets/sections/sidebar.dart';
import 'package:luminous/features/record/presentation/widgets/sections/summary_grid.dart';
import 'package:luminous/features/record/presentation/widgets/sections/timeline.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDashboardView extends StatelessWidget {
  const RecordDashboardView({
    super.key,
    required this.dashboard,
    this.isPreview = false,
    this.isLoading = false,
    this.onQuickAction,
    this.onNewEntry,
    this.onFilterSelected,
    this.onDateSelected,
    this.onRecordDateChange,
  });

  final RecordDashboard dashboard;
  final bool isPreview;
  final bool isLoading;
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final VoidCallback? onNewEntry;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<DateTime>? onDateSelected;

  /// Called when a timeline card is dragged onto a calendar day.
  /// Receives the record ID and the new target date.
  final void Function(String recordId, DateTime newDate)? onRecordDateChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    final content = isDesktop
        ? _DesktopRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            onDateSelected: onDateSelected,
            onFilterSelected: onFilterSelected,
            onQuickAction: onQuickAction,
            onNewEntry: onNewEntry,
            onRecordDateChange: onRecordDateChange,
          )
        : _MobileRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            onQuickAction: onQuickAction,
            onFilterSelected: onFilterSelected,
            onDateSelected: onDateSelected,
          );

    return SkeletonScope(isLoading: isLoading, child: content);
  }
}

class _MobileRecordDashboard extends StatelessWidget {
  const _MobileRecordDashboard({
    required this.dashboard,
    required this.l10n,
    this.onQuickAction,
    this.onFilterSelected,
    this.onDateSelected,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    final quickActions = buildMobileQuickActions(dashboard.quickActions);
    final mobileFilters = buildMobileFilters(dashboard.filters);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecordDateBar(
          dashboard: dashboard,
          l10n: l10n,
          onDateSelected: onDateSelected,
        ),
        const SizedBox(height: Spacing.level4),
        RecordQuickEntryPanel(
          actions: quickActions,
          l10n: l10n,
          onQuickAction: onQuickAction,
        ),
        const SizedBox(height: Spacing.level4),
        RecordMobileFilter(
          filters: mobileFilters,
          l10n: l10n,
          onFilterSelected: onFilterSelected,
        ),
        const SizedBox(height: Spacing.level4),
        RecordMobileTimeline(
          entries: dashboard.timeline,
          totalCount: dashboard.timeline.length,
          l10n: l10n,
          selectedDate: dashboard.selectedDate,
          hasActiveFilter: !dashboard.filters.every((f) => f.selected),
          onClearFilter: onFilterSelected != null
              ? () => onFilterSelected!(null)
              : null,
          onBackToToday: onDateSelected != null
              ? () => onDateSelected!(clock.now())
              : null,
        ),
        const SizedBox(height: Spacing.level4),
      ],
    );
  }
}

class _DesktopRecordDashboard extends StatelessWidget {
  const _DesktopRecordDashboard({
    required this.dashboard,
    required this.l10n,
    this.onDateSelected,
    this.onFilterSelected,
    this.onQuickAction,
    this.onNewEntry,
    this.onRecordDateChange,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final VoidCallback? onNewEntry;
  final void Function(String recordId, DateTime newDate)? onRecordDateChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260,
          child: Column(
            children: [
              RecordMonthCalendarPanel(
                days: dashboard.monthDays,
                selectedDate: dashboard.selectedDate,
                l10n: l10n,
                onDateSelected: onDateSelected,
                onRecordDropped: onRecordDateChange,
                // Month navigation is handled internally by the panel's
                // _viewedMonth state — no parent callback needed.
              ),
              const SizedBox(height: Spacing.level4),
              RecordFilterPanel(
                filters: dashboard.filters,
                l10n: l10n,
                onFilterSelected: onFilterSelected,
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.level5),
        Expanded(
          child: Column(
            children: [
              RecordSummaryGrid(
                summary: dashboard.summary,
                l10n: l10n,
                onTypeSelected: onFilterSelected,
              ),
              const SizedBox(height: Spacing.level4),
              RecordTimelinePanel(
                entries: dashboard.timeline,
                l10n: l10n,
                onClearFilter: () => onFilterSelected?.call(null),
                selectedDate: dashboard.selectedDate,
                onRecordDateChange: onRecordDateChange,
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.level5),
        SizedBox(
          width: 220,
          child: Column(
            children: [
              RecordNewEntryPanel(
                actions: dashboard.quickActions,
                l10n: l10n,
                onNewEntry: onNewEntry,
                onQuickAction: onQuickAction,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

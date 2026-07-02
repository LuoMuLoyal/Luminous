import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/sections/record_date_bar.dart';
import 'package:luminous/features/record/presentation/widgets/sections/record_mobile_filter.dart';
import 'package:luminous/features/record/presentation/widgets/sections/record_mobile_timeline.dart';
import 'package:luminous/features/record/presentation/widgets/record_overview.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_dashboard_tokens.dart';
import 'package:luminous/features/record/presentation/widgets/sections/record_quick_entry_panel.dart';
import 'package:luminous/features/record/presentation/widgets/sections/record_sidebar.dart';
import 'package:luminous/features/record/presentation/widgets/sections/record_timeline.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDashboardView extends StatelessWidget {
  const RecordDashboardView({
    super.key,
    required this.dashboard,
    this.isLoading = false,
    this.onQuickAction,
    this.onAiInputTap,
    this.onMicTap,
    this.onCameraTap,
    this.onNewEntry,
    this.onFilterSelected,
    this.onDateSelected,
    this.onPickDate,
  });

  final RecordDashboard dashboard;
  final bool isLoading;
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final VoidCallback? onAiInputTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onCameraTap;
  final VoidCallback? onNewEntry;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onPickDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    final content = isDesktop
        ? _DesktopRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            onDateSelected: onDateSelected,
            onFilterSelected: onFilterSelected,
            onQuickAction: onQuickAction,
            onNewEntry: onNewEntry,
          )
        : _MobileRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            onQuickAction: onQuickAction,
            onAiInputTap: onAiInputTap,
            onMicTap: onMicTap,
            onCameraTap: onCameraTap,
            onFilterSelected: onFilterSelected,
            onDateSelected: onDateSelected,
            onPickDate: onPickDate,
          );

    return AppSkeletonScope(isLoading: isLoading, child: content);
  }
}

class _MobileRecordDashboard extends StatelessWidget {
  const _MobileRecordDashboard({
    required this.dashboard,
    required this.l10n,
    this.onQuickAction,
    this.onAiInputTap,
    this.onMicTap,
    this.onCameraTap,
    this.onFilterSelected,
    this.onDateSelected,
    this.onPickDate,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final VoidCallback? onAiInputTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onCameraTap;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onPickDate;

  @override
  Widget build(BuildContext context) {
    final quickActions = buildMobileQuickActions(dashboard.quickActions);
    final timeline = dashboard.timeline.take(7).toList(growable: false);
    final mobileFilters = buildMobileFilters(dashboard.filters);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecordDateBar(
          dashboard: dashboard,
          l10n: l10n,
          onDateSelected: onDateSelected,
          onPickDate: onPickDate,
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        RecordAiInputBar(
          l10n: l10n,
          onTap: onAiInputTap,
          onMicTap: onMicTap,
          onCameraTap: onCameraTap,
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        RecordQuickEntryPanel(
          actions: quickActions,
          l10n: l10n,
          onQuickAction: onQuickAction,
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        RecordMobileFilter(
          filters: mobileFilters,
          l10n: l10n,
          onFilterSelected: onFilterSelected,
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        RecordMobileTimeline(
          entries: timeline,
          totalCount: dashboard.timeline.length,
          l10n: l10n,
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        RecordGuideRow(l10n: l10n),
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
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final VoidCallback? onNewEntry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppResponsiveSizing.sidebarWidth(context),
          child: Column(
            children: [
              RecordMonthCalendarPanel(
                days: dashboard.monthDays,
                selectedDate: dashboard.selectedDate,
                l10n: l10n,
                onDateSelected: onDateSelected,
                onMonthChanged: onDateSelected,
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              RecordFilterPanel(
                filters: dashboard.filters,
                l10n: l10n,
                onFilterSelected: onFilterSelected,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level5),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              RecordSummaryGrid(
                summary: dashboard.summary,
                l10n: l10n,
                onTypeSelected: onFilterSelected,
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              RecordTimelinePanel(
                entries: dashboard.timeline,
                l10n: l10n,
                onClearFilter: () => onFilterSelected?.call(null),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level5),
        SizedBox(
          width: AppResponsiveSizing.sidebarWidth(context),
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

import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/sections/record_date_bar.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_dashboard_tokens.dart';
import 'package:luminous/features/record/presentation/widgets/sections/record_mobile_filter.dart';
import 'package:luminous/features/record/presentation/widgets/sections/record_mobile_timeline.dart';
import 'package:luminous/features/record/presentation/widgets/record_overview.dart';
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final isDesktop = width >= AppBreakpoints.desktop;

    final content = isDesktop
        ? _DesktopRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            typography: typography,
            surface: surface,
            onDateSelected: onDateSelected,
            onFilterSelected: onFilterSelected,
            onQuickAction: onQuickAction,
            onNewEntry: onNewEntry,
          )
        : _MobileRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            typography: typography,
            surface: surface,
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
    required this.typography,
    required this.surface,
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
  final AppTypographyScale typography;
  final AppThemeSurface surface;
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
          typography: typography,
          surface: surface,
          onDateSelected: onDateSelected,
          onPickDate: onPickDate,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordAiInputBar(
          l10n: l10n,
          typography: typography,
          surface: surface,
          onTap: onAiInputTap,
          onMicTap: onMicTap,
          onCameraTap: onCameraTap,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordQuickEntryPanel(
          actions: quickActions,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onQuickAction: onQuickAction,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordMobileFilter(
          filters: mobileFilters,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onFilterSelected: onFilterSelected,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordMobileTimeline(
          entries: timeline,
          totalCount: dashboard.timeline.length,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordGuideRow(l10n: l10n, typography: typography, surface: surface),
      ],
    );
  }
}

class _DesktopRecordDashboard extends StatelessWidget {
  const _DesktopRecordDashboard({
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onDateSelected,
    this.onFilterSelected,
    this.onQuickAction,
    this.onNewEntry,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
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
                typography: typography,
                surface: surface,
                onDateSelected: onDateSelected,
                onMonthChanged: onDateSelected,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordFilterPanel(
                filters: dashboard.filters,
                l10n: l10n,
                typography: typography,
                surface: surface,
                onFilterSelected: onFilterSelected,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.lg),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              RecordSummaryGrid(
                summary: dashboard.summary,
                l10n: l10n,
                typography: typography,
                surface: surface,
                onTypeSelected: onFilterSelected,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordTimelinePanel(
                entries: dashboard.timeline,
                l10n: l10n,
                typography: typography,
                surface: surface,
                onClearFilter: () => onFilterSelected?.call(null),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.lg),
        SizedBox(
          width: AppResponsiveSizing.sidebarWidth(context),
          child: Column(
            children: [
              RecordNewEntryPanel(
                actions: dashboard.quickActions,
                l10n: l10n,
                typography: typography,
                surface: surface,
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

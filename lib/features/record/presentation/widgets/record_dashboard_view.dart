import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_overview.dart';
import 'package:luminous/features/record/presentation/widgets/record_sidebar.dart';
import 'package:luminous/features/record/presentation/widgets/record_timeline.dart';
import 'package:luminous/features/record/presentation/widgets/record_trends.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDashboardView extends StatelessWidget {
  const RecordDashboardView({super.key, required this.dashboard});

  final RecordDashboard dashboard;

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

    return isDesktop
        ? _DesktopRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            typography: typography,
            surface: surface,
          )
        : _MobileRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            typography: typography,
            surface: surface,
          );
  }
}

class _MobileRecordDashboard extends StatelessWidget {
  const _MobileRecordDashboard({
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecordWeekStrip(
          days: dashboard.weekDays,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordQuickActions(
          actions: dashboard.quickActions,
          l10n: l10n,
          typography: typography,
          surface: surface,
          compact: true,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordSummaryGrid(
          summary: dashboard.summary,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordTimelinePanel(
          entries: dashboard.timeline.take(5).toList(),
          l10n: l10n,
          typography: typography,
          surface: surface,
          dense: true,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordTrendsPanel(
          trends: dashboard.trends.take(2).toList(),
          l10n: l10n,
          typography: typography,
          surface: surface,
          compact: true,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        RecordHealthBagPanel(
          healthBag: dashboard.healthBag,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
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
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: Column(
            children: [
              RecordMonthCalendarPanel(
                days: dashboard.monthDays,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordFilterPanel(
                filters: dashboard.filters,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordHealthBagPanel(
                healthBag: dashboard.healthBag,
                l10n: l10n,
                typography: typography,
                surface: surface,
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
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordTimelinePanel(
                entries: dashboard.timeline,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.lg),
        SizedBox(
          width: 330,
          child: Column(
            children: [
              RecordTrendsPanel(
                trends: dashboard.trends,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordNewEntryPanel(
                actions: dashboard.quickActions,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

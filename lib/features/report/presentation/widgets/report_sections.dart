import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportTopBar extends StatelessWidget {
  const ReportTopBar({
    super.key,
    required this.onGenerate,
    required this.onSync,
    this.isGenerating = false,
    this.isSyncing = false,
  });

  final VoidCallback onGenerate;
  final VoidCallback onSync;
  final bool isGenerating;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tabReport,
                    style: typography.displayXl.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    l10n.reportWeekDateRange,
                    style: typography.bodyLg.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.md),
            ReportPeriodPill(label: l10n.reportPeriodThisWeek),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        _ReportSnapshotStatus(typography: typography, surface: surface),
        const SizedBox(height: AppSpacingTokens.sm),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const Key('report-generate-action'),
                onPressed: isGenerating ? null : onGenerate,
                style: FilledButton.styleFrom(
                  backgroundColor: ReportPalette.previewScore,
                  foregroundColor: AppColorTokens.onPrimary,
                  disabledBackgroundColor: ReportPalette.previewScore
                      .withValues(alpha: 0.38),
                  disabledForegroundColor: AppColorTokens.onPrimary.withValues(
                    alpha: 0.7,
                  ),
                ),
                icon: Icon(
                  isGenerating
                      ? Icons.hourglass_top_rounded
                      : Icons.auto_awesome_rounded,
                ),
                label: Text(
                  l10n.reportGenerateAction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Tooltip(
              message: l10n.reportSyncAction,
              child: IconButton.outlined(
                key: const Key('report-sync-action'),
                onPressed: isSyncing ? null : onSync,
                icon: Icon(
                  isSyncing ? Icons.hourglass_top_rounded : Icons.sync_rounded,
                ),
                color: theme.colorScheme.onSurface,
                visualDensity: VisualDensity.compact,
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReportSnapshotStatus extends StatelessWidget {
  const _ReportSnapshotStatus({
    required this.typography,
    required this.surface,
  });

  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      key: const Key('report-snapshot-status'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, thickness: 1, color: surface.hairline),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
          child: Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: ReportPalette.blue,
                size: AppSpacingTokens.lg,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportSnapshotStatus,
                      style: typography.bodySmStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(
                      l10n.reportSnapshotHint,
                      style: typography.caption.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: surface.hairline),
      ],
    );
  }
}

class ReportPeriodPill extends StatelessWidget {
  const ReportPeriodPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, label),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.md),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: typography.bodyMdStrong.copyWith(letterSpacing: 0),
                ),
                const SizedBox(width: AppSpacingTokens.xxs),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: AppSpacingTokens.lg,
                  color: surface.body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportScoreHero extends StatelessWidget {
  const ReportScoreHero({
    super.key,
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final score = dashboard.score;

    return ReportPanel(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      borderColor: ReportPalette.previewScore.withValues(alpha: 0.22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.reportScoreTitle,
                        style: typography.displaySm.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.info_outline_rounded,
                      color: surface.mute,
                      size: AppSpacingTokens.lg,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.md),
                Wrap(
                  spacing: AppSpacingTokens.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 58,
                        width: 76,
                        radius: AppRadiusTokens.md,
                      ),
                      child: Text(
                        score.value.toString(),
                        style: typography.displayXl.copyWith(
                          color: ReportPalette.previewScore,
                          fontSize: 54,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Text(
                      l10n.reportScoreOutOf(score.maxValue),
                      style: typography.bodyLg.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                    ),
                    AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 22,
                        width: 64,
                        radius: AppRadiusTokens.sm,
                      ),
                      child: ReportPill(
                        label: _statusLabel(l10n, score.status),
                        color: _statusColor(score.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.lg),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 20,
                    widthFactor: 0.86,
                    radius: AppRadiusTokens.sm,
                  ),
                  child: ReportTextAction(
                    label: score.summary,
                    onTap: () => showReportToast(context, score.summary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: ReportPalette.previewScoreSoft,
              shape: BoxShape.circle,
            ),
            child: const SizedBox.square(
              dimension: 112,
              child: Icon(
                Icons.fact_check_rounded,
                color: ReportPalette.previewScore,
                size: 68,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportMetricsGrid extends StatelessWidget {
  const ReportMetricsGrid({
    super.key,
    required this.metrics,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportMetric> metrics;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacingTokens.sm,
        mainAxisSpacing: AppSpacingTokens.sm,
        mainAxisExtent: 180,
      ),
      itemBuilder: (context, index) {
        return _MetricCard(
          metric: metrics[index],
          l10n: l10n,
          typography: typography,
          surface: surface,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportMetric metric;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final title = _metricTitle(l10n, metric.kind);
    final directionIcon = switch (metric.direction) {
      ReportMetricDirection.up => Icons.arrow_upward_rounded,
      ReportMetricDirection.down => Icons.arrow_downward_rounded,
      ReportMetricDirection.flat => Icons.arrow_forward_rounded,
    };
    final directionColor = switch (metric.direction) {
      ReportMetricDirection.down => Theme.of(context).colorScheme.error,
      _ => ReportPalette.green,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, title),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: ReportPanel(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ReportIconBadge(
                    icon: metric.icon,
                    color: metric.color,
                    size: 34,
                    iconSize: 19,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: AppSpacingTokens.xs),
                  Expanded(
                    child: Text(
                      title,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Wrap(
                spacing: AppSpacingTokens.xxs,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  AppSkeletonText(
                    text: metric.value,
                    style: typography.displayLg.copyWith(
                      color: metric.color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                    width: 48,
                  ),
                  if (metric.unit.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.xxs,
                      ),
                      child: Text(
                        metric.unit,
                        style: typography.bodySm.copyWith(
                          color: surface.body,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Row(
                children: [
                  AppSkeletonSlot(
                    skeleton: const AppInlineSkeletonBlock(
                      height: 22,
                      width: 54,
                      radius: AppRadiusTokens.sm,
                    ),
                    child: ReportPill(
                      label: _statusLabel(l10n, metric.status),
                      color: _statusColor(metric.status),
                      backgroundAlpha: 0.1,
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.xs),
                  Icon(directionIcon, size: 14, color: directionColor),
                  const SizedBox(width: AppSpacingTokens.xxs),
                  Expanded(
                    child: AppSkeletonText(
                      text: metric.delta,
                      style: typography.caption.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.82,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AppSkeletonSlot(
                skeleton: const AppInlineSkeletonBlock(
                  height: 26,
                  radius: AppRadiusTokens.sm,
                ),
                child: ReportMetricTrack(
                  values: metric.sparkline,
                  color: metric.color,
                  height: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportTrendSection extends StatelessWidget {
  const ReportTrendSection({
    super.key,
    required this.trends,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportTrendSeries> trends;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportSectionHeader(
          title: l10n.reportTrendSectionTitle,
          trailing: ReportPeriodPill(label: l10n.reportRangeLast7Days),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Divider(height: 1, thickness: 1, color: surface.hairline),
        const SizedBox(height: AppSpacingTokens.md),
        Wrap(
          spacing: AppSpacingTokens.md,
          runSpacing: AppSpacingTokens.xs,
          children: [
            for (final series in trends)
              _LegendDot(
                color: series.color,
                label: _metricTitle(l10n, series.kind),
                typography: typography,
                surface: surface,
              ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _TrendPlaceholder(
          trends: trends,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Align(
          alignment: Alignment.centerRight,
          child: ReportTextAction(
            label: l10n.reportViewDetailsAction,
            color: ReportPalette.blue,
            onTap: () => showReportToast(context, l10n.reportViewDetailsAction),
          ),
        ),
      ],
    );
  }
}

class _TrendPlaceholder extends StatelessWidget {
  const _TrendPlaceholder({
    required this.trends,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportTrendSeries> trends;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          children: [
            SizedBox(
              height: 176,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var index = 0; index < 5; index += 1)
                        Divider(height: 1, color: surface.hairline),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final series in trends)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacingTokens.xs,
                            ),
                            child: AppSkeletonSlot(
                              skeleton: const AppInlineSkeletonBlock(
                                height: 22,
                                width: 46,
                                radius: AppRadiusTokens.sm,
                              ),
                              child: ReportPill(
                                label: series.currentValue,
                                color: series.color,
                                backgroundAlpha: 0.92,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 54),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final series in trends)
                          AppSkeletonSlot(
                            skeleton: const AppInlineSkeletonBlock(
                              height: 30,
                              radius: AppRadiusTokens.sm,
                            ),
                            child: ReportMetricTrack(
                              values: series.values,
                              color: series.color,
                              height: 30,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Row(
              children: [
                for (final label in l10n.reportTrendDateLabels.split('|'))
                  Expanded(
                    child: Text(
                      label,
                      style: typography.caption.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReportFindingsSection extends StatelessWidget {
  const ReportFindingsSection({
    super.key,
    required this.findings,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportFinding> findings;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportSectionHeader(title: l10n.reportFindingsSectionTitle),
        const SizedBox(height: AppSpacingTokens.sm),
        Divider(height: 1, thickness: 1, color: surface.hairline),
        const SizedBox(height: AppSpacingTokens.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < findings.length; index += 1) ...[
                SizedBox(
                  width: 238,
                  child: _FindingCard(
                    finding: findings[index],
                    typography: typography,
                    surface: surface,
                  ),
                ),
                if (index != findings.length - 1)
                  const SizedBox(width: AppSpacingTokens.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({
    required this.finding,
    required this.typography,
    required this.surface,
  });

  final ReportFinding finding;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, finding.title),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: finding.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: finding.color.withValues(alpha: 0.18)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ReportIconBadge(
                      icon: finding.icon,
                      color: finding.color,
                      size: 42,
                      iconSize: 22,
                      shape: BoxShape.circle,
                    ),
                    const Spacer(),
                    ReportIconBadge(
                      icon: Icons.chevron_right_rounded,
                      color: surface.body,
                      size: 28,
                      iconSize: 18,
                      shape: BoxShape.circle,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.md),
                AppSkeletonText(
                  text: finding.title,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                  widthFactor: 0.7,
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                AppSkeletonText(
                  text: finding.body,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  widthFactor: 0.9,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportAiSummarySection extends StatelessWidget {
  const ReportAiSummarySection({
    super.key,
    required this.dashboard,
    required this.authSession,
    required this.settingsAsync,
    required this.aiState,
    required this.selectedRange,
    this.onRangeChanged,
    this.onGenerate,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportDashboard dashboard;
  final AuthSessionState authSession;
  final AsyncValue<UserSettingsDataDto>? settingsAsync;
  final ReportAiSummaryCardState aiState;
  final ReportAiSummaryRange selectedRange;
  final ValueChanged<ReportAiSummaryRange>? onRangeChanged;
  final Future<void> Function()? onGenerate;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final content = _buildReportAiSummaryContent(
      l10n: l10n,
      dashboard: dashboard,
      authSession: authSession,
      settingsAsync: settingsAsync,
      aiState: aiState,
      selectedRange: selectedRange,
    );
    final actionLabel = aiState.summary?.actionLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportIconBadge(
              icon: Icons.auto_awesome_rounded,
              color: ReportPalette.green,
              size: AppSpacingTokens.x3l,
              iconSize: AppSpacingTokens.lg,
              shape: BoxShape.circle,
            ),
            const SizedBox(width: AppSpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportAiSummaryTitle,
                    style: typography.bodyMdStrong.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    content.subtitle,
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            SegmentedButton<ReportAiSummaryRange>(
              key: const Key('report-ai-summary-range-toggle'),
              segments: [
                ButtonSegment(
                  value: ReportAiSummaryRange.last7Days,
                  label: Text(l10n.reportRangeLast7Days),
                ),
                ButtonSegment(
                  value: ReportAiSummaryRange.last30Days,
                  label: Text(l10n.reportRangeLast30Days),
                ),
              ],
              selected: {selectedRange},
              onSelectionChanged: onRangeChanged == null
                  ? null
                  : (selection) {
                      if (selection.isNotEmpty) {
                        onRangeChanged!(selection.first);
                      }
                    },
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: AppSpacingTokens.sm),
              OutlinedButton(
                onPressed: () => showReportToast(context, actionLabel),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacingTokens.md),
        Divider(height: 1, thickness: 1, color: surface.hairline),
        if (content.summaryText != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
            child: AppSkeletonText(
              text: content.summaryText!,
              style: typography.bodyMdStrong.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
              widthFactor: 0.94,
            ),
          ),
          Divider(height: 1, thickness: 1, color: surface.hairline),
        ],
        for (var index = 0; index < content.bullets.length; index += 1) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacingTokens.xs),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: content.bullets[index].color,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(
                      dimension: AppSpacingTokens.xs,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: AppSkeletonText(
                    text: content.bullets[index].text,
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
                    widthFactor: 0.9,
                  ),
                ),
              ],
            ),
          ),
          if (index < content.bullets.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              indent: AppSpacingTokens.lg,
              color: surface.hairline,
            ),
        ],
        if (content.footer != null) ...[
          const SizedBox(height: AppSpacingTokens.sm),
          Divider(height: 1, thickness: 1, color: surface.hairline),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            content.footer!,
            style: typography.caption.copyWith(
              color: surface.body,
              letterSpacing: 0,
            ),
          ),
        ],
        if (content.showGenerateButton) ...[
          const SizedBox(height: AppSpacingTokens.md),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              key: const Key('report-ai-summary-generate-action'),
              onPressed: aiState.isLoading || onGenerate == null
                  ? null
                  : () {
                      onGenerate!();
                    },
              icon: Icon(
                aiState.isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.auto_awesome_rounded,
              ),
              label: Text(
                aiState.isLoading
                    ? _reportAiSummaryGeneratingLabel(l10n, selectedRange)
                    : l10n.reportGenerateAction,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ReportExportSection extends StatelessWidget {
  const ReportExportSection({
    super.key,
    required this.actions,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportExportAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportSectionHeader(title: l10n.reportExportSectionTitle),
        const SizedBox(height: AppSpacingTokens.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacingTokens.sm,
            mainAxisSpacing: AppSpacingTokens.sm,
            mainAxisExtent: 118,
          ),
          itemBuilder: (context, index) {
            return _ExportCard(
              action: actions[index],
              l10n: l10n,
              typography: typography,
              surface: surface,
            );
          },
        ),
      ],
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.action,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportExportAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final title = _exportTitle(l10n, action.kind);
    final subtitle = _exportSubtitle(l10n, action.kind);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, title),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: ReportPanel(
          child: Row(
            children: [
              ReportIconBadge(icon: action.icon, color: action.color),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(
                      subtitle,
                      style: typography.caption.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: surface.body,
                size: AppSpacingTokens.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportPatternsSection extends StatelessWidget {
  const ReportPatternsSection({
    super.key,
    required this.patterns,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportPatternCard> patterns;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportSectionHeader(title: l10n.reportPatternSectionTitle),
        const SizedBox(height: AppSpacingTokens.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: patterns.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacingTokens.sm,
            mainAxisSpacing: AppSpacingTokens.sm,
            mainAxisExtent: 180,
          ),
          itemBuilder: (context, index) {
            return _PatternCard(
              pattern: patterns[index],
              l10n: l10n,
              typography: typography,
              surface: surface,
            );
          },
        ),
      ],
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({
    required this.pattern,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportPatternCard pattern;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, pattern.title),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: ReportPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ReportIconBadge(
                    icon: pattern.icon,
                    color: pattern.color,
                    size: 36,
                    iconSize: 20,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: AppSpacingTokens.xs),
                  Expanded(
                    child: Text(
                      pattern.title,
                      style: typography.bodySmStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.md),
              AppSkeletonText(
                text: _statusLabel(l10n, pattern.status),
                style: typography.bodyMdStrong.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                widthFactor: 0.74,
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              AppSkeletonText(
                text: pattern.body,
                style: typography.bodySm.copyWith(
                  color: surface.body,
                  letterSpacing: 0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                widthFactor: 0.88,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 28,
                        radius: AppRadiusTokens.sm,
                      ),
                      child: ReportMetricTrack(
                        values: pattern.sparkline,
                        color: pattern.color,
                        height: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: surface.body,
                    size: AppSpacingTokens.lg,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportReferenceNotice extends StatelessWidget {
  const ReportReferenceNotice({
    super.key,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          ReportPalette.orange.withValues(alpha: 0.1),
          surface.canvas,
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: ReportPalette.orange.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: ReportPalette.orange,
              size: AppSpacingTokens.lg,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Text(
                l10n.reportReferenceNotice,
                style: typography.bodySm.copyWith(
                  color: ReportPalette.orange,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.typography,
    required this.surface,
  });

  final Color color;
  final String label;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox.square(dimension: 8),
        ),
        const SizedBox(width: AppSpacingTokens.xs),
        Text(
          label,
          style: typography.caption.copyWith(
            color: surface.body,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

String _metricTitle(AppLocalizations l10n, ReportDataKind kind) {
  return switch (kind) {
    ReportDataKind.medication => l10n.reportMetricMedicationTitle,
    ReportDataKind.sleep => l10n.reportMetricSleepTitle,
    ReportDataKind.water => l10n.reportMetricWaterTitle,
    ReportDataKind.general => l10n.reportScoreTitle,
  };
}

String _exportTitle(AppLocalizations l10n, ReportExportKind kind) {
  return switch (kind) {
    ReportExportKind.hospital => l10n.reportExportHospitalTitle,
    ReportExportKind.monthly => l10n.reportExportMonthlyTitle,
    ReportExportKind.print => l10n.reportExportPrintTitle,
  };
}

String _exportSubtitle(AppLocalizations l10n, ReportExportKind kind) {
  return switch (kind) {
    ReportExportKind.hospital => l10n.reportExportHospitalSubtitle,
    ReportExportKind.monthly => l10n.reportExportMonthlySubtitle,
    ReportExportKind.print => l10n.reportExportPrintSubtitle,
  };
}

String _statusLabel(AppLocalizations l10n, ReportStatus status) {
  return switch (status) {
    ReportStatus.good => l10n.reportStatusGood,
    ReportStatus.stable => l10n.reportStatusStable,
    ReportStatus.needsAttention => l10n.reportStatusNeedsImprove,
    ReportStatus.insufficientData => l10n.medicineReminderUnavailableStatus,
    ReportStatus.unknown => l10n.reportStatusStable,
  };
}

Color _statusColor(ReportStatus status) {
  return switch (status) {
    ReportStatus.good => ReportPalette.green,
    ReportStatus.stable => ReportPalette.previewScore,
    ReportStatus.needsAttention => ReportPalette.orange,
    ReportStatus.insufficientData => ReportPalette.blue,
    ReportStatus.unknown => ReportPalette.blue,
  };
}

_ReportAiSummaryContent _buildReportAiSummaryContent({
  required AppLocalizations l10n,
  required ReportDashboard dashboard,
  required AuthSessionState authSession,
  required AsyncValue<UserSettingsDataDto>? settingsAsync,
  required ReportAiSummaryCardState aiState,
  required ReportAiSummaryRange selectedRange,
}) {
  if (!authSession.canAccessProtectedData) {
    return _ReportAiSummaryContent(
      subtitle: l10n.reportSnapshotHint,
      bullets: [
        _ReportAiSummaryItem(
          color: ReportPalette.orange,
          text: l10n.authLoginRequiredPrompt,
        ),
      ],
      footer: l10n.authNotSignedIn,
    );
  }

  final settings = settingsAsync?.asData?.value;
  if (settings?.aiSummariesEnabled == false || aiState.isDisabled) {
    return _ReportAiSummaryContent(
      subtitle: l10n.reportSnapshotHint,
      bullets: [
        _ReportAiSummaryItem(
          color: ReportPalette.blue,
          text: l10n.reportAiSummaryDisabledHint,
        ),
      ],
      footer: l10n.reportAiSummaryDisabledHint,
    );
  }

  final summary = aiState.summary;
  if (summary != null) {
    return _ReportAiSummaryContent(
      subtitle: _reportAiSummarySubtitle(l10n, selectedRange),
      summaryText: summary.summary,
      bullets: summary.bullets
          .map(
            (bullet) => _ReportAiSummaryItem(
              color: bullet.color,
              text: bullet.text,
            ),
          )
          .toList(growable: false),
      footer: summary.confidenceNote,
    );
  }

  if (aiState.status == ReportAiSummaryCardStatus.error) {
    return _ReportAiSummaryContent(
      subtitle: _reportAiSummarySubtitle(l10n, selectedRange),
      bullets: [
        _ReportAiSummaryItem(
          color: ReportPalette.orange,
          text: aiState.errorMessage ?? l10n.reportAiSummaryErrorHint,
        ),
        ..._reportAiSummaryFallbackBullets(dashboard),
      ],
      footer: aiState.errorMessage ?? l10n.reportAiSummaryErrorHint,
      showGenerateButton: dashboard.aiSummaryEnabled,
    );
  }

  if (aiState.status == ReportAiSummaryCardStatus.loading) {
    return _ReportAiSummaryContent(
      subtitle: _reportAiSummarySubtitle(l10n, selectedRange),
      bullets: [
        _ReportAiSummaryItem(
          color: ReportPalette.green,
          text: _reportAiSummaryGeneratingLabel(l10n, selectedRange),
        ),
        ..._reportAiSummaryFallbackBullets(dashboard),
      ],
      footer: _reportAiSummaryGeneratingLabel(l10n, selectedRange),
    );
  }

  return _ReportAiSummaryContent(
    subtitle: l10n.reportSnapshotHint,
    bullets: _reportAiSummaryFallbackBullets(dashboard),
    footer: l10n.reportAiSummaryDefaultHint,
    showGenerateButton: dashboard.aiSummaryEnabled,
  );
}

List<_ReportAiSummaryItem> _reportAiSummaryFallbackBullets(
  ReportDashboard dashboard,
) {
  return [
    _ReportAiSummaryItem(
      color: _statusColor(dashboard.score.status),
      text: dashboard.score.summary,
    ),
    ...dashboard.findings.take(3).map(
      (finding) => _ReportAiSummaryItem(
        color: finding.color,
        text: '${finding.title}: ${finding.body}',
      ),
    ),
  ];
}

class _ReportAiSummaryContent {
  const _ReportAiSummaryContent({
    required this.subtitle,
    required this.bullets,
    this.summaryText,
    this.footer,
    this.showGenerateButton = false,
  });

  final String subtitle;
  final List<_ReportAiSummaryItem> bullets;
  final String? summaryText;
  final String? footer;
  final bool showGenerateButton;
}

class _ReportAiSummaryItem {
  const _ReportAiSummaryItem({
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;
}

String _reportAiSummarySubtitle(
  AppLocalizations l10n,
  ReportAiSummaryRange range,
) {
  return switch (range) {
    ReportAiSummaryRange.last30Days => l10n.reportAiSummarySubtitleLast30Days,
    ReportAiSummaryRange.last7Days => l10n.reportAiSummarySubtitle,
  };
}

String _reportAiSummaryGeneratingLabel(
  AppLocalizations l10n,
  ReportAiSummaryRange range,
) {
  return switch (range) {
    ReportAiSummaryRange.last30Days =>
      l10n.reportAiSummaryGeneratingHintLast30Days,
    ReportAiSummaryRange.last7Days => l10n.reportAiSummaryGeneratingHint,
  };
}

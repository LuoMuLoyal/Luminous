import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_components.dart';
import 'package:luminous/features/report/presentation/widgets/report_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportTopBar extends StatelessWidget {
  const ReportTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
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
        const SizedBox(width: AppSpacingTokens.sm),
        Tooltip(
          message: l10n.reportShareTooltip,
          child: IconButton(
            onPressed: () => showReportToast(context, l10n.reportShareTooltip),
            icon: const Icon(Icons.ios_share_rounded),
            color: theme.colorScheme.onSurface,
            visualDensity: VisualDensity.compact,
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
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
      borderColor: ReportPalette.violet.withValues(alpha: 0.26),
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
                          color: ReportPalette.violet,
                          fontSize: 58,
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
                        width: 56,
                        radius: AppRadiusTokens.sm,
                      ),
                      child: ReportPill(
                        label: reportCopy(l10n, score.statusKey),
                        color: ReportPalette.green,
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
                    label: reportCopy(l10n, score.bodyKey),
                    onTap: () => showReportToast(
                      context,
                      reportCopy(l10n, score.bodyKey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: ReportPalette.violet.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const SizedBox.square(
              dimension: 112,
              child: Icon(
                Icons.health_and_safety_rounded,
                color: ReportPalette.violet,
                size: 76,
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
        mainAxisExtent: 174,
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
    final directionIcon = switch (metric.direction) {
      ReportMetricDirection.up => Icons.arrow_upward_rounded,
      ReportMetricDirection.down => Icons.arrow_downward_rounded,
      ReportMetricDirection.flat => Icons.arrow_forward_rounded,
    };
    final directionColor = switch (metric.direction) {
      ReportMetricDirection.down => Theme.of(context).colorScheme.error,
      _ => ReportPalette.green,
    };
    final value = metric.valueKey == null
        ? metric.value
        : reportCopy(l10n, metric.valueKey!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            showReportToast(context, reportCopy(l10n, metric.titleKey)),
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
                      reportCopy(l10n, metric.titleKey),
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
                    text: value,
                    style: typography.displayLg.copyWith(
                      color: metric.color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                    width: 48,
                  ),
                  if (metric.unitKey != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.xxs,
                      ),
                      child: Text(
                        reportCopy(l10n, metric.unitKey!),
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
                      width: 46,
                      radius: AppRadiusTokens.sm,
                    ),
                    child: ReportPill(
                      label: reportCopy(l10n, metric.statusKey),
                      color:
                          metric.statusKey == ReportCopyKey.statusNeedsImprove
                          ? ReportPalette.orange
                          : ReportPalette.green,
                      backgroundAlpha: 0.1,
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.xs),
                  Icon(directionIcon, size: 14, color: directionColor),
                  const SizedBox(width: AppSpacingTokens.xxs),
                  Expanded(
                    child: AppSkeletonText(
                      text: reportCopy(l10n, metric.deltaKey),
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
    return ReportPanel(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportSectionHeader(
            title: l10n.reportTrendSectionTitle,
            trailing: ReportPeriodPill(label: l10n.reportRangeLast7Days),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Wrap(
            spacing: AppSpacingTokens.md,
            runSpacing: AppSpacingTokens.xs,
            children: [
              for (final series in trends)
                _LegendDot(
                  color: series.color,
                  label: reportCopy(l10n, series.labelKey),
                  typography: typography,
                  surface: surface,
                ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          _TrendPlaceholder(
            trends: trends,
            l10n: l10n,
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Center(
            child: ReportTextAction(
              label: l10n.reportViewDetailsAction,
              color: ReportPalette.blue,
              onTap: () =>
                  showReportToast(context, l10n.reportViewDetailsAction),
            ),
          ),
        ],
      ),
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
    return ReportPanel(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportSectionHeader(title: l10n.reportFindingsSectionTitle),
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
                      l10n: l10n,
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
      ),
    );
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({
    required this.finding,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportFinding finding;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final title = reportCopy(l10n, finding.titleKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, title),
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
                  text: title,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                  widthFactor: 0.7,
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                AppSkeletonText(
                  text: reportCopy(l10n, finding.bodyKey),
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
    required this.bullets,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportAiBullet> bullets;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return ReportPanel(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      child: Column(
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
                      l10n.reportAiSummarySubtitle,
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              OutlinedButton(
                onPressed: () =>
                    showReportToast(context, l10n.reportViewAdviceAction),
                child: Text(l10n.reportViewAdviceAction),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          for (final bullet in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacingTokens.xs),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: bullet.color,
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
                      text: reportCopy(l10n, bullet.bodyKey),
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
        ],
      ),
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
    final title = reportCopy(l10n, action.titleKey);

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
                      reportCopy(l10n, action.subtitleKey),
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
            mainAxisExtent: 174,
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
    final title = reportCopy(l10n, pattern.titleKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, title),
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
                      title,
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
                text: reportCopy(l10n, pattern.statusKey),
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
                text: reportCopy(l10n, pattern.bodyKey),
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

class ReportPrivacySection extends StatelessWidget {
  const ReportPrivacySection({
    super.key,
    required this.actions,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportPrivacyAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return ReportPanel(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      borderColor: ReportPalette.green.withValues(alpha: 0.18),
      color: Color.alphaBlend(
        ReportPalette.green.withValues(alpha: 0.05),
        surface.canvas,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReportIconBadge(
                icon: Icons.lock_rounded,
                color: ReportPalette.green,
                size: 44,
                iconSize: 22,
                shape: BoxShape.circle,
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportPrivacyTitle,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(
                      l10n.reportPrivacyBody,
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              ReportTextAction(
                label: l10n.reportLearnMoreAction,
                color: ReportPalette.green,
                onTap: () =>
                    showReportToast(context, l10n.reportLearnMoreAction),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Text(
            l10n.reportPrivacySettingsTitle,
            style: typography.bodyMdStrong.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          Row(
            children: [
              for (var index = 0; index < actions.length; index += 1) ...[
                Expanded(
                  child: _PrivacyActionChip(
                    action: actions[index],
                    l10n: l10n,
                    typography: typography,
                  ),
                ),
                if (index != actions.length - 1)
                  const SizedBox(width: AppSpacingTokens.sm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacyActionChip extends StatelessWidget {
  const _PrivacyActionChip({
    required this.action,
    required this.l10n,
    required this.typography,
  });

  final ReportPrivacyAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    final label = reportCopy(l10n, action.titleKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, label),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).extension<AppThemeSurface>()!.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(
              color: Theme.of(context).extension<AppThemeSurface>()!.hairline,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.sm,
              vertical: AppSpacingTokens.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, color: action.color, size: 18),
                const SizedBox(width: AppSpacingTokens.xs),
                Flexible(
                  child: Text(
                    label,
                    style: typography.bodySmStrong.copyWith(letterSpacing: 0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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

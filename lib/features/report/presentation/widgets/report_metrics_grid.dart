import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_status_pill.dart';
import 'package:luminous/core/widgets/app_icon_badge.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_components.dart';
import 'package:luminous/features/report/presentation/widgets/report_section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportMetricsGrid extends StatelessWidget {
  const ReportMetricsGrid({
    super.key,
    required this.dashboard,
    required this.metrics,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportDashboard dashboard;
  final List<ReportMetric> metrics;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final displayMetrics = _buildDisplayMetrics();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayMetrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacingTokens.sm,
        mainAxisSpacing: AppSpacingTokens.sm,
        mainAxisExtent: _metricCardHeight(context),
      ),
      itemBuilder: (context, index) {
        return _MetricCard(
          metric: displayMetrics[index],
          l10n: l10n,
          typography: typography,
          surface: surface,
        );
      },
    );
  }

  List<ReportMetric> _buildDisplayMetrics() {
    final normalized = List<ReportMetric>.of(metrics);
    final hasGeneral = normalized.any(
      (metric) => metric.kind == ReportDataKind.general,
    );
    if (!hasGeneral) {
      normalized.add(
        ReportMetric(
          kind: ReportDataKind.general,
          icon: Icons.monitor_heart_rounded,
          color: ReportPalette.previewScore,
          value: _deriveOverallValue(),
          unit: _deriveOverallUnit(),
          status: dashboard.score.status,
          delta: _deriveOverallDelta(),
          direction: ReportMetricDirection.flat,
          sparkline: _deriveOverallSparkline(),
        ),
      );
    }
    return normalized;
  }

  String _deriveOverallValue() {
    if (_allMetricValuesUnavailable && dashboard.score.value == 0) {
      return '--';
    }
    return dashboard.score.value.toString();
  }

  String _deriveOverallUnit() {
    if (_allMetricValuesUnavailable && dashboard.score.value == 0) {
      return '';
    }
    return '/${dashboard.score.maxValue}';
  }

  String _deriveOverallDelta() {
    return _allMetricValuesUnavailable ? '--' : l10n.reportMetricOverallDelta;
  }

  List<double> _deriveOverallSparkline() {
    if (metrics.isEmpty) {
      return const <double>[0, 0, 0, 0, 0, 0, 0];
    }
    final longest = metrics
        .map((metric) => metric.sparkline.length)
        .fold<int>(0, (max, length) => length > max ? length : max);
    if (longest == 0) {
      return const <double>[0, 0, 0, 0, 0, 0, 0];
    }

    return List<double>.generate(longest, (index) {
      var sum = 0.0;
      var count = 0;
      for (final metric in metrics) {
        if (index < metric.sparkline.length) {
          sum += metric.sparkline[index];
          count += 1;
        }
      }
      return count == 0 ? 0 : sum / count;
    }, growable: false);
  }

  double _metricCardHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop) return 184;
    if (width >= AppBreakpoints.tablet) return 172;
    return 160;
  }

  bool get _allMetricValuesUnavailable =>
      metrics.isNotEmpty && metrics.every((metric) => metric.value == '--');
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
    final title = reportMetricTitle(l10n, metric.kind);
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
        child: AppSectionSurface(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIconBadge(
                    icon: metric.icon,
                    color: metric.color,
                    size: AppResponsiveSizing.scaleByWidth(
                      context,
                      fraction: 0.084,
                      minValue: 28,
                      maxValue: 36,
                    ),
                    iconSize: AppResponsiveSizing.scaleByWidth(
                      context,
                      fraction: 0.046,
                      minValue: 16,
                      maxValue: 20,
                    ),
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
                    widthFactor: 0.32,
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
              const SizedBox(height: AppSpacingTokens.xxs),
              Row(
                children: [
                  AppSkeletonSlot(
                    skeleton: AppInlineSkeletonBlock(
                      height: (typography.bodySm.fontSize ?? 14) + 8,
                      widthFactor: 0.36,
                      radius: AppRadiusTokens.sm,
                    ),
                    child: AppStatusPill(
                      label: reportStatusLabel(l10n, metric.status),
                      color: reportStatusColor(metric.status),
                      backgroundAlpha: 0.1,
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.xs),
                  Icon(
                    directionIcon,
                    size: AppResponsiveSizing.scaleByWidth(
                      context,
                      fraction: 0.034,
                      minValue: 12,
                      maxValue: 16,
                    ),
                    color: directionColor,
                  ),
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
                  height: 22,
                  radius: AppRadiusTokens.sm,
                ),
                child: ReportMetricTrack(
                  values: metric.sparkline,
                  color: metric.color,
                  height: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

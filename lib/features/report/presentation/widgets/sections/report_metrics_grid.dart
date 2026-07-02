import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_components.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportMetricsGrid extends StatelessWidget {
  const ReportMetricsGrid({
    super.key,
    required this.dashboard,
    required this.metrics,
    required this.l10n,
    this.onMetricSelected,
  });

  final ReportDashboard dashboard;
  final List<ReportMetric> metrics;
  final AppLocalizations l10n;
  final ValueChanged<ReportDataKind>? onMetricSelected;

  @override
  Widget build(BuildContext context) {
    final displayMetrics = _buildDisplayMetrics();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayMetrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacingTokens.level3,
        mainAxisSpacing: AppSpacingTokens.level3,
        mainAxisExtent: _metricCardHeight(context),
      ),
      itemBuilder: (context, index) {
        return _MetricCard(
          metric: displayMetrics[index],
          l10n: l10n,
          onTap: onMetricSelected,
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
          icon: FLucideIcons.heartPulse,
          color: Color(0xFF15803D),
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
    if (width >= AppBreakpoints.desktop) return 188;
    if (width >= AppBreakpoints.tablet) return 176;
    return 164;
  }

  bool get _allMetricValuesUnavailable =>
      metrics.isNotEmpty && metrics.every((metric) => metric.value == '--');
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric, required this.l10n, this.onTap});

  final ReportMetric metric;
  final AppLocalizations l10n;
  final ValueChanged<ReportDataKind>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final title = reportMetricTitle(l10n, metric.kind);
    final directionIcon = switch (metric.direction) {
      ReportMetricDirection.up => FLucideIcons.arrowUp,
      ReportMetricDirection.down => FLucideIcons.arrowDown,
      ReportMetricDirection.flat => FLucideIcons.arrowRight,
    };
    final directionColor = switch (metric.direction) {
      ReportMetricDirection.down => colors.destructive,
      _ => Color(0xFF0F766E),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(metric.kind),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
        child: FCard.raw(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.level4),
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
                    const SizedBox(width: AppSpacingTokens.level2),
                    Expanded(
                      child: Text(
                        title,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level3),
                Wrap(
                  spacing: AppSpacingTokens.level1,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    AppSkeletonText(
                      text: metric.value,
                      style: textTheme.headlineMedium?.copyWith(
                        color: metric.color,
                        fontWeight: FontWeight.w800,
                      ),
                      widthFactor: 0.32,
                    ),
                    if (metric.unit.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacingTokens.level1,
                        ),
                        child: Text(
                          metric.unit,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                Row(
                  children: [
                    AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 20,
                        widthFactor: 0.36,
                        radius: AppRadiusTokens.level2,
                      ),
                      child: _MetricBadge(
                        label: reportStatusLabel(l10n, metric.status),
                        color: reportStatusColor(metric.status),
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.level2),
                    Icon(directionIcon, size: 14, color: directionColor),
                    const SizedBox(width: AppSpacingTokens.level1),
                    Expanded(
                      child: AppSkeletonText(
                        text: metric.delta,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.mutedForeground,
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
                    radius: AppRadiusTokens.level2,
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
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level2,
          vertical: AppSpacingTokens.level1,
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

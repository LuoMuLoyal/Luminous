import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/components.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
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
    final displayMetrics = _buildDisplayMetrics(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayMetrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Spacing.level3,
        mainAxisSpacing: Spacing.level3,
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

  List<ReportMetric> _buildDisplayMetrics(BuildContext context) {
    final normalized = List<ReportMetric>.of(metrics);
    final hasGeneral = normalized.any(
      (metric) => metric.kind == ReportDataKind.general,
    );
    if (!hasGeneral) {
      normalized.add(
        ReportMetric(
          kind: ReportDataKind.general,
          icon: FLucideIcons.heartPulse,
          color: SemanticColor.primary,
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
      return l10n.placeholderNoData;
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
    return _allMetricValuesUnavailable
        ? l10n.placeholderNoData
        : l10n.reportMetricOverallDelta;
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
    // Values account for: FCard internal padding + button padding + Column content
    // (title row ~36 + value row ~32 + status row ~22 + track 22 + gaps 18 + safety 20)
    if (width >= Breakpoints.desktop) return 230;
    if (width >= Breakpoints.tablet) return 234;
    return 234;
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

    final title = reportMetricTitle(l10n, metric.kind);
    final directionIcon = switch (metric.direction) {
      ReportMetricDirection.up => FLucideIcons.arrowUp,
      ReportMetricDirection.down => FLucideIcons.arrowDown,
      ReportMetricDirection.flat => FLucideIcons.arrowRight,
    };
    final directionColor = switch (metric.direction) {
      ReportMetricDirection.down => colors.destructive,
      _ => context.theme.colors.primary,
    };

    return FButton.raw(
      onPress: onTap == null ? null : () => onTap!(metric.kind),
      variant: FButtonVariant.ghost,
      style: const .delta(
        contentStyle: .delta(padding: .value(EdgeInsets.zero)),
      ),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FAvatar.raw(
                    size: ResponsiveSizing.scaleByWidth(
                      context,
                      fraction: 0.084,
                      minValue: 28,
                      maxValue: 36,
                    ),
                    child: Icon(
                      metric.icon,
                      color: metric.color.solid(context),
                      size: ResponsiveSizing.scaleByWidth(
                        context,
                        fraction: 0.046,
                        minValue: 16,
                        maxValue: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.level2),
                  Expanded(
                    child: Text(
                      title,
                      style: TypographyToken.level5
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level3),
              Wrap(
                spacing: Spacing.level1,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  SkeletonText(
                    text: metric.value,
                    style: TypographyToken.level8
                        .display(context)
                        .copyWith(
                          color: metric.color.solid(context),
                          fontWeight: FontWeight.w800,
                        ),
                    widthFactor: 0.32,
                  ),
                  if (metric.unit.isNotEmpty &&
                      metric.value != '--' &&
                      metric.value != l10n.placeholderNoData)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.level1),
                      child: Text(
                        metric.unit,
                        style: TypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.level1),
              Row(
                children: [
                  Flexible(
                    child: SkeletonSlot(
                      skeleton: const InlineSkeletonBlock(
                        height: 20,
                        widthFactor: 0.36,
                        radius: RadiusTokens.level2,
                      ),
                      child: _MetricBadge(
                        label: reportStatusLabel(l10n, metric.status),
                        color: reportStatusColor(metric.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.level2),
                  Icon(
                    directionIcon,
                    size: IconSizeTokens.level2,
                    color: directionColor,
                  ),
                  const SizedBox(width: Spacing.level1),
                  Expanded(
                    child: SkeletonText(
                      text: metric.delta,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.82,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SkeletonSlot(
                skeleton: const InlineSkeletonBlock(
                  height: 22,
                  radius: RadiusTokens.level2,
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

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.color});

  final String label;
  final SemanticColor color;

  @override
  Widget build(BuildContext context) {
    final palette = color.palette(context);

    return FBadge.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: palette.muted,
          shape: RoundedSuperellipseBorder(
            borderRadius: context.theme.style.borderRadius.sm,
          ),
        ),
      ),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: palette.solid, fontWeight: FontWeight.w800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

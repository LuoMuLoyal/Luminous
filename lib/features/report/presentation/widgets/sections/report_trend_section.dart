import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/report_range_picker_dialog.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_components.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_section_models.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_top_bar.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportTrendSection extends StatelessWidget {
  const ReportTrendSection({
    super.key,
    required this.trends,
    required this.selectedQuery,
    required this.onQueryChanged,
    required this.l10n,
  });

  final List<ReportTrendSeries> trends;
  final ReportDashboardQuery selectedQuery;
  final ValueChanged<ReportDashboardQuery> onQueryChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                l10n.reportTrendSectionTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ReportPeriodPill(
              range: selectedQuery.range,
              onTap: () => _showRangePicker(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        Divider(height: 1, thickness: 1, color: colors.border),
        const SizedBox(height: AppSpacingTokens.level4),
        Wrap(
          spacing: AppSpacingTokens.level4,
          runSpacing: AppSpacingTokens.level2,
          children: [
            for (final series in trends)
              _LegendDot(
                color: series.color,
                label: reportMetricTitle(l10n, series.kind),
              ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        _TrendPlaceholder(trends: trends, l10n: l10n),
        const SizedBox(height: AppSpacingTokens.level3),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            l10n.reportViewDetailsAction,
            style: textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showRangePicker(BuildContext context) async {
    final selected = await showReportRangePickerDialog(
      context,
      selectedQuery: selectedQuery,
    );
    if (selected != null && selected != selectedQuery) {
      onQueryChanged(selected);
    }
  }
}

class _TrendPlaceholder extends StatelessWidget {
  const _TrendPlaceholder({required this.trends, required this.l10n});

  final List<ReportTrendSeries> trends;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Container(
        decoration: BoxDecoration(
          color: colors.secondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
          border: Border.all(color: colors.border),
        ),
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          children: [
            SizedBox(
              height: AppResponsiveSizing.scaleByHeight(
                context,
                fraction: 0.22,
                minValue: 144,
                maxValue: 200,
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var index = 0; index < 5; index += 1)
                        Divider(height: 1, color: colors.border),
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
                              bottom: AppSpacingTokens.level2,
                            ),
                            child: AppSkeletonSlot(
                              skeleton: const AppInlineSkeletonBlock(
                                height: 22,
                                width: 46,
                                radius: AppRadiusTokens.level2,
                              ),
                              child: _TrendValuePill(
                                label: series.currentValue,
                                color: series.color,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: AppResponsiveSizing.scaleByWidth(
                        context,
                        fraction: 0.14,
                        minValue: 48,
                        maxValue: 72,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final series in trends)
                          AppSkeletonSlot(
                            skeleton: const AppInlineSkeletonBlock(
                              height: 30,
                              radius: AppRadiusTokens.level2,
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
            const SizedBox(height: AppSpacingTokens.level3),
            Row(
              children: [
                for (final label in l10n.reportTrendDateLabels.split('|'))
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.mutedForeground,
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox.square(dimension: 8),
        ),
        const SizedBox(width: AppSpacingTokens.level2),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: colors.mutedForeground),
        ),
      ],
    );
  }
}

class _TrendValuePill extends StatelessWidget {
  const _TrendValuePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
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
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

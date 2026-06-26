import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/app_text_action.dart';
import 'package:luminous/core/widgets/app_status_pill.dart';
import 'package:luminous/core/widgets/app_section_header.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_components.dart';
import 'package:luminous/features/report/presentation/widgets/report_range_picker_dialog.dart';
import 'package:luminous/features/report/presentation/widgets/report_section_models.dart';
import 'package:luminous/features/report/presentation/widgets/report_top_bar.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportTrendSection extends StatelessWidget {
  const ReportTrendSection({
    super.key,
    required this.trends,
    required this.selectedQuery,
    required this.onQueryChanged,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportTrendSeries> trends;
  final ReportDashboardQuery selectedQuery;
  final ValueChanged<ReportDashboardQuery> onQueryChanged;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: l10n.reportTrendSectionTitle,
          trailing: ReportPeriodPill(
            range: selectedQuery.range,
            onTap: () => _showRangePicker(context),
          ),
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
                label: reportMetricTitle(l10n, series.kind),
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
          child: AppTextAction(
            label: l10n.reportViewDetailsAction,
            flexible: true,
            color: ReportPalette.blue,
            onTap: null,
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
                              child: AppStatusPill(
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

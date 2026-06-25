import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_text_action.dart';
import 'package:luminous/core/widgets/app_status_pill.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordTrendsPanel extends StatelessWidget {
  const RecordTrendsPanel({
    super.key,
    required this.trends,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.compact = false,
    this.onEdit,
  });

  final List<RecordTrend> trends;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool compact;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      key: const Key('record-trends'),
      title: l10n.recordTrendsSectionTitle,
      trailing: AppTextAction(
        label: l10n.recordEditAction,
        icon: null,
        onTap: onEdit ?? () => showRecordToast(context, l10n.recordEditAction),
      ),
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          for (var index = 0; index < trends.length; index += 1)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == trends.length - 1 ? 0 : AppSpacingTokens.md,
              ),
              child: _TrendCard(
                trend: trends[index],
                l10n: l10n,
                typography: typography,
                surface: surface,
                compact: compact,
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.trend,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.compact,
  });

  final RecordTrend trend;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showRecordToast(context, recordCopy(l10n, trend.titleKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recordCopy(l10n, trend.titleKey),
                        style: typography.bodySmStrong,
                      ),
                    ),
                    AppStatusPill(
                      label: recordCopy(l10n, trend.rangeKey),
                      color: trend.color,
                      typography: typography,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.md),
                if (trend.bars.isEmpty)
                  RecordLineChart(
                    points: trend.points,
                    color: trend.color,
                    surface: surface,
                    secondaryPoints: trend.secondaryPoints,
                    secondaryColor: trend.secondaryColor,
                    height: compact ? 84 : 104,
                  )
                else
                  RecordBarChart(
                    values: trend.bars,
                    color: trend.color,
                    surface: surface,
                    height: compact ? 84 : 104,
                  ),
                if (trend.legendKey != null) ...[
                  const SizedBox(height: AppSpacingTokens.sm),
                  Wrap(
                    spacing: AppSpacingTokens.md,
                    runSpacing: AppSpacingTokens.xs,
                    children: [
                      _LegendDot(
                        color: trend.color,
                        label: recordCopy(l10n, trend.legendKey!),
                        typography: typography,
                        surface: surface,
                      ),
                      if (trend.secondaryLegendKey != null &&
                          trend.secondaryColor != null)
                        _LegendDot(
                          color: trend.secondaryColor!,
                          label: recordCopy(l10n, trend.secondaryLegendKey!),
                          typography: typography,
                          surface: surface,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
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
          child: const SizedBox.square(dimension: 7),
        ),
        const SizedBox(width: AppSpacingTokens.xs),
        Text(label, style: typography.caption.copyWith(color: surface.body)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportRangePickerSheet extends StatelessWidget {
  const ReportRangePickerSheet({super.key, required this.selectedRange});

  final ReportDashboardRange selectedRange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.reportRangePickerTitle,
              style: typography.bodyMdStrong.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacingTokens.md),
            _RangeOption(
              range: ReportDashboardRange.last7Days,
              label: l10n.reportRangeLast7Days,
              selected: selectedRange == ReportDashboardRange.last7Days,
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            _RangeOption(
              range: ReportDashboardRange.last30Days,
              label: l10n.reportRangeLast30Days,
              selected: selectedRange == ReportDashboardRange.last30Days,
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeOption extends StatelessWidget {
  const _RangeOption({
    required this.range,
    required this.label,
    required this.selected,
  });

  final ReportDashboardRange range;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Material(
      color: surface.canvas,
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(range),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: typography.bodyMdStrong.copyWith(letterSpacing: 0),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_rounded,
                  color: surface.accent,
                  size: AppSpacingTokens.lg,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

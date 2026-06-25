import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportRangePickerSheet extends StatelessWidget {
  const ReportRangePickerSheet({super.key, required this.selectedQuery});

  final ReportDashboardQuery selectedQuery;

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
              query: const ReportDashboardQuery(
                range: ReportDashboardRange.last7Days,
              ),
              label: l10n.reportRangeLast7Days,
              selected: selectedQuery.range == ReportDashboardRange.last7Days,
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            _RangeOption(
              query: const ReportDashboardQuery(
                range: ReportDashboardRange.last30Days,
              ),
              label: l10n.reportRangeLast30Days,
              selected: selectedQuery.range == ReportDashboardRange.last30Days,
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            _RangeOption(
              query: selectedQuery.isCustom
                  ? selectedQuery
                  : const ReportDashboardQuery(
                      range: ReportDashboardRange.custom,
                    ),
              label: l10n.reportRangeCustom,
              selected: selectedQuery.range == ReportDashboardRange.custom,
              onCustomTap: () async {
                final now = DateTime.now();
                final initialDateRange = selectedQuery.isCustom
                    ? DateTimeRange(
                        start: selectedQuery.startDate!,
                        end: selectedQuery.endDate!,
                      )
                    : DateTimeRange(
                        start: now.subtract(const Duration(days: 7)),
                        end: now,
                      );
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: now,
                  initialDateRange: initialDateRange,
                );
                if (picked != null && context.mounted) {
                  Navigator.of(context).pop(
                    ReportDashboardQuery(
                      range: ReportDashboardRange.custom,
                      startDate: picked.start,
                      endDate: picked.end,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeOption extends StatelessWidget {
  const _RangeOption({
    required this.query,
    required this.label,
    required this.selected,
    this.onCustomTap,
  });

  final ReportDashboardQuery query;
  final String label;
  final bool selected;
  final VoidCallback? onCustomTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final isCustom = query.range == ReportDashboardRange.custom;

    return Material(
      color: surface.canvas,
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isCustom ? onCustomTap : () => Navigator.of(context).pop(query),
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

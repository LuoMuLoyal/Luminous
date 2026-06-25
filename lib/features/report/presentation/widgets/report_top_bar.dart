import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_components.dart';
import 'package:luminous/features/report/presentation/widgets/report_range_picker_sheet.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportTopBar extends StatelessWidget {
  const ReportTopBar({
    super.key,
    required this.dateRangeLabel,
    required this.selectedRange,
    required this.onRangeSelected,
    required this.onGenerate,
    required this.onSync,
    this.isGenerating = false,
    this.isSyncing = false,
  });

  final String dateRangeLabel;
  final ReportDashboardRange selectedRange;
  final ValueChanged<ReportDashboardRange> onRangeSelected;
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
                    dateRangeLabel,
                    style: typography.bodyLg.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.md),
            ReportPeriodPill(
              range: selectedRange,
              onTap: () => _showRangePicker(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.xs),
        _ReportSnapshotStatus(typography: typography, surface: surface),
        const SizedBox(height: AppSpacingTokens.xs),
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

  Future<void> _showRangePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<ReportDashboardRange>(
      context: context,
      useRootNavigator: true,
      builder: (context) =>
          ReportRangePickerSheet(selectedRange: selectedRange),
    );
    if (selected != null && selected != selectedRange) {
      onRangeSelected(selected);
    }
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
  const ReportPeriodPill({super.key, required this.range, required this.onTap});

  final ReportDashboardRange range;
  final VoidCallback onTap;

  String _label(AppLocalizations l10n) => switch (range) {
    ReportDashboardRange.last7Days => l10n.reportRangeLast7Days,
    ReportDashboardRange.last30Days => l10n.reportRangeLast30Days,
    ReportDashboardRange.custom => l10n.reportRangeCustom,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                  _label(l10n),
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

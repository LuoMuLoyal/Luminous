import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/app_top_bar.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/report_range_picker_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportTopBar extends StatelessWidget {
  const ReportTopBar({
    super.key,
    required this.dateRangeLabel,
    required this.selectedQuery,
    required this.onQueryChanged,
    required this.onGenerate,
    required this.onSync,
    this.isGenerating = false,
    this.isSyncing = false,
  });

  final String dateRangeLabel;
  final ReportDashboardQuery selectedQuery;
  final ValueChanged<ReportDashboardQuery> onQueryChanged;
  final VoidCallback onGenerate;
  final VoidCallback onSync;
  final bool isGenerating;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      title: l10n.tabReport,
      subtitle: Text(dateRangeLabel),
      trailing: [
        ReportPeriodPill(
          range: selectedQuery.range,
          onTap: () => _showRangePicker(context),
        ),
      ],
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ReportSnapshotStatus(),
          const SizedBox(height: AppSpacingTokens.level3),
          Row(
            children: [
              Expanded(
                child: FButton(
                  key: const Key('report-generate-action'),
                  onPress: isGenerating ? null : onGenerate,
                  prefix: Icon(
                    isGenerating
                        ? FLucideIcons.loaderCircle
                        : FLucideIcons.sparkles,
                    size: 16,
                  ),
                  child: Text(
                    l10n.reportGenerateAction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacingTokens.level3),
              FTooltip(
                tipBuilder: (context, controller) =>
                    Text(l10n.reportSyncAction),
                child: FButton(
                  key: const Key('report-sync-action'),
                  variant: FButtonVariant.secondary,
                  onPress: isSyncing ? null : onSync,
                  child: Icon(
                    isSyncing
                        ? FLucideIcons.loaderCircle
                        : FLucideIcons.refreshCw,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

class _ReportSnapshotStatus extends StatelessWidget {
  const _ReportSnapshotStatus();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FCard.raw(
      key: const Key('report-snapshot-status'),
      style: .delta(
        decoration: .shapeDelta(
          color: colors.secondary.withValues(alpha: 0.08),
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: colors.border),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            Icon(FLucideIcons.history, color: colors.primary, size: 18),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportSnapshotStatus,
                    style: AppTypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  Text(
                    l10n.reportSnapshotHint,
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final colors = context.theme.colors;

    return FButton.raw(
      onPress: onTap,
      variant: FButtonVariant.outline,
      style: .delta(
        decoration: .delta([
          .all(
            .shapeDelta(
              color: colors.background,
              shape: RoundedSuperellipseBorder(
                side: BorderSide(color: colors.border),
                borderRadius: context.theme.style.borderRadius.sm,
              ),
            ),
          ),
        ]),
        contentStyle: const .delta(
          padding: .value(
            EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level4,
              vertical: AppSpacingTokens.level3,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _label(l10n),
            style: AppTypographyToken.level4
                .body(context)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: AppSpacingTokens.level1),
          Icon(
            FLucideIcons.chevronDown,
            size: 16,
            color: colors.mutedForeground,
          ),
        ],
      ),
    );
  }
}
